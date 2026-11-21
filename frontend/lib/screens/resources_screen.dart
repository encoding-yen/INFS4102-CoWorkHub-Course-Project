// Owner: Jassem
// What: List of rooms and desks with filters, edit, delete, and create.
// Checklist: shows name, type, location, capacity, hourly rate, ACTIVE/OUT_OF_SERVICE;
//            can filter; required details are visible in the list or form;
//            deleting a resource that has bookings shows the server's 409 message;
//            loading, success, and error states; list refreshes after create, update, or delete.
// Depends on: ApiClient getResources, deleteResource (Yyan); ResourceFormScreen; ResourceFilterBar.
//             Use sampleResources until ApiClient works.

import 'package:material_ui/material_ui.dart';

import '../models/resource.dart';
import '../services/api_client.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  // TODO(Jassem): Hold loading / error / resources / current filters in state.

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
    // TODO(Jassem): Optional details dialog. If the list/form already shows the fields, remove this unused helper.
    throw UnimplementedError('TODO(Jassem): ResourcesScreen.showDetails');
  }

  Future<void> openForm({Resource? resource, String? newType}) async {
    // TODO(Jassem): Push ResourceFormScreen (create a room, create a desk, or edit). Reload when it returns true.
    throw UnimplementedError('TODO(Jassem): ResourcesScreen.openForm');
  }

  Future<void> deleteResource(Resource resource) async {
    // TODO(Jassem): Call widget.api.deleteResource, show success and reload. A confirmation dialog is optional.
    //               On ApiException show its message, for example the 409 "has bookings" message.
    throw UnimplementedError('TODO(Jassem): ResourcesScreen.deleteResource');
  }

  @override
  Widget build(BuildContext context) {
    // TODO(Jassem): Show filters and one list/table with the required fields, including type and status.
    //               Add New room, New desk, Edit, and Delete actions. Separate subtype sections are unnecessary.
    return const Scaffold(
      body: Center(child: Text('TODO(Jassem): Resources screen')),
    );
  }
}
