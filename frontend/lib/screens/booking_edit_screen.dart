// Owner: Jassem
// What: Change the start, end, or attendees of a booking. The server rechecks every rule and recalculates the price.
// Checklist: a booking can be edited; end before start is stopped before sending;
//            the server's error message is shown (for example an overlap after editing).
// Depends on: ApiClient updateBooking (Yyan).

import 'package:material_ui/material_ui.dart';

import '../models/booking.dart';
import '../services/api_client.dart';

class BookingEditScreen extends StatefulWidget {
  const BookingEditScreen({super.key, required this.api, required this.booking});

  final ApiClient api;
  final Booking booking;

  @override
  State<BookingEditScreen> createState() => _BookingEditScreenState();
}

class _BookingEditScreenState extends State<BookingEditScreen> {
  // TODO(Jassem): State for start, end, and attendees, starting from widget.booking.

  Future<void> save() async {
    // TODO(Jassem): Check end is after start and attendees >= 1. Show loading, call widget.api.updateBooking,
    //               show the new total cost, Navigator.pop(context, true). On ApiException show its message.
    throw UnimplementedError('TODO(Jassem): BookingEditScreen.save');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('TODO(Jassem): Edit booking')),
    );
  }
}
