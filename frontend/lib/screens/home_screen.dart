// Owner: Jassem
// What: Dashboard. Entry point with a short summary.
// Checklist: home has navigation and a short summary, such as how many rooms, desks, members, and bookings exist;
//            loading state while counting; error message if the server cannot be reached.
// Depends on: AppData (shared data, loaded through ApiClient). The counts update whenever any screen changes data.

import 'package:material_ui/material_ui.dart';

import '../state/app_data.dart';
import '../widgets/data_gate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.data});

  final AppData data;

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
    return ListenableBuilder(
      listenable: data,
      builder: (context, _) {
        final rooms = data.resources.where((r) => !r.isDesk).length;
        final desks = data.resources.where((r) => r.isDesk).length;

        return Scaffold(
          appBar: AppBar(title: const Text('CoWorkHub Dashboard')),
          body: DataGate(
            data: data,
            builder: (context) => Align(
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
                              data.members.length,
                              Icons.people,
                              cardWidth,
                            ),
                            summaryCard(
                              'Bookings',
                              data.bookings.length,
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
          ),
        );
      },
    );
  }
}
