// Owner: Jassem
// What: Pick dates and times, search availability, choose member and resource, enter attendees, submit.
//       This is the screen used in the demo for the successful booking AND the rejected overlapping booking.
// Checklist: collects member, resource, start, end, and attendees; shows resources from the availability search;
//            stops an end time before the start time or an empty attendee count before sending;
//            shows the server's error message (for example the 409 overlap message) on screen;
//            shows the price of the created booking.
// Depends on: ApiClient getMembers, getAvailableResources, createBooking (Yyan).

import 'package:material_ui/material_ui.dart';

import '../services/api_client.dart';
import '../models/resource.dart';
import '../models/sample_data.dart';

class NewBookingScreen extends StatefulWidget {
  const NewBookingScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  int? memberId;
  DateTime? start;
  DateTime? end;
  final attendees = TextEditingController(text: '1');

  List<Resource>? available;
  int? resourceId;
  String? error;
  bool submitting = false;
  @override
  void dispose() {
    attendees.dispose();
    super.dispose();
  }

  void resetSearch() {
    available = null;
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

  void searchAvailability() {
    final from = start;
    final until = end;
    final count = int.tryParse(attendees.text.trim());

    setState(() {
      resetSearch();

      if (from == null || until == null) {
        error = 'Choose a start and end time.';
        return;
      }
      if (!until.isAfter(from)) {
        error = 'End time must be after start time.';
        return;
      }
      if (count == null || count < 1) {
        error = 'Enter at least one attendee using a whole number.';
        return;
      }

      available = sampleResources.where((resource) {
        if (!resource.isActive || resource.capacity < count) return false;
        if (resource.isDesk && count != 1) return false;

        final overlaps = sampleBookings.any(
          (booking) =>
              booking.resourceId == resource.id &&
              booking.status == 'CONFIRMED' &&
              booking.startDateTime.isBefore(until) &&
              booking.endDateTime.isAfter(from),
        );

        return !overlaps;
      }).toList();
    });
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
      final booking = await widget.api.createBooking(
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
      if (mounted) setState(() => error = e.message);
    } on UnimplementedError {
      if (mounted) {
        setState(() => error = 'Booking submission is not connected yet.');
      }
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
    final theme = Theme.of(context);
    final spaces = available;

    return Scaffold(
      appBar: AppBar(title: const Text('New booking')),
      body: Align(
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
                    value: memberId,
                    items: [
                      for (final member in sampleMembers)
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
                onPressed: submitting ? null : searchAvailability,
                child: const Text('Search availability'),
              ),
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
                      value: resourceId,
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
      ),
    );
  }
}
