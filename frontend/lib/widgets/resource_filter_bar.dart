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
  // TODO(Jassem): A type dropdown (All / MEETING_ROOM / DESK), text fields for minimum capacity, location,
  //               and maximum hourly rate, and an Apply button that calls widget.onApply.
  //               Empty fields mean no filter. A separate Clear button is optional.

  @override
  Widget build(BuildContext context) {
    return const Placeholder(fallbackHeight: 56);
  }
}
