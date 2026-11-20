// Owner: Jassem (Yyan checks the field names match the server JSON)
// What: A room or a desk as the server sends it. See docs/API.md, section Resources.
//       type is "MEETING_ROOM" or "DESK". status is "ACTIVE" or "OUT_OF_SERVICE".
//       hasVideoConference is only set for rooms; deskType is only set for desks.
// Depends on: nothing.

class Resource {
  const Resource({
    required this.id,
    required this.type,
    required this.name,
    required this.location,
    required this.capacity,
    required this.hourlyRate,
    required this.status,
    this.hasVideoConference,
    this.deskType,
  });

  final int id;
  final String type;
  final String name;
  final String location;
  final int capacity;
  final double hourlyRate;
  final String status;
  final bool? hasVideoConference;
  final String? deskType;

  bool get isDesk => type == 'DESK';
  bool get isActive => status == 'ACTIVE';

  factory Resource.fromJson(Map<String, dynamic> json) {
    // TODO(Jassem): Read every field. hourlyRate arrives as a JSON number: use (json['hourlyRate'] as num).toDouble().
    //               hasVideoConference and deskType may be missing.
    throw UnimplementedError('TODO(Jassem): Resource.fromJson');
  }
}
