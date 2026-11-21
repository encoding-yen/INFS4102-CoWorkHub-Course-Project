// Owner: Yyan
// What: The ONLY place in the app that makes HTTP calls. Screens call these methods and never use http directly.
//       One method per endpoint in docs/API.md.
// Checklist: uses async/await; covers GET, POST, PUT, and DELETE for every endpoint;
//            Dart model classes match the JSON fields used by the screens.
// Depends on: the model classes (Jassem). Each method only succeeds once its server endpoint is implemented:
//   members and resources   -> Erin's controllers
//   bookings, availability  -> Amani's controllers
//   error messages          -> Erin's GlobalExceptionHandler
// You can write every method today against the JSON in docs/API.md.

import 'package:http/http.dart' as http;

import '../models/booking.dart';
import '../models/member.dart';
import '../models/resource.dart';

/// Thrown for any non-2xx response. [message] is the server's "message" field,
/// which screens show to the user, for example the overlap error during the demo.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  factory ApiException.fromResponse(http.Response response) {
    // TODO(Yyan): Decode {"status", "error", "message"} from response.body and keep "message".
    //             If the body is not that JSON (for example the server is down), use a general sentence.
    throw UnimplementedError('TODO(Yyan): ApiException.fromResponse');
  }

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({this.baseUrl = 'http://localhost:8080', http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client httpClient;

  // TODO(Yyan): Add small private helpers if they help, for example one that sends a request with
  //             Content-Type: application/json, throws ApiException.fromResponse for non-2xx, and decodes JSON.
  //             A connection failure (server not running) should also become a readable ApiException.

  // Members ---------------------------------------------------------------

  Future<List<Member>> getMembers() async {
    // TODO(Yyan): GET /api/members -> list of Member.fromJson.
    throw UnimplementedError('TODO(Yyan): getMembers');
  }

  Future<Member> createMember({required String fullName, required String email}) async {
    // TODO(Yyan): POST /api/members with {fullName, email}. Expect 201.
    throw UnimplementedError('TODO(Yyan): createMember');
  }

  Future<Member> updateMember(int id, {required String fullName, required String email}) async {
    // TODO(Yyan): PUT /api/members/{id} with {fullName, email}. Expect 200.
    throw UnimplementedError('TODO(Yyan): updateMember');
  }

  // Resources -------------------------------------------------------------

  Future<List<Resource>> getResources({
    String? type,
    int? minCapacity,
    String? location,
    double? maxHourlyRate,
  }) async {
    // TODO(Yyan): GET /api/resources with only the non-null filters as query parameters.
    //             Build the URL with Uri.parse(baseUrl).replace(path: ..., queryParameters: ...).
    throw UnimplementedError('TODO(Yyan): getResources');
  }

  Future<Resource> createRoom({
    required String name,
    required String location,
    required int capacity,
    required double hourlyRate,
    required bool hasVideoConference,
    String status = 'ACTIVE',
  }) async {
    // TODO(Yyan): POST /api/resources/rooms. Expect 201.
    throw UnimplementedError('TODO(Yyan): createRoom');
  }

  Future<Resource> createDesk({
    required String name,
    required String location,
    required double hourlyRate,
    required String deskType,
    int capacity = 1,
    String status = 'ACTIVE',
  }) async {
    // TODO(Yyan): POST /api/resources/desks. Expect 201.
    throw UnimplementedError('TODO(Yyan): createDesk');
  }

  Future<Resource> updateResource(
    int id, {
    required String name,
    required String location,
    required int capacity,
    required double hourlyRate,
    required String status,
    bool? hasVideoConference,
    String? deskType,
  }) async {
    // TODO(Yyan): PUT /api/resources/{id}. Send hasVideoConference for a room, deskType for a desk.
    //             Setting status to OUT_OF_SERVICE goes through this method.
    throw UnimplementedError('TODO(Yyan): updateResource');
  }

  Future<void> deleteResource(int id) async {
    // TODO(Yyan): DELETE /api/resources/{id}. Expect 204. A 409 must reach the screen as ApiException,
    //             so the user sees "This resource has bookings and cannot be deleted...".
    throw UnimplementedError('TODO(Yyan): deleteResource');
  }

  Future<List<Resource>> getAvailableResources({
    required DateTime start,
    required DateTime end,
    String? type,
    int? minCapacity,
    String? location,
    double? maxHourlyRate,
  }) async {
    // TODO(Yyan): GET /api/resources/available?start=...&end=... plus optional filters.
    //             Send dates as "2026-11-20T14:00:00": no milliseconds, no timezone.
    throw UnimplementedError('TODO(Yyan): getAvailableResources');
  }

  // Bookings --------------------------------------------------------------

  Future<List<Booking>> getBookings({int? memberId}) async {
    // TODO(Yyan): GET /api/bookings, or /api/bookings?memberId={id} for one member's bookings.
    throw UnimplementedError('TODO(Yyan): getBookings');
  }

  Future<Booking> createBooking({
    required int memberId,
    required int resourceId,
    required DateTime start,
    required DateTime end,
    required int attendees,
  }) async {
    // TODO(Yyan): POST /api/bookings with {memberId, resourceId, startDateTime, endDateTime, attendees}.
    //             Never send status or totalCost; the server sets them. Expect 201.
    throw UnimplementedError('TODO(Yyan): createBooking');
  }

  Future<Booking> updateBooking(
    int id, {
    required DateTime start,
    required DateTime end,
    required int attendees,
  }) async {
    // TODO(Yyan): PUT /api/bookings/{id} with {startDateTime, endDateTime, attendees}.
    throw UnimplementedError('TODO(Yyan): updateBooking');
  }

  Future<Booking> cancelBooking(int id) async {
    // TODO(Yyan): PUT /api/bookings/{id} with {"status": "CANCELLED"}. There is no DELETE for bookings.
    throw UnimplementedError('TODO(Yyan): cancelBooking');
  }
}
