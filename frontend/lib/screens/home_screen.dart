// Owner: Jassem
// What: Simple entry point. AppShell provides navigation to the workflows.
// Checklist: a usable starting screen. Summary counts are optional; the brief does not require four cards.
// Depends on: ApiClient only if optional summary counts are implemented.

import 'package:material_ui/material_ui.dart';

import '../services/api_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO(Jassem): Keep this screen simple. State is only needed if implementing optional summary counts.

  @override
  void initState() {
    super.initState();
    // TODO(Jassem): Call loadSummary only if implementing the optional summary.
  }

  Future<void> loadSummary() async {
    // TODO(Jassem): Optional: load list counts and show loading/errors. Otherwise remove this unused helper.
    throw UnimplementedError('TODO(Jassem): HomeScreen.loadSummary');
  }

  @override
  Widget build(BuildContext context) {
    // TODO(Jassem): Show the app name and a short instruction to choose a workflow from the navigation.
    return const Scaffold(
      body: Center(child: Text('TODO(Jassem): Home screen with summary counts')),
    );
  }
}
