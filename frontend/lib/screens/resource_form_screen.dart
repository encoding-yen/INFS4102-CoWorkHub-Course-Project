// Owner: Jassem
// What: Create a room, create a desk, or edit an existing resource, including setting it OUT_OF_SERVICE.
// Checklist: management screens create and update a room and a desk, and can set a resource to OUT_OF_SERVICE;
//            the form stops an empty name before the request is sent; loading, success, and error states.
// Depends on: AppData (saves through ApiClient createRoom, createDesk, updateResource, then updates every screen).

import 'package:material_ui/material_ui.dart';

import '../models/resource.dart';
import '../services/api_client.dart';
import '../state/app_data.dart';

class ResourceFormScreen extends StatefulWidget {
  const ResourceFormScreen({
    super.key,
    required this.data,
    this.resource,
    this.newType,
  });

  final AppData data;
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

  bool saving = false;
  String? error;

  String? requiredText(String? value) {
    return (value ?? '').trim().isEmpty ? 'Required' : null;
  }

  Future<void> save() async {
    if (saving || !formKey.currentState!.validate()) return;

    final cleanName = name.trim();
    final cleanLocation = location.trim();
    final seats = isDesk ? 1 : int.parse(capacity.trim());
    final hourlyRate = double.parse(rate.trim());
    final cleanDeskType = deskType.trim();

    setState(() {
      saving = true;
      error = null;
    });

    try {
      final existing = original;
      if (existing != null) {
        await widget.data.updateResource(
          existing.id,
          name: cleanName,
          location: cleanLocation,
          capacity: seats,
          hourlyRate: hourlyRate,
          status: status,
          hasVideoConference: isDesk ? null : video,
          deskType: isDesk ? cleanDeskType : null,
        );
      } else if (isDesk) {
        await widget.data.createDesk(
          name: cleanName,
          location: cleanLocation,
          hourlyRate: hourlyRate,
          deskType: cleanDeskType,
          status: status,
        );
      } else {
        await widget.data.createRoom(
          name: cleanName,
          location: cleanLocation,
          capacity: seats,
          hourlyRate: hourlyRate,
          hasVideoConference: video,
          status: status,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$cleanName saved')));
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
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
              enabled: !saving,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: requiredText,
              onChanged: (value) => name = value,
            ),
            TextFormField(
              initialValue: location,
              enabled: !saving,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: requiredText,
              onChanged: (value) => location = value,
            ),
            TextFormField(
              initialValue: capacity,
              readOnly: isDesk,
              enabled: !saving,
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
              enabled: !saving,
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
              onChanged: saving
                  ? null
                  : (value) {
                      if (value != null) status = value;
                    },
            ),
            if (isDesk)
              TextFormField(
                initialValue: deskType,
                enabled: !saving,
                decoration: const InputDecoration(labelText: 'Desk type'),
                validator: requiredText,
                onChanged: (value) => deskType = value,
              )
            else
              SwitchListTile(
                title: const Text('Video conferencing'),
                value: video,
                onChanged: saving ? null : (value) => setState(() => video = value),
              ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saving ? null : save,
              child: Text(saving ? 'Saving...' : 'Save'),
            ),
            if (saving) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
