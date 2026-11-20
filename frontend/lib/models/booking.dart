// Owner: Jassem (Yyan checks the field names match the server JSON)
// What: A booking as the server sends it. See docs/API.md, section Bookings.
//       status is "CONFIRMED" or "CANCELLED". The server calculates totalCost; the app only displays it.
// Depends on: nothing.

class Booking {
  const Booking({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.resourceId,
    required this.resourceName,
    required this.startDateTime,
    required this.endDateTime,
    required this.attendees,
    required this.status,
    required this.totalCost,
  });

  final int id;
  final int memberId;
  final String memberName;
  final int resourceId;
  final String resourceName;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int attendees;
  final String status;
  final double totalCost;

  bool get isCancelled => status == 'CANCELLED';

  // TODO(Jassem): Decide what counts as a past booking for the bookings screen, for example endDateTime before now.
  bool get isPast => throw UnimplementedError('TODO(Jassem): Booking.isPast');

  factory Booking.fromJson(Map<String, dynamic> json) {
    // TODO(Jassem): Read every field. Dates use DateTime.parse("2026-11-20T14:00:00").
    //               totalCost arrives as a JSON number: use (json['totalCost'] as num).toDouble().
    throw UnimplementedError('TODO(Jassem): Booking.fromJson');
  }
}
