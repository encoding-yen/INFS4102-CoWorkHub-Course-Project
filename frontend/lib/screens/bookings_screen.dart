// Owner: Jassem
// What: Every booking, current and past, with status and total cost. Edit or cancel from here.
// Checklist: shows current and past bookings, including cancelled ones, with status and total cost;
//            a booking can be edited and cancelled from this screen;
//            loading, success, and error states; list refreshes after edit or cancel.
// Depends on: ApiClient getBookings, cancelBooking (Yyan); BookingEditScreen. Use sampleBookings until ApiClient works.

import 'package:material_ui/material_ui.dart';

import '../models/booking.dart';
import '../models/sample_data.dart';
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
  // TODO(Jassem): Hold loading / error / bookings in state.

  @override
  void initState() {
    super.initState();
    // TODO(Jassem): Call loadBookings().
  }

  Future<void> loadBookings() async {
    // TODO(Jassem): await widget.api.getBookings(), then setState.
    throw UnimplementedError('TODO(Jassem): BookingsScreen.loadBookings');
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
      setState(() {});
    }
  }

  Future<void> cancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: Text('Cancel the booking for ${booking.resourceName}?'),
        actions: [
          TextButton(
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

    final index = sampleBookings.indexWhere((item) => item.id == booking.id);
    if (index == -1) return;

    setState(() {
      sampleBookings[index] = Booking(
        id: booking.id,
        memberId: booking.memberId,
        memberName: booking.memberName,
        resourceId: booking.resourceId,
        resourceName: booking.resourceName,
        startDateTime: booking.startDateTime,
        endDateTime: booking.endDateTime,
        attendees: booking.attendees,
        status: 'CANCELLED',
        totalCost: booking.totalCost,
      );
    });

    showSuccess(context, 'Booking cancelled');
  }

  @override
  Widget build(BuildContext context) {
    // TODO(Jassem): A table with member, resource, start, end, attendees, status, total cost, Edit and Cancel.
    //               Separate or mark current vs past (Booking.isPast) and cancelled bookings.
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: ListView(
        children: [
          if (sampleBookings.isEmpty)
            const ListTile(title: Text('No bookings yet')),
          for (final booking in sampleBookings)
            ListTile(
              title: Text('${booking.resourceName} • ${booking.memberName}'),
              subtitle: Text(
                '${booking.startDateTime} → ${booking.endDateTime}\n'
                'Attendees: ${booking.attendees} • ${booking.status} • '
                '${booking.isPast ? "Past" : "Current or upcoming"}',
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total: ${booking.totalCost.toStringAsFixed(2)}'),
                  TextButton(
                    onPressed: booking.isCancelled
                        ? null
                        : () => cancelBooking(booking),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: booking.isCancelled
                        ? null
                        : () => editBooking(booking),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
