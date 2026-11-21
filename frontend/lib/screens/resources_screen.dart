// Owner: Jassem
// What: List of rooms and desks with filters, details, edit, delete, and create.
// Checklist: separates rooms and desks; shows name, type, location, capacity, hourly rate, ACTIVE/OUT_OF_SERVICE;
//            can filter; a resource can be opened to see its details;
//            deleting a resource that has bookings shows the server's 409 message;
//            loading, success, and error states; list refreshes after create, update, or delete.
// Depends on: ApiClient getResources, deleteResource (Yyan); ResourceFormScreen; ResourceFilterBar.
//             Use sampleResources until ApiClient works.

import 'package:material_ui/material_ui.dart';

import '../models/resource.dart';
import '../models/sample_data.dart';
import '../widgets/resource_filter_bar.dart';
import '../services/api_client.dart';
import 'resource_form_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  // TODO(Jassem): Hold loading / error / resources / current filters in state.
  String locationFilter = '';
  String? typeFilter;
  int minimumSeats = 0;
  double priceLimit = double.infinity;

  @override
  void initState() {
    super.initState();
    // TODO(Jassem): Call loadResources().
  }

  Future<void> loadResources() async {
    // TODO(Jassem): await widget.api.getResources(...current filters...), then setState.
    throw UnimplementedError('TODO(Jassem): ResourcesScreen.loadResources');
  }

  void showDetails(Resource resource) {
    // TODO(Jassem): Open a dialog or side panel with every field, including hasVideoConference or deskType.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(resource.name),
        content: Text(
          'Type: ${resource.isDesk ? "Desk" : "Meeting room"}\n'
          'Location: ${resource.location}\n'
          'Capacity: ${resource.capacity}\n'
          'Hourly rate: ${resource.hourlyRate.toStringAsFixed(2)}\n'
          'Status: ${resource.status}\n'
          '${resource.isDesk ? "Desk type: ${resource.deskType ?? 'Unknown'}" : "Video conferencing: ${resource.hasVideoConference == true ? 'Yes' : 'No'}"}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> openForm({Resource? resource, String? newType}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ResourceFormScreen(
          api: widget.api,
          resource: resource,
          newType: newType,
        ),
      ),
    );

    if (mounted && saved == true) {
      setState(() {});
    }
  }

  Future<void> deleteResource(Resource resource) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${resource.name}?'),
        content: const Text('This will remove the resource from the list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep resource'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final hasBookings = sampleBookings.any(
      (booking) => booking.resourceId == resource.id,
    );

    if (hasBookings) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${resource.name} has bookings and cannot be deleted.'),
        ),
      );
      return;
    }

    setState(() {
      sampleResources.removeWhere((item) => item.id == resource.id);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${resource.name} deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matches = sampleResources.where((resource) {
      return resource.location.toLowerCase().contains(locationFilter) &&
          resource.capacity >= minimumSeats &&
          resource.hourlyRate <= priceLimit &&
          (typeFilter == null || resource.type == typeFilter);
    }).toList();

    final rooms = matches.where((r) => !r.isDesk).toList();
    final desks = matches.where((r) => r.isDesk).toList();

    Widget resourceCard(Resource resource) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(resource.name, style: theme.textTheme.titleMedium),
              Text(
                '${resource.isDesk ? "Desk" : "Meeting room"} • ${resource.location}',
              ),
              const SizedBox(height: 8),
              Text('Capacity: ${resource.capacity}'),
              Text('Hourly rate: ${resource.hourlyRate.toStringAsFixed(2)}'),
              Text(
                'Status: ${resource.isActive ? "Active" : "Out of service"}',
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => showDetails(resource),
                    child: const Text('View details'),
                  ),
                  TextButton(
                    onPressed: () => openForm(resource: resource),
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: () => deleteResource(resource),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () => openForm(newType: 'MEETING_ROOM'),
                    child: const Text('New room'),
                  ),
                  OutlinedButton(
                    onPressed: () => openForm(newType: 'DESK'),
                    child: const Text('New desk'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ResourceFilterBar(
                onApply: ({type, minCapacity, location, maxHourlyRate}) {
                  setState(() {
                    typeFilter = type;
                    locationFilter = (location ?? '').toLowerCase();
                    minimumSeats = minCapacity ?? 0;
                    priceLimit = maxHourlyRate ?? double.infinity;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (sampleResources.isEmpty)
                const ListTile(
                  title: Text('No resources yet'),
                  subtitle: Text('Choose New room or New desk to add one.'),
                )
              else if (matches.isEmpty)
                const ListTile(
                  title: Text('No matching resources'),
                  subtitle: Text(
                    'Change your filters or select Clear to see all resources.',
                  ),
                ),
              if (rooms.isNotEmpty) ...[
                Text(
                  'Meeting rooms (${rooms.length})',
                  style: theme.textTheme.titleMedium,
                ),
                for (final room in rooms) resourceCard(room),
              ],
              if (desks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Desks (${desks.length})',
                  style: theme.textTheme.titleMedium,
                ),
                for (final desk in desks) resourceCard(desk),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
