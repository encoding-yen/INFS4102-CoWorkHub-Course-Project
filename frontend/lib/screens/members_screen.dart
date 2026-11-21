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
    final heading = Theme.of(context).textTheme.titleMedium;

    final memberRows = <Widget>[
      if (sampleMembers.isEmpty)
        const ListTile(
          title: Text('No members yet'),
          subtitle: Text('Choose New member to add the first member.'),
        ),
      for (final item in sampleMembers)
        ListTile(
          title: Text(item.fullName),
          subtitle: Text(item.email),
          selected: item.id == member?.id,
          leading: Icon(
            item.id == member?.id ? Icons.check_circle : Icons.person_outline,
          ),
          onTap: () => selectMember(item),
          trailing: IconButton(
            tooltip: 'Edit ${item.fullName}',
            icon: const Icon(Icons.edit),
            onPressed: () => openForm(member: item),
          ),
        ),
    ];

    final bookingRows = <Widget>[
      ListTile(
        title: Text(
          member == null
              ? 'Member bookings'
              : 'Bookings for ${member.fullName}',
          style: heading,
        ),
      ),
      if (member == null)
        const ListTile(title: Text('Select a member to see their bookings.'))
      else if (bookings.isEmpty)
        const ListTile(title: Text('This member has no bookings.'))
      else
        for (final booking in bookings)
          ListTile(
            title: Text(booking.resourceName),
            subtitle: Text(
              '${booking.isCancelled ? "Cancelled" : "Confirmed"}'
              ' • Total: ${booking.totalCost.toStringAsFixed(2)}',
            ),
          ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () => openForm(),
              icon: const Icon(Icons.person_add),
              label: const Text('New member'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 650) {
                    return ListView(
                      children: [
                        ...memberRows,
                        const Divider(),
                        ...bookingRows,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: ListView(children: memberRows)),
                      const VerticalDivider(width: 24),
                      Expanded(child: ListView(children: bookingRows)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
