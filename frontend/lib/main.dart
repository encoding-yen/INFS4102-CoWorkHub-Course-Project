// Owner: Jassem
// What: App entry point and the main desktop window with navigation.
// Checklist: home has navigation; ordinary Flutter desktop widgets; no operating-system-specific code.
// Depends on: every screen (Jassem), ApiClient (Yyan, signatures done).
//
// One ApiClient is created here and passed to every screen, so all HTTP calls go through Yyan's class.

import 'package:material_ui/material_ui.dart';

import 'screens/home_screen.dart';
import 'services/api_client.dart';
import 'screens/resources_screen.dart';
import 'screens/members_screen.dart';
import 'screens/new_booking_screen.dart';
import 'screens/bookings_screen.dart';

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
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // TODO(Jassem): Add simple navigation, such as buttons or tabs, to select a screen.
    //               Destinations: Home, Resources, Members, New booking, Bookings.
    //               Screens: HomeScreen, ResourcesScreen, MembersScreen, NewBookingScreen, BookingsScreen.
    //               Pass widget.api to each one.
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
              HomeScreen(api: widget.api),
              ResourcesScreen(api: widget.api),
              MembersScreen(api: widget.api),
              NewBookingScreen(api: widget.api),
              BookingsScreen(api: widget.api),
            ][selectedIndex],
          ),
        ],
      ),
    );
  }
}
