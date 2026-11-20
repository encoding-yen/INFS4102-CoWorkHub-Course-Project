// Owner: Jassem
// What: Create or edit a member.
// Checklist: management screens create and update a member; the form stops an empty name or an empty email
//            before the request is sent; a duplicate email shows the server's 409 message.
// Depends on: ApiClient createMember, updateMember (Yyan).

import 'package:material_ui/material_ui.dart';

import '../models/member.dart';
import '../services/api_client.dart';

class MemberFormScreen extends StatefulWidget {
  /// Pass [member] to edit it; leave it null to create a new member.
  const MemberFormScreen({super.key, required this.api, this.member});

  final ApiClient api;
  final Member? member;

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  // TODO(Jassem): A Form with a GlobalKey<FormState> and controllers for fullName and email.

  String? validateName(String? value) {
    // TODO(Jassem): 'Name is required' when empty.
    throw UnimplementedError('TODO(Jassem): validateName');
  }

  String? validateEmail(String? value) {
    // TODO(Jassem): 'Email is required' when empty; 'Enter a valid email' when it has no @.
    throw UnimplementedError('TODO(Jassem): validateEmail');
  }

  Future<void> save() async {
    // TODO(Jassem): Validate, show loading, call createMember or updateMember, show success,
    //               Navigator.pop(context, true). On ApiException show its message.
    throw UnimplementedError('TODO(Jassem): MemberFormScreen.save');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('TODO(Jassem): Member form')),
    );
  }
}
