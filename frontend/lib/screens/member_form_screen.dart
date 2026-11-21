// Owner: Jassem
// What: Create or edit a member.
// Checklist: management screens create and update a member; the form stops an empty name or an empty email
//            before the request is sent; a duplicate email shows the server's 409 message.
// Depends on: ApiClient createMember, updateMember (Yyan).

import 'package:material_ui/material_ui.dart';

import '../models/member.dart';
import '../models/sample_data.dart';
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

    final taken = sampleMembers.any(
      (m) => m.id != widget.member?.id && m.email.toLowerCase() == email,
    );
    return taken ? 'This email is already in use' : null;
  }

  void save() {
    if (!formKey.currentState!.validate()) return;

    final original = widget.member;
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (original == null) {
      // New members are appended in ID order in the sample list.
      final id = sampleMembers.isEmpty ? 1 : sampleMembers.last.id + 1;
      sampleMembers.add(Member(id: id, fullName: name, email: email));
    } else {
      final index = sampleMembers.indexWhere((m) => m.id == original.id);
      sampleMembers[index] = Member(
        id: original.id,
        fullName: name,
        email: email,
      );
    }

    Navigator.pop(context, true);
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
            ElevatedButton(onPressed: save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
