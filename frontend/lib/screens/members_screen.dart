// Owner: Jassem
// What: List of members. Selecting a member shows that member's bookings.
// Checklist: members are created and displayed; choosing a member shows that member's bookings;
//            loading, success, and error states; list refreshes after create or update.
// Depends on: ApiClient getMembers, getBookings(memberId:) (Yyan); MemberFormScreen.

import 'package:material_ui/material_ui.dart';

import '../models/member.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../models/booking.dart';
import '../services/api_client.dart';
import 'member_form_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<Member> members = [];
  int? selectedId;
  List<Booking> memberBookings = [];
  bool loadingBookings = false;
  String? bookingsError;
  int bookingRequest = 0;
  bool loading = true;
  String? loadError;
  int requestId = 0;

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  Future<void> loadMembers() async {
    final request = ++requestId;
    setState(() {
      loading = true;
      loadError = null;
    });
    try {
      final result = await widget.api.getMembers();
      if (!mounted || request != requestId) return;
      setState(() {
        members = result;
        if (!members.any((member) => member.id == selectedId)) selectedId = null;
      });
    } catch (e) {
      if (mounted && request == requestId) setState(() => loadError = e.toString());
    } finally {
      if (mounted && request == requestId) setState(() => loading = false);
    }
  }


  Future<void> openForm({Member? member}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MemberFormScreen(api: widget.api, member: member),
      ),
    );

    if (!mounted || saved != true) return;

    await loadMembers();
    if (!mounted) return;
    final selected = members.where((item) => item.id == selectedId).firstOrNull;
    if (selected != null && loadError == null) selectMember(selected);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Member saved')));
  }

  Future<void> selectMember(Member member) async {
    final request = ++bookingRequest;
    setState(() {
      selectedId = member.id;
      loadingBookings = true;
      memberBookings = [];
      bookingsError = null;
    });
    try {
      final result = await widget.api.getBookings(memberId: member.id);
      if (mounted && request == bookingRequest) setState(() => memberBookings = result);
    } catch (e) {
      if (mounted && request == bookingRequest) setState(() => bookingsError = e.toString());
    } finally {
      if (mounted && request == bookingRequest) setState(() => loadingBookings = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final member = members.where((item) => item.id == selectedId).firstOrNull;
    final heading = Theme.of(context).textTheme.titleMedium;

    final memberRows = <Widget>[
      if (members.isEmpty)
        const ListTile(
          title: Text('No members yet'),
          subtitle: Text('Choose New member to add the first member.'),
        ),
      for (final item in members)
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
      else if (loadingBookings)
        const LoadingView()
      else if (bookingsError != null)
        ErrorView(message: bookingsError!, onRetry: () => selectMember(member))
      else if (memberBookings.isEmpty)
        const ListTile(title: Text('This member has no bookings.'))
      else
        for (final booking in memberBookings)
          ListTile(
            title: Text(booking.resourceName),
            subtitle: Text(
              '${booking.isCancelled ? "Cancelled" : "Confirmed"}'
              ' • Total: ${booking.totalCost.toStringAsFixed(2)}',
            ),
          ),
    ];

    if (loading || loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Members')),
        body: loading
            ? const LoadingView()
            : ErrorView(message: loadError!, onRetry: loadMembers),
      );
    }
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
