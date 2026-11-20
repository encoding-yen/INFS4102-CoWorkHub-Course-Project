// Owner: Jassem
// What: Create a room, create a desk, or edit an existing resource, including setting it OUT_OF_SERVICE.
// Checklist: management screens create and update a room and a desk, and can set a resource to OUT_OF_SERVICE;
//            the form stops an empty name before the request is sent; loading, success, and error states.
// Depends on: ApiClient createRoom, createDesk, updateResource (Yyan).

import 'package:material_ui/material_ui.dart';

import '../models/resource.dart';
import '../services/api_client.dart';

class ResourceFormScreen extends StatefulWidget {
  /// Pass [resource] to edit it. Otherwise pass [newType] as 'MEETING_ROOM' or 'DESK' to create one.
  const ResourceFormScreen({super.key, required this.api, this.resource, this.newType});

  final ApiClient api;
  final Resource? resource;
  final String? newType;

  @override
  State<ResourceFormScreen> createState() => _ResourceFormScreenState();
}

class _ResourceFormScreenState extends State<ResourceFormScreen> {
  // TODO(Jassem): A Form with a GlobalKey<FormState> and TextEditingControllers for
  //               name, location, capacity, hourlyRate; a status dropdown (ACTIVE / OUT_OF_SERVICE);
  //               a hasVideoConference switch for rooms or a deskType field for desks.

  String? validateRequired(String? value) {
    // TODO(Jassem): Return 'Required' when empty, otherwise null.
    throw UnimplementedError('TODO(Jassem): validateRequired');
  }

  String? validateCapacity(String? value) {
    // TODO(Jassem): Whole number of at least 1. For a desk it must be exactly 1.
    throw UnimplementedError('TODO(Jassem): validateCapacity');
  }

  String? validateHourlyRate(String? value) {
    // TODO(Jassem): A number of 0 or more.
    throw UnimplementedError('TODO(Jassem): validateHourlyRate');
  }

  Future<void> save() async {
    // TODO(Jassem): Validate the form first. Show a loading indicator, call createRoom, createDesk, or updateResource,
    //               show a success message, then Navigator.pop(context, true) so the list refreshes.
    //               On ApiException show its message and stay on the form.
    throw UnimplementedError('TODO(Jassem): ResourceFormScreen.save');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('TODO(Jassem): Room / desk form')),
    );
  }
}
