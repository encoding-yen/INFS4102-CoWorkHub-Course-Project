// Owner: Jassem
// What: Every booking, current and past, with status and total cost. Edit or cancel from here.
// Checklist: shows current and past bookings, including cancelled ones, with status and total cost;
//            a booking can be edited and cancelled from this screen;
//            loading, success, and error states; list refreshes after edit or cancel.
// Depends on: ApiClient getBookings, cancelBooking (Yyan); BookingEditScreen. Use sampleBookings until ApiClient works.

import 'package:material_ui/material_ui.dart';

import '../models/booking.dart';
import '../services/api_client.dart';

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
    // TODO(Jassem): Push BookingEditScreen. Reload when it returns true. Do not allow editing a CANCELLED booking.
    throw UnimplementedError('TODO(Jassem): BookingsScreen.editBooking');
  }

  Future<void> cancelBooking(Booking booking) async {
    // TODO(Jassem): Confirm, call widget.api.cancelBooking(booking.id), show success, reload.
    //               The cancelled booking must still appear in the list with status CANCELLED.
    throw UnimplementedError('TODO(Jassem): BookingsScreen.cancelBooking');
  }

  @override
  Widget build(BuildContext context) {
    // TODO(Jassem): A table with member, resource, start, end, attendees, status, total cost, Edit and Cancel.
    //               Separate or mark current vs past (Booking.isPast) and cancelled bookings.
    return const Scaffold(
      body: Center(child: Text('TODO(Jassem): Bookings screen')),
    );
  }
}
