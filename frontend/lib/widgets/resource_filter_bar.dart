// Owner: Jassem
// What: Filter controls above the resource list: type, minimum capacity, location, maximum hourly rate.
// Checklist: the resource list can filter.
// Depends on: nothing. ResourcesScreen passes the values to ApiClient.getResources.

import 'package:material_ui/material_ui.dart';

typedef ResourceFilterCallback = void Function({
  String? type,
  int? minCapacity,
  String? location,
  double? maxHourlyRate,
});

class ResourceFilterBar extends StatefulWidget {
  const ResourceFilterBar({super.key, required this.onApply});

  final ResourceFilterCallback onApply;

  @override
  State<ResourceFilterBar> createState() => _ResourceFilterBarState();
}

class _ResourceFilterBarState extends State<ResourceFilterBar> {
  final locationController = TextEditingController();
  final capacityController = TextEditingController();
  final rateController = TextEditingController();
  String selectedType = 'ALL';

  void applyFilters() {
    widget.onApply(
      type: selectedType == 'ALL' ? null : selectedType,
      location: locationController.text.trim(),
      minCapacity: int.tryParse(capacityController.text.trim()),
      maxHourlyRate: double.tryParse(rateController.text.trim()),
    );
  }

  void clearFilters() {
    locationController.clear();
    capacityController.clear();
    rateController.clear();
    setState(() {
      selectedType = 'ALL';
    });
    applyFilters();
  }

  @override
  void dispose() {
    locationController.dispose();
    capacityController.dispose();
    rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: selectedType,
          items: const [
            DropdownMenuItem(value: 'ALL', child: Text('All types')),
            DropdownMenuItem(
              value: 'MEETING_ROOM',
              child: Text('Meeting rooms'),
            ),
            DropdownMenuItem(value: 'DESK', child: Text('Desks')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              selectedType = value;
            });
          },
        ),
        TextField(
          controller: locationController,
          decoration: const InputDecoration(labelText: 'Filter by location'),
        ),
        TextField(
          controller: capacityController,
          decoration: const InputDecoration(labelText: 'Minimum capacity'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: rateController,
          decoration: const InputDecoration(labelText: 'Maximum hourly rate'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: applyFilters,
              child: const Text('Apply filters'),
            ),
            TextButton(onPressed: clearFilters, child: const Text('Clear')),
          ],
        ),
      ],
    );
  }
}
