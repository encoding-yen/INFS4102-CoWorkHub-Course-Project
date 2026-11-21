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
    // TODO(Jassem): ResourceFilterBar on top; then two sections, Meeting rooms and Desks, each a list or table;
    //               buttons for New room, New desk, Edit, Delete. OUT_OF_SERVICE should be clearly visible.
    return Scaffold(
      body: ListView(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () => openForm(newType: 'MEETING_ROOM'),
                child: const Text('New room'),
              ),
              TextButton(
                onPressed: () => openForm(newType: 'DESK'),
                child: const Text('New desk'),
              ),
            ],
          ),
          ResourceFilterBar(
            onApply: ({type, minCapacity, location, maxHourlyRate}) {
              setState(() {
                locationFilter = (location ?? '').toLowerCase();
              });
              minimumSeats = minCapacity ?? 0;
              typeFilter = type;
              priceLimit = maxHourlyRate ?? double.infinity;
            },
          ),
          for (final desksOnly in [false, true]) ...[
            ListTile(title: Text(desksOnly ? 'Desks' : 'Meeting rooms')),
            for (final resource in sampleResources.where(
              (r) =>
                  r.isDesk == desksOnly &&
                  r.location.toLowerCase().contains(locationFilter) &&
                  r.capacity >= minimumSeats &&
                  (typeFilter == null || r.type == typeFilter) &&
                  r.hourlyRate <= priceLimit,
            ))
              ListTile(
                title: Text(
                  '${resource.name} (${resource.isDesk ? "Desk" : "Meeting room"})',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(resource.status),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit resource',
                      onPressed: () => openForm(resource: resource),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete resource',
                      onPressed: () => deleteResource(resource),
                    ),
                  ],
                ),
                onTap: () => showDetails(resource),
                subtitle: Text(
                  '${resource.location} • Capacity: ${resource.capacity} • ${resource.hourlyRate.toStringAsFixed(2)}/hour',
                ),
              ),
          ],
        ],
      ),
    );
  }
}
