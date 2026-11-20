// Owner: Jassem
// What: App entry point and the main desktop window with navigation.
// Checklist: home has navigation; ordinary Flutter desktop widgets; no operating-system-specific code.
// Depends on: every screen (Jassem), ApiClient (Yyan, signatures done).
//
// One ApiClient is created here and passed to every screen, so all HTTP calls go through Yyan's class.

import 'package:material_ui/material_ui.dart';

import 'screens/home_screen.dart';
import 'services/api_client.dart';

void main() {
  runApp(CoWorkHubApp(api: ApiClient()));
}

class CoWorkHubApp extends StatelessWidget {
  const CoWorkHubApp({super.key, required this.api});

  final ApiClient api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoWorkHub',
      debugShowCheckedModeBanner: false,
      home: AppShell(api: api),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.api});

  final ApiClient api;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    // TODO(Jassem): Replace with a Scaffold that has a NavigationRail on the left and the selected screen on the right.
    //               Destinations: Home, Resources, Members, New booking, Bookings.
    //               Screens: HomeScreen, ResourcesScreen, MembersScreen, NewBookingScreen, BookingsScreen.
    //               Pass widget.api to each one.
    return HomeScreen(api: widget.api);
  }
}
