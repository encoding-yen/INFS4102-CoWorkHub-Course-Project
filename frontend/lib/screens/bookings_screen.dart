// Owner: Jassem
// What: Every booking, current and past, with status and total cost. Edit or cancel from here.
// Checklist: shows current and past bookings, including cancelled ones, with status and total cost;
//            a booking can be edited and cancelled from this screen;
//            loading, success, and error states; list refreshes after edit or cancel.
// Depends on: AppData (shared data, loaded through ApiClient); BookingEditScreen.
//             Bookings come from AppData, so a booking made on the New booking screen appears here at once,
//             and a renamed member or resource shows its new name.

import 'package:material_ui/material_ui.dart';

import '../models/booking.dart';
import '../services/api_client.dart';
import '../state/app_data.dart';
import '../widgets/data_gate.dart';
import '../widgets/feedback.dart';
import 'booking_edit_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key, required this.data});

  final AppData data;

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  Future<void> editBooking(Booking booking) async {
    if (booking.isCancelled) return;

    // The edit screen saves through AppData, which updates every screen. Nothing else to do here.
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BookingEditScreen(data: widget.data, booking: booking),
      ),
    );
  }

  Future<void> cancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: Text(
          '${booking.resourceName} • ${booking.memberName}\n'
          '${formatBookingTime(booking)}\n\n'
          'The booking will stay in the list as cancelled.',
        ),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep booking'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await widget.data.cancelBooking(booking.id);
      if (mounted) showSuccess(context, 'Booking cancelled');
    } on ApiException catch (e) {
      if (mounted) showError(context, e.message);
    }
  }

  String formatBookingTime(Booking booking) {
    final start = booking.startDateTime;
    final end = booking.endDateTime;
    final dates = MaterialLocalizations.of(context);

    final startDate = dates.formatShortDate(start);
    final startTime = TimeOfDay.fromDateTime(start).format(context);
    final endTime = TimeOfDay.fromDateTime(end).format(context);

    if (DateUtils.isSameDay(start, end)) {
      return '$startDate · $startTime–$endTime';
    }

    return '$startDate · $startTime → ${dates.formatShortDate(end)} · $endTime';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.data,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Bookings')),
        body: DataGate(data: widget.data, builder: buildContent),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    final bookings = widget.data.bookings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (bookings.isEmpty)
          const ListTile(
            leading: Icon(Icons.event),
            title: Text('No bookings yet'),
            subtitle: Text(
              'Select New booking in the sidebar to book a room or desk.',
            ),
          ),
        for (final booking in bookings)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.resourceName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('Member: ${booking.memberName}'),
                  const SizedBox(height: 8),
                  Text(formatBookingTime(booking)),
                  Text('Attendees: ${booking.attendees}'),
                  Text(
                    'Status: ${booking.isCancelled ? "Cancelled" : "Confirmed"}',
                  ),
                  Text(
                    'Schedule: ${booking.isPast ? "Past" : "Current or upcoming"}',
                  ),
                  const SizedBox(height: 8),
                  Text('Total: ${booking.totalCost.toStringAsFixed(2)}'),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: booking.isCancelled
                            ? null
                            : () => editBooking(booking),
                        child: const Text('Edit booking'),
                      ),
                      TextButton(
                        onPressed: booking.isCancelled
                            ? null
                            : () => cancelBooking(booking),
                        child: const Text('Cancel booking'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
