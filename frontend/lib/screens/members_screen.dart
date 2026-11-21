// Owner: Jassem
// What: List of members. Selecting a member shows that member's bookings.
// Checklist: members are created and displayed; choosing a member shows that member's bookings;
//            loading, success, and error states; list refreshes after create or update.
// Depends on: ApiClient getMembers, getBookings(memberId:) (Yyan); MemberFormScreen.
//             Use sampleMembers and sampleBookings until ApiClient works.

import 'package:material_ui/material_ui.dart';

import '../models/member.dart';
import '../models/sample_data.dart';
import '../services/api_client.dart';
import 'member_form_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  Member? selectedMember;
  Future<void> openForm({Member? member}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MemberFormScreen(api: widget.api, member: member),
      ),
    );

    if (!mounted || saved != true) return;

    setState(() {
      if (member != null && selectedMember?.id == member.id) {
        selectedMember = sampleMembers.firstWhere((m) => m.id == member.id);
      }
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Member saved')));
  }

  void selectMember(Member member) {
    setState(() {
      selectedMember = member;
    });
  }

  @override
  Widget build(BuildContext context) {
    final member = selectedMember;
    final bookings = sampleBookings
        .where((booking) => booking.memberId == member?.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          TextButton(
            onPressed: () => openForm(),
            child: const Text('New member'),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (final item in sampleMembers)
                  ListTile(
                    title: Text(item.fullName),
                    subtitle: Text(item.email),
                    selected: item.id == member?.id,
                    onTap: () => selectMember(item),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit member',
                      onPressed: () => openForm(member: item),
                    ),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: member == null
                ? const Center(child: Text('Select a member to see bookings'))
                : ListView(
                    children: [
                      ListTile(title: Text('Bookings for ${member.fullName}')),
                      if (bookings.isEmpty)
                        const ListTile(title: Text('No bookings')),
                      for (final booking in bookings)
                        ListTile(
                          title: Text(booking.resourceName),
                          subtitle: Text(booking.status),
                          trailing: Text(
                            'Total: ${booking.totalCost.toStringAsFixed(2)}',
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
