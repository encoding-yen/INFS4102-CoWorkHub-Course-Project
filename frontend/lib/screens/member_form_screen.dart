// Owner: Jassem
// What: Create or edit a member.
// Checklist: management screens create and update a member; the form stops an empty name or an empty email
//            before the request is sent; a duplicate email shows the server's 409 message.
// Depends on: ApiClient createMember, updateMember (Yyan).

import 'package:material_ui/material_ui.dart';

import '../models/member.dart';
import '../services/api_client.dart';

class MemberFormScreen extends StatefulWidget {
  const MemberFormScreen({super.key, required this.api, this.member});

  final ApiClient api;
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

    return null;
  }

  bool saving = false;
  String? error;

  Future<void> save() async {
    if (saving || !formKey.currentState!.validate()) return;

    final original = widget.member;
    final name = nameController.text;
    final email = emailController.text;

    setState(() {
      saving = true;
      error = null;
    });
    try {
      if (original == null) {
        await widget.api.createMember(fullName: name, email: email);
      } else {
        await widget.api.updateMember(original.id, fullName: name, email: email);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
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
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Name is required' : null,
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: validateEmail,
            ),
            const SizedBox(height: 16),
            if (error != null) Text(error!),
            ElevatedButton(onPressed: saving ? null : save, child: Text(saving ? 'Saving…' : 'Save')),
          ],
        ),
      ),
    );
  }
}
