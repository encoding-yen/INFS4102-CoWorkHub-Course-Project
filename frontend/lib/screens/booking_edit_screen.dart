// Owner: Jassem
// What: Change the start, end, or attendees of a booking. The server rechecks every rule and recalculates the price.
// Checklist: a booking can be edited; end before start is stopped before sending;
//            the server's error message is shown (for example an overlap after editing).
// Depends on: AppData (saves through ApiClient updateBooking, then updates every screen).

import 'package:material_ui/material_ui.dart';

import '../models/booking.dart';
import '../services/api_client.dart';
import '../state/app_data.dart';

class BookingEditScreen extends StatefulWidget {
  const BookingEditScreen({
    super.key,
    required this.data,
    required this.booking,
  });

  final AppData data;
  final Booking booking;

  @override
  State<BookingEditScreen> createState() => _BookingEditScreenState();
}

class _BookingEditScreenState extends State<BookingEditScreen> {
  late DateTime start = widget.booking.startDateTime;
  late DateTime end = widget.booking.endDateTime;
  late final attendees = TextEditingController(
    text: widget.booking.attendees.toString(),
  );
  String? error;
  bool saving = false;

  @override
  void dispose() {
    attendees.dispose();
    super.dispose();
  }

  Future<void> pickDateTime({required bool isStart}) async {
    final current = isStart ? start : end;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
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
      error = null;
    });
  }

  String formatTime(DateTime value) {
    final date = MaterialLocalizations.of(context).formatShortDate(value);
    final time = TimeOfDay.fromDateTime(value).format(context);
    return '$date  $time';
  }

  Future<void> save() async {
    if (saving) return;

    final count = int.tryParse(attendees.text.trim());

    if (!end.isAfter(start)) {
      setState(() => error = 'End time must be after start time.');
      return;
    }
    if (count == null || count < 1) {
      setState(
        () => error = 'Enter at least one attendee using a whole number.',
      );
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    try {
      // The server checks the capacity, out-of-service, and overlap rules and recalculates the price.
      final updated = await widget.data.updateBooking(
        widget.booking.id,
        start: start,
        end: end,
        attendees: count,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking updated. Total: ${updated.totalCost.toStringAsFixed(2)}',
          ),
        ),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      // For example the 409 overlap message.
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit booking')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('${widget.booking.resourceName} • ${widget.booking.memberName}'),
          ListTile(
            title: const Text('Start'),
            subtitle: Text(formatTime(start)),
            onTap: saving ? null : () => pickDateTime(isStart: true),
          ),
          ListTile(
            title: const Text('End'),
            subtitle: Text(formatTime(end)),
            onTap: saving ? null : () => pickDateTime(isStart: false),
          ),
          TextField(
            controller: attendees,
            enabled: !saving,
            decoration: const InputDecoration(labelText: 'Attendees'),
            keyboardType: TextInputType.number,
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
            child: Text(saving ? 'Saving...' : 'Save changes'),
          ),
          if (saving) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
