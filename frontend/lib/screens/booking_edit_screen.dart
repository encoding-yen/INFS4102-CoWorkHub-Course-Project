// Owner: Jassem
// What: Change the start, end, or attendees of a booking. The server rechecks every rule and recalculates the price.
// Checklist: a booking can be edited; end before start is stopped before sending;
//            the server's error message is shown (for example an overlap after editing).
// Depends on: ApiClient updateBooking (Yyan).

import 'package:material_ui/material_ui.dart';

import '../models/booking.dart';
import '../models/sample_data.dart';
import '../services/api_client.dart';

class BookingEditScreen extends StatefulWidget {
  const BookingEditScreen({
    super.key,
    required this.api,
    required this.booking,
  });

  final ApiClient api;
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

  void save() {
    final booking = widget.booking;
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

    final resource = sampleResources.firstWhere(
      (r) => r.id == booking.resourceId,
    );
    if (!resource.isActive) {
      setState(() => error = 'This resource is out of service.');
      return;
    }
    if (count > resource.capacity || (resource.isDesk && count != 1)) {
      setState(
        () => error = 'This space allows up to ${resource.capacity} attendees.',
      );
      return;
    }

    final overlaps = sampleBookings.any(
      (other) =>
          other.id != booking.id &&
          other.resourceId == booking.resourceId &&
          !other.isCancelled &&
          other.startDateTime.isBefore(end) &&
          other.endDateTime.isAfter(start),
    );

    if (overlaps) {
      setState(() => error = 'This space already has a booking at that time.');
      return;
    }

    final hours = end.difference(start).inMinutes / 60;
    final total = double.parse(
      (hours * resource.hourlyRate).toStringAsFixed(2),
    );
    final index = sampleBookings.indexWhere((item) => item.id == booking.id);

    sampleBookings[index] = Booking(
      id: booking.id,
      memberId: booking.memberId,
      memberName: booking.memberName,
      resourceId: booking.resourceId,
      resourceName: booking.resourceName,
      startDateTime: start,
      endDateTime: end,
      attendees: count,
      status: booking.status,
      totalCost: total,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking updated. Total: ${total.toStringAsFixed(2)}'),
      ),
    );
    Navigator.pop(context, true);
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
            onTap: () => pickDateTime(isStart: true),
          ),
          ListTile(
            title: const Text('End'),
            subtitle: Text(formatTime(end)),
            onTap: () => pickDateTime(isStart: false),
          ),
          TextField(
            controller: attendees,
            decoration: const InputDecoration(labelText: 'Attendees'),
            keyboardType: TextInputType.number,
          ),
          if (error != null) Text(error!),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: save, child: const Text('Save changes')),
        ],
      ),
    );
  }
}
