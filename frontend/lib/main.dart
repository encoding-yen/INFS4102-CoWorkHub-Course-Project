// Owner: Jassem
// What: App entry point and the main desktop window with navigation.
// Checklist: home has navigation; ordinary Flutter desktop widgets; no operating-system-specific code.
// Depends on: every screen (Jassem), ApiClient (Yyan), AppData (shared data for every screen).
//
// One ApiClient is created here and wrapped in one AppData. Every screen receives that same AppData,
// so all HTTP calls go through ApiClient and every screen shows the same, current data.

import 'package:material_ui/material_ui.dart';

import 'screens/home_screen.dart';
import 'screens/resources_screen.dart';
import 'screens/members_screen.dart';
import 'screens/new_booking_screen.dart';
import 'screens/bookings_screen.dart';
import 'services/api_client.dart';
import 'state/app_data.dart';

void main() {
  final data = AppData(ApiClient());
  data.refresh(); // Load members, resources, and bookings once at start-up.
  runApp(CoWorkHubApp(data: data));
}

class CoWorkHubApp extends StatelessWidget {
  const CoWorkHubApp({super.key, required this.data});

  final AppData data;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoWorkHub',
      debugShowCheckedModeBanner: false,
      home: AppShell(data: data),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.data});

  final AppData data;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            labelType: MediaQuery.sizeOf(context).width < 500
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business),
                label: Text('Resources'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Members'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add),
                label: Text('New booking'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.event),
                label: Text('Bookings'),
              ),
            ],
          ),
          Expanded(
            child: [
              HomeScreen(data: widget.data),
              ResourcesScreen(data: widget.data),
              MembersScreen(data: widget.data),
              NewBookingScreen(data: widget.data),
              BookingsScreen(data: widget.data),
            ][selectedIndex],
          ),
        ],
      ),
    );
  }
}
