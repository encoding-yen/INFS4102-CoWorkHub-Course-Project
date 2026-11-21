// Owner: Jassem
// What: Create a room, create a desk, or edit an existing resource, including setting it OUT_OF_SERVICE.
// Checklist: management screens create and update a room and a desk, and can set a resource to OUT_OF_SERVICE;
//            the form stops an empty name before the request is sent; loading, success, and error states.
// Depends on: ApiClient createRoom, createDesk, updateResource (Yyan).

import 'package:material_ui/material_ui.dart';

import '../models/resource.dart';
import '../services/api_client.dart';

class ResourceFormScreen extends StatefulWidget {
  const ResourceFormScreen({
    super.key,
    required this.api,
    this.resource,
    this.newType,
  });

  final ApiClient api;
  final Resource? resource;
  final String? newType;

  @override
  State<ResourceFormScreen> createState() => _ResourceFormScreenState();
}

class _ResourceFormScreenState extends State<ResourceFormScreen> {
  final formKey = GlobalKey<FormState>();

  late final original = widget.resource;
  late final type = original?.type ?? widget.newType!;
  bool get isDesk => type == 'DESK';

  late String name = original?.name ?? '';
  late String location = original?.location ?? '';
  late String capacity = original?.capacity.toString() ?? '1';
  late String rate = original?.hourlyRate.toString() ?? '';
  late String status = original?.status ?? 'ACTIVE';
  late String deskType = original?.deskType ?? '';
  late bool video = original?.hasVideoConference ?? false;

  String? requiredText(String? value) {
    return (value ?? '').trim().isEmpty ? 'Required' : null;
  }

  bool saving = false;
  String? error;

  Future<void> save() async {
    if (saving || !formKey.currentState!.validate()) return;

    setState(() {
      saving = true;
      error = null;
    });
    try {
      final id = original?.id;
      final seats = int.parse(capacity.trim());
      final price = double.parse(rate.trim());
      if (id != null) {
        await widget.api.updateResource(
          id, name: name, location: location, capacity: seats, hourlyRate: price,
          status: status, deskType: isDesk ? deskType : null,
          hasVideoConference: isDesk ? null : video,
        );
      } else if (isDesk) {
        await widget.api.createDesk(
          name: name, location: location, hourlyRate: price,
          deskType: deskType, status: status,
        );
      } else {
        await widget.api.createRoom(
          name: name, location: location, capacity: seats, hourlyRate: price,
          hasVideoConference: video, status: status,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = original == null ? 'New' : 'Edit';
    final kind = isDesk ? 'desk' : 'room';

    return Scaffold(
      appBar: AppBar(title: Text('$action $kind')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              initialValue: name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: requiredText,
              onChanged: (value) => name = value,
            ),
            TextFormField(
              initialValue: location,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: requiredText,
              onChanged: (value) => location = value,
            ),
            TextFormField(
              initialValue: capacity,
              readOnly: isDesk,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Capacity'),
              validator: (value) {
                final seats = int.tryParse((value ?? '').trim());
                if (seats == null || seats < 1) {
                  return 'Enter a whole number of at least 1';
                }
                return null;
              },
              onChanged: (value) => capacity = value,
            ),
            TextFormField(
              initialValue: rate,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Hourly rate'),
              validator: (value) {
                final price = double.tryParse((value ?? '').trim());
                if (price == null || !price.isFinite || price < 0) {
                  return 'Enter a rate of 0 or more';
                }
                return null;
              },
              onChanged: (value) => rate = value,
            ),
            DropdownButtonFormField<String>(
              initialValue: status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                DropdownMenuItem(
                  value: 'OUT_OF_SERVICE',
                  child: Text('Out of service'),
                ),
              ],
              onChanged: (value) {
                if (value != null) status = value;
              },
            ),
            if (isDesk)
              TextFormField(
                initialValue: deskType,
                decoration: const InputDecoration(labelText: 'Desk type'),
                validator: requiredText,
                onChanged: (value) => deskType = value,
              )
            else
              SwitchListTile(
                title: const Text('Video conferencing'),
                value: video,
                onChanged: (value) => setState(() => video = value),
              ),
            const SizedBox(height: 16),
            if (error != null) Text(error!),
            ElevatedButton(onPressed: saving ? null : save, child: Text(saving ? 'Saving…' : 'Save')),
          ],
        ),
      ),
    );
  }
}
