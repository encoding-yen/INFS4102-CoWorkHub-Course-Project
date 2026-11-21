// Owner: Jassem
// What: Dashboard. Entry point with a short summary.
// Checklist: home has navigation and a short summary, such as how many rooms, desks, members, and bookings exist;
//            loading state while counting; error message if the server cannot be reached.
// Depends on: ApiClient getResources, getMembers, getBookings (Yyan).

import 'package:material_ui/material_ui.dart';

import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../services/api_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int rooms = 0, desks = 0, members = 0, bookings = 0;
  bool loading = true;
  String? loadError;
  int requestId = 0;

  @override
  void initState() {
    super.initState();
    loadSummary();
  }

  Future<void> loadSummary() async {
    final request = ++requestId;
    setState(() {
      loading = true;
      loadError = null;
    });
    try {
      final api = widget.api;
      final resources = await api.getResources();
      final people = await api.getMembers();
      final reservations = await api.getBookings();
      if (!mounted || request != requestId) return;
      setState(() {
        desks = resources.where((r) => r.isDesk).length;
        rooms = resources.length - desks;
        members = people.length;
        bookings = reservations.length;
      });
    } catch (e) {
      if (mounted && request == requestId) setState(() => loadError = e.toString());
    } finally {
      if (mounted && request == requestId) setState(() => loading = false);
    }
  }

  Widget summaryCard(String label, int count, IconData icon, double width) {
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon),
          title: Text(label),
          subtitle: Text('$count'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading || loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('CoWorkHub Dashboard')),
        body: loading
            ? const LoadingView()
            : ErrorView(message: loadError!, onRetry: loadSummary),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('CoWorkHub Dashboard')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final cardWidth = width >= 440 ? (width - 12) / 2 : width;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      summaryCard(
                        'Meeting rooms',
                        rooms,
                        Icons.business,
                        cardWidth,
                      ),
                      summaryCard('Desks', desks, Icons.computer, cardWidth),
                      summaryCard(
                        'Members',
                        members,
                        Icons.people,
                        cardWidth,
                      ),
                      summaryCard(
                        'Bookings',
                        bookings,
                        Icons.event,
                        cardWidth,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
