// Owner: Jassem
// What: List of members. Selecting a member shows that member's bookings.
// Checklist: members are created and displayed; choosing a member shows that member's bookings;
//            loading, success, and error states; list refreshes after create or update.
// Depends on: ApiClient getMembers, getBookings(memberId:) (Yyan); MemberFormScreen.
//             Use sampleMembers and sampleBookings until ApiClient works.

import 'package:material_ui/material_ui.dart';

import '../models/member.dart';
import '../services/api_client.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  // TODO(Jassem): Hold loading / error / members / selected member / that member's bookings in state.

  @override
  void initState() {
    super.initState();
    // TODO(Jassem): Call loadMembers().
  }

  Future<void> loadMembers() async {
    // TODO(Jassem): await widget.api.getMembers(), then setState.
    throw UnimplementedError('TODO(Jassem): MembersScreen.loadMembers');
  }

  Future<void> selectMember(Member member) async {
    // TODO(Jassem): await widget.api.getBookings(memberId: member.id) and show them beside the list,
    //               with status and total cost, cancelled ones included.
    throw UnimplementedError('TODO(Jassem): MembersScreen.selectMember');
  }

  Future<void> openForm({Member? member}) async {
    // TODO(Jassem): Push MemberFormScreen to create or edit. Reload when it returns true.
    throw UnimplementedError('TODO(Jassem): MembersScreen.openForm');
  }

  @override
  Widget build(BuildContext context) {
    // TODO(Jassem): Member list on the left, selected member's bookings on the right, New member button.
    return const Scaffold(
      body: Center(child: Text("TODO(Jassem): Members screen with a selected member's bookings")),
    );
  }
}
