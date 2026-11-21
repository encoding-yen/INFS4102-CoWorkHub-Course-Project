// Owner: Jassem
// What: Dashboard. Entry point with a short summary.
// Checklist: home has navigation and a short summary, such as how many rooms, desks, members, and bookings exist;
//            loading state while counting; error message if the server cannot be reached.
// Depends on: ApiClient getResources, getMembers, getBookings (Yyan). Use sample_data.dart until those work.

import 'package:material_ui/material_ui.dart';

import '../models/sample_data.dart';
import '../services/api_client.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.api});

  final ApiClient api;

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
    final rooms = sampleResources.where((r) => !r.isDesk).length;
    final desks = sampleResources.where((r) => r.isDesk).length;

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
                        sampleMembers.length,
                        Icons.people,
                        cardWidth,
                      ),
                      summaryCard(
                        'Bookings',
                        sampleBookings.length,
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
