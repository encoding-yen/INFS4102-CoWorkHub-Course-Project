// Owner: Jassem
// What: Every booking, current and past, with status and total cost. Edit or cancel from here.
// Checklist: shows current and past bookings, including cancelled ones, with status and total cost;
//            a booking can be edited and cancelled from this screen;
//            loading, success, and error states; list refreshes after edit or cancel.
// Depends on: ApiClient getBookings, cancelBooking (Yyan); BookingEditScreen.

import 'package:material_ui/material_ui.dart';

import '../models/booking.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../services/api_client.dart';
import 'booking_edit_screen.dart';
import '../widgets/feedback.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<Booking> bookings = [];
  bool loading = true;
  String? loadError;
  int requestId = 0;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    final request = ++requestId;
    setState(() {
      loading = true;
      loadError = null;
    });
    try {
      final result = await widget.api.getBookings();
      if (!mounted || request != requestId) return;
      setState(() {
        bookings = result;
      });
    } catch (e) {
      if (mounted && request == requestId) setState(() => loadError = e.toString());
    } finally {
      if (mounted && request == requestId) setState(() => loading = false);
    }
  }

  Future<void> editBooking(Booking booking) async {
    if (booking.isCancelled) return;

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BookingEditScreen(api: widget.api, booking: booking),
      ),
    );

    if (mounted && saved == true) {
      await loadBookings();
    }
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

    setState(() => loading = true);
    try {
      await widget.api.cancelBooking(booking.id);
      if (!mounted) return;
      showSuccess(context, 'Booking cancelled');
    } catch (e) {
      if (!mounted) return;
      showError(context, e.toString());
    }
    await loadBookings();
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
    if (loading || loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bookings')),
        body: loading
            ? const LoadingView()
            : ErrorView(message: loadError!, onRetry: loadBookings),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: ListView(
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
      ),
    );
  }
}
