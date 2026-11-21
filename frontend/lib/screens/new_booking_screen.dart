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

class NewBookingScreen extends StatefulWidget {
  const NewBookingScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  // TODO(Jassem): State for selected start and end (showDatePicker + showTimePicker), members list,
  //               available resources, selected member, selected resource, attendees controller,
  //               loading and error.

  @override
  void initState() {
    super.initState();
    // TODO(Jassem): Load members for the member dropdown.
  }

  Future<void> searchAvailability() async {
    // TODO(Jassem): Check end is after start first. Then await widget.api.getAvailableResources(start:, end:)
    //               and show the results to pick from.
    throw UnimplementedError('TODO(Jassem): NewBookingScreen.searchAvailability');
  }

  String? validateAttendees(String? value) {
    // TODO(Jassem): Required, whole number, at least 1. A desk can only take 1.
    //               The server checks this again; this check only avoids obviously invalid requests.
    throw UnimplementedError('TODO(Jassem): validateAttendees');
  }

  Future<void> submit() async {
    // TODO(Jassem): Validate, show loading, call widget.api.createBooking.
    //   Success: show "Booking confirmed, total 60.00" using the returned totalCost, then reset the form.
    //   ApiException: show exception.message clearly. The instructor will try an overlapping booking here.
    throw UnimplementedError('TODO(Jassem): NewBookingScreen.submit');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('TODO(Jassem): New booking screen with availability search')),
    );
  }
}
