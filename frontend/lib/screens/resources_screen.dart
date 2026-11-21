// Owner: Jassem
// What: List of rooms and desks with filters, details, edit, delete, and create.
// Checklist: separates rooms and desks; shows name, type, location, capacity, hourly rate, ACTIVE/OUT_OF_SERVICE;
//            can filter; a resource can be opened to see its details;
//            deleting a resource that has bookings shows the server's 409 message;
//            loading, success, and error states; list refreshes after create, update, or delete.
// Depends on: ApiClient getResources, deleteResource (Yyan); ResourceFormScreen; ResourceFilterBar.

import 'package:material_ui/material_ui.dart';

import '../models/resource.dart';
import '../widgets/resource_filter_bar.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/feedback.dart';
import '../services/api_client.dart';
import 'resource_form_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  String? locationFilter;
  String? typeFilter;
  int? minimumSeats;
  double? priceLimit;
  List<Resource> resources = [];
  bool loading = true;
  String? loadError;
  int requestId = 0;

  @override
  void initState() {
    super.initState();
    loadResources();
  }

  Future<void> loadResources() async {
    final request = ++requestId;
    setState(() {
      loading = true;
      loadError = null;
    });
    try {
      final result = await widget.api.getResources(
        type: typeFilter, location: locationFilter,
        minCapacity: minimumSeats, maxHourlyRate: priceLimit,
      );
      if (!mounted || request != requestId) return;
      setState(() {
        resources = result;
      });
    } catch (e) {
      if (mounted && request == requestId) setState(() => loadError = e.toString());
    } finally {
      if (mounted && request == requestId) setState(() => loading = false);
    }
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
      showSuccess(context, 'Resource saved');
      await loadResources();
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

    setState(() => loading = true);
    try {
      await widget.api.deleteResource(resource.id);
      if (!mounted) return;
      showSuccess(context, '${resource.name} deleted');
    } catch (e) {
      if (!mounted) return;
      showError(context, e.toString());
    }
    await loadResources();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rooms = resources.where((r) => !r.isDesk);
    final desks = resources.where((r) => r.isDesk);

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
                  typeFilter = type;
                  locationFilter = location;
                  minimumSeats = minCapacity;
                  priceLimit = maxHourlyRate;
                  loadResources();
                },
              ),
              const SizedBox(height: 16),
              if (loading)
                const LoadingView()
              else if (loadError != null)
                ErrorView(message: loadError!, onRetry: loadResources)
              else if (resources.isEmpty)
                const ListTile(title: Text('No resources match this search.')),
              if (!loading && loadError == null && rooms.isNotEmpty) ...[
                Text(
                  'Meeting rooms (${rooms.length})',
                  style: theme.textTheme.titleMedium,
                ),
                for (final room in rooms) resourceCard(room),
              ],
              if (!loading && loadError == null && desks.isNotEmpty) ...[
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
