// Owner: Jassem
// What: Dashboard. Entry point with a short summary.
// Checklist: home has navigation and a short summary, such as how many rooms, desks, members, and bookings exist;
//            loading state while counting; error message if the server cannot be reached.
// Depends on: ApiClient getResources, getMembers, getBookings (Yyan). Use sample_data.dart until those work.

import 'package:material_ui/material_ui.dart';

import '../services/api_client.dart';

import '../models/sample_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO(Jassem): Hold loading / error / counts in state.

  @override
  void initState() {
    super.initState();
    // TODO(Jassem): Call loadSummary().
  }

  Future<void> loadSummary() async {
    // TODO(Jassem): await the three ApiClient lists, count rooms, desks, members, and bookings, then setState.
    //               Catch ApiException and show its message with ErrorView.
    throw UnimplementedError('TODO(Jassem): HomeScreen.loadSummary');
  }

  @override
  Widget build(BuildContext context) {
    // TODO(Jassem): Show LoadingView, ErrorView, or four summary cards.
        final roomCount = sampleResources.where((r) => r.type == 'MEETING_ROOM').length;
        final deskCount = sampleResources.where((r) => r.type == 'DESK').length;

    return Scaffold(
      body: Center(child: Text('CoWorkHub Dashboard\nMeeting rooms: $roomCount\nDesks: $deskCount\nMembers: ${sampleMembers.length}\nBookings: ${sampleBookings.length}')),
    );
  }
}
