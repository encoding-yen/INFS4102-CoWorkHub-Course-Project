// Owner: Jassem
// What: Pick dates and times, search availability, choose member and resource, enter attendees, submit.
//       This is the screen used in the demo for the successful booking AND the rejected overlapping booking.
// Checklist: collects member, resource, start, end, and attendees; shows resources from the availability search;
//            stops an end time before the start time or an empty attendee count before sending;
//            shows the server's error message (for example the 409 overlap message) on screen;
//            shows the price of the created booking.
// Depends on: AppData (members and resources, the availability search, and createBooking through ApiClient).
//             The member list and the names in the search results are read from AppData, so edits made
//             on other screens appear here immediately.

import 'package:material_ui/material_ui.dart';

import '../models/resource.dart';
import '../services/api_client.dart';
import '../state/app_data.dart';
import '../widgets/data_gate.dart';

class NewBookingScreen extends StatefulWidget {
  const NewBookingScreen({super.key, required this.data});

  final AppData data;

  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  int? memberId;
  DateTime? start;
  DateTime? end;
  final attendees = TextEditingController(text: '1');

  // The search keeps only the ids of the free spaces. Names, capacity, and status are read from
  // AppData each time the screen builds, so a rename or an OUT_OF_SERVICE change shows up here at once.
  List<int>? availableIds;
  int? resourceId;
  String? error;
  bool searching = false;
  bool submitting = false;

  @override
  void dispose() {
    attendees.dispose();
    super.dispose();
  }

  void resetSearch() {
    availableIds = null;
    resourceId = null;
    error = null;
  }

  Future<void> pickDateTime({required bool isStart}) async {
    final initial = isStart
        ? (start ?? DateTime.now())
        : (end ?? (start ?? DateTime.now()).add(const Duration(hours: 1)));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        start = picked;
      } else {
        end = picked;
      }
      resetSearch();
    });
  }

  Future<void> searchAvailability() async {
    if (searching) return;

    final from = start;
    final until = end;
    final count = int.tryParse(attendees.text.trim());

    String? problem;
    if (from == null || until == null) {
      problem = 'Choose a start and end time.';
    } else if (!until.isAfter(from)) {
      problem = 'End time must be after start time.';
    } else if (count == null || count < 1) {
      problem = 'Enter at least one attendee using a whole number.';
    }

    setState(() {
      resetSearch();
      error = problem;
    });
    if (problem != null || from == null || until == null || count == null) return;

    setState(() => searching = true);

    try {
      final found = await widget.data.findAvailable(start: from, end: until);
      if (!mounted) return;

      setState(() {
        availableIds = [
          for (final resource in found)
            if (resource.capacity >= count && !(resource.isDesk && count != 1))
              resource.id,
        ];
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  Future<void> submitBooking() async {
    if (submitting) return;

    final member = memberId;
    final resource = resourceId;
    final from = start;
    final until = end;
    final count = int.tryParse(attendees.text.trim());

    if (member == null) {
      setState(() => error = 'Select a member first.');
      return;
    }
    if (from == null || until == null || !until.isAfter(from)) {
      setState(() => error = 'Choose a valid start and end time.');
      return;
    }
    if (count == null || count < 1) {
      setState(() => error = 'Enter at least one attendee.');
      return;
    }
    if (resource == null) {
      setState(() => error = 'Search availability and select a space first.');
      return;
    }

    setState(() {
      submitting = true;
      error = null;
    });

    try {
      final booking = await widget.data.createBooking(
        memberId: member,
        resourceId: resource,
        start: from,
        end: until,
        attendees: count,
      );

      if (!mounted) return;
      setState(() {
        memberId = null;
        start = null;
        end = null;
        attendees.text = '1';
        resetSearch();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking confirmed. Total: ${booking.totalCost.toStringAsFixed(2)}',
          ),
        ),
      );
    } on ApiException catch (e) {
      // For example the 409 overlap message.
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  String formatTime(DateTime? value) {
    if (value == null) return 'Choose date and time';
    final date = MaterialLocalizations.of(context).formatShortDate(value);
    final time = TimeOfDay.fromDateTime(value).format(context);
    return '$date  $time';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.data,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('New booking')),
        body: DataGate(data: widget.data, builder: buildContent),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final members = widget.data.members;

    // The free spaces from the last search, using the current details from AppData.
    // A space that was deleted or set to OUT_OF_SERVICE since the search drops out of the list.
    final ids = availableIds;
    final List<Resource>? spaces = ids == null
        ? null
        : widget.data.resources
            .where((resource) => ids.contains(resource.id) && resource.isActive)
            .toList();

    // A dropdown must not hold a value that is no longer in its list.
    final memberValue = members.any((m) => m.id == memberId) ? memberId : null;
    final resourceValue =
        spaces != null && spaces.any((r) => r.id == resourceId) ? resourceId : null;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Member',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text('Select a member'),
                  value: memberValue,
                  items: [
                    for (final member in members)
                      DropdownMenuItem(
                        value: member.id,
                        child: Text(member.fullName),
                      ),
                  ],
                  onChanged: submitting
                      ? null
                      : (id) => setState(() => memberId = id),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Start date and time'),
              subtitle: Text(formatTime(start)),
              onTap: submitting ? null : () => pickDateTime(isStart: true),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('End date and time'),
              subtitle: Text(formatTime(end)),
              onTap: submitting ? null : () => pickDateTime(isStart: false),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: attendees,
              enabled: !submitting,
              decoration: const InputDecoration(
                labelText: 'Number of attendees',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(resetSearch),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: (submitting || searching) ? null : searchAvailability,
              child: Text(searching ? 'Searching...' : 'Search availability'),
            ),
            if (searching) const LinearProgressIndicator(),
            if (spaces != null && spaces.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No spaces available. Try a different time or group size.',
                ),
              ),
            if (spaces != null && spaces.isNotEmpty) ...[
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Available space',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    hint: const Text('Select a room or desk'),
                    value: resourceValue,
                    items: [
                      for (final resource in spaces)
                        DropdownMenuItem(
                          value: resource.id,
                          child: Text(
                            '${resource.name} • ${resource.capacity} seats',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: submitting
                        ? null
                        : (id) => setState(() => resourceId = id),
                  ),
                ),
              ),
            ],
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: submitting ? null : submitBooking,
              child: Text(submitting ? 'Booking…' : 'Confirm booking'),
            ),
            if (submitting) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
