// Owner: Jassem
// What: Create or edit a member.
// Checklist: management screens create and update a member; the form stops an empty name or an empty email
//            before the request is sent; a duplicate email shows the server's 409 message.
// Depends on: AppData (saves through ApiClient createMember, updateMember, then updates every screen).

import 'package:material_ui/material_ui.dart';

import '../models/member.dart';
import '../services/api_client.dart';
import '../state/app_data.dart';

class MemberFormScreen extends StatefulWidget {
  const MemberFormScreen({super.key, required this.data, this.member});

  final AppData data;
  final Member? member;

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final nameController = TextEditingController(
    text: widget.member?.fullName,
  );
  late final emailController = TextEditingController(
    text: widget.member?.email,
  );
  bool saving = false;
  String? error;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    final email = (value ?? '').trim().toLowerCase();
    if (email.isEmpty) return 'Email is required';
    if (!email.contains('@')) return 'Enter a valid email';

    final taken = widget.data.members.any(
      (m) => m.id != widget.member?.id && m.email.toLowerCase() == email,
    );
    return taken ? 'This email is already in use' : null;
  }

  Future<void> save() async {
    if (saving || !formKey.currentState!.validate()) return;

    final original = widget.member;
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    setState(() {
      saving = true;
      error = null;
    });

    try {
      if (original == null) {
        await widget.data.createMember(fullName: name, email: email);
      } else {
        await widget.data.updateMember(original.id, fullName: name, email: email);
      }
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      // For example the 409 message when the email is already used.
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.member == null ? 'New member' : 'Edit member'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: nameController,
              enabled: !saving,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Name is required' : null,
            ),
            TextFormField(
              controller: emailController,
              enabled: !saving,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: validateEmail,
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saving ? null : save,
              child: Text(saving ? 'Saving...' : 'Save'),
            ),
            if (saving) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
