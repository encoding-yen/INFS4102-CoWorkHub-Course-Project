// Owner: Yyan
// What: The ONLY place in the app that makes HTTP calls. Screens call these methods and never use http directly.
//       One method per endpoint in docs/API.md.
// Checklist: uses async/await; covers GET, POST, PUT, and DELETE for every endpoint;
//            Dart model classes match the JSON fields used by the screens.
// Depends on: the model classes (Jassem). Each method only succeeds once its server endpoint is implemented:
//   members and resources   -> Erin's controllers
//   bookings, availability  -> Amani's controllers
//   error messages          -> Erin's GlobalExceptionHandler

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/booking.dart';
import '../models/member.dart';
import '../models/resource.dart';

/// Thrown for any failed request. [message] is the server's "message" field,
/// which screens show to the user, for example the overlap error during the demo.
/// [statusCode] is 0 when no response arrived (server not running, timeout).
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  factory ApiException.fromResponse(http.Response response) {
    // The server sends {"status": 409, "error": "Conflict", "message": "..."}.
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map<String, dynamic> && body['message'] is String) {
        return ApiException(response.statusCode, body['message'] as String);
      }
    } catch (_) {
      // The body was empty or not JSON. Fall through to the general sentence.
    }
    return ApiException(
      response.statusCode,
      'The server returned an unexpected error (${response.statusCode}).',
    );
  }

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({this.baseUrl = 'http://localhost:8080', http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client httpClient;

  static const _timeout = Duration(seconds: 15);
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  // Helpers ---------------------------------------------------------------

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse(baseUrl);
    return base.replace(
      path: path,
      queryParameters: (query == null || query.isEmpty) ? null : query,
    );
  }

  /// Sends one request. Turns a connection failure into a readable ApiException
  /// and any non-2xx response into ApiException.fromResponse.
  Future<http.Response> _send(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
  }) async {
    final request = http.Request(method, uri);
    if (body != null) {
      request.headers.addAll(_jsonHeaders);
      request.body = jsonEncode(body);
    }

    http.Response response;
    try {
      final streamed = await httpClient.send(request).timeout(_timeout);
      response = await http.Response.fromStream(streamed).timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(0, 'The server took too long to respond. Please try again.');
    } on Exception {
      throw const ApiException(
        0,
        'Could not reach the server. Check that it is running at the address the app uses.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromResponse(response);
    }
    return response;
  }

  dynamic _decode(http.Response response) => jsonDecode(utf8.decode(response.bodyBytes));

  List<T> _decodeList<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    final list = _decode(response) as List<dynamic>;
    return list.map((item) => fromJson(item as Map<String, dynamic>)).toList();
  }

  /// "2026-11-20T14:00:00": no milliseconds, no timezone, as docs/API.md requires.
  String _dateTime(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year.toString().padLeft(4, '0')}-${two(value.month)}-${two(value.day)}'
        'T${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
  }

  Map<String, String> _resourceFilters({
    String? type,
    int? minCapacity,
    String? location,
    double? maxHourlyRate,
  }) {
    final query = <String, String>{};
    if (type != null && type.isNotEmpty) query['type'] = type;
    if (minCapacity != null) query['minCapacity'] = minCapacity.toString();
    if (location != null && location.trim().isNotEmpty) query['location'] = location.trim();
    if (maxHourlyRate != null) query['maxHourlyRate'] = maxHourlyRate.toString();
    return query;
  }

  // Members ---------------------------------------------------------------

  Future<List<Member>> getMembers() async {
    final response = await _send('GET', _uri('/api/members'));
    return _decodeList(response, Member.fromJson);
  }

  Future<Member> createMember({required String fullName, required String email}) async {
    final response = await _send(
      'POST',
      _uri('/api/members'),
      body: {'fullName': fullName, 'email': email},
    );
    return Member.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<Member> updateMember(int id, {required String fullName, required String email}) async {
    final response = await _send(
      'PUT',
      _uri('/api/members/$id'),
      body: {'fullName': fullName, 'email': email},
    );
    return Member.fromJson(_decode(response) as Map<String, dynamic>);
  }

  // Resources -------------------------------------------------------------

  Future<List<Resource>> getResources({
    String? type,
    int? minCapacity,
    String? location,
    double? maxHourlyRate,
  }) async {
    final query = _resourceFilters(
      type: type,
      minCapacity: minCapacity,
      location: location,
      maxHourlyRate: maxHourlyRate,
    );
    final response = await _send('GET', _uri('/api/resources', query));
    return _decodeList(response, Resource.fromJson);
  }

  Future<Resource> createRoom({
    required String name,
    required String location,
    required int capacity,
    required double hourlyRate,
    required bool hasVideoConference,
    String status = 'ACTIVE',
  }) async {
    final response = await _send(
      'POST',
      _uri('/api/resources/rooms'),
      body: {
        'name': name,
        'location': location,
        'capacity': capacity,
        'hourlyRate': hourlyRate,
        'status': status,
        'hasVideoConference': hasVideoConference,
      },
    );
    return Resource.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<Resource> createDesk({
    required String name,
    required String location,
    required double hourlyRate,
    required String deskType,
    int capacity = 1,
    String status = 'ACTIVE',
  }) async {
    final response = await _send(
      'POST',
      _uri('/api/resources/desks'),
      body: {
        'name': name,
        'location': location,
        'capacity': capacity,
        'hourlyRate': hourlyRate,
        'status': status,
        'deskType': deskType,
      },
    );
    return Resource.fromJson(_decode(response) as Map<String, dynamic>);
  }

  /// Not a partial update: every common field is sent. Send [hasVideoConference]
  /// for a room or [deskType] for a desk. The type itself cannot be changed.
  /// Setting [status] to OUT_OF_SERVICE goes through this method.
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
    final body = <String, dynamic>{
      'name': name,
      'location': location,
      'capacity': capacity,
      'hourlyRate': hourlyRate,
      'status': status,
    };
    if (hasVideoConference != null) body['hasVideoConference'] = hasVideoConference;
    if (deskType != null) body['deskType'] = deskType;

    final response = await _send('PUT', _uri('/api/resources/$id'), body: body);
    return Resource.fromJson(_decode(response) as Map<String, dynamic>);
  }

  /// A 409 (resource has bookings) arrives as an ApiException with the server's message.
  Future<void> deleteResource(int id) async {
    await _send('DELETE', _uri('/api/resources/$id'));
  }

  Future<List<Resource>> getAvailableResources({
    required DateTime start,
    required DateTime end,
    String? type,
    int? minCapacity,
    String? location,
    double? maxHourlyRate,
  }) async {
    final query = <String, String>{
      'start': _dateTime(start),
      'end': _dateTime(end),
      ..._resourceFilters(
        type: type,
        minCapacity: minCapacity,
        location: location,
        maxHourlyRate: maxHourlyRate,
      ),
    };
    final response = await _send('GET', _uri('/api/resources/available', query));
    return _decodeList(response, Resource.fromJson);
  }

  // Bookings --------------------------------------------------------------

  Future<List<Booking>> getBookings({int? memberId}) async {
    final query = memberId == null ? null : {'memberId': memberId.toString()};
    final response = await _send('GET', _uri('/api/bookings', query));
    return _decodeList(response, Booking.fromJson);
  }

  /// The server sets status and totalCost, so they are never sent.
  Future<Booking> createBooking({
    required int memberId,
    required int resourceId,
    required DateTime start,
    required DateTime end,
    required int attendees,
  }) async {
    final response = await _send(
      'POST',
      _uri('/api/bookings'),
      body: {
        'memberId': memberId,
        'resourceId': resourceId,
        'startDateTime': _dateTime(start),
        'endDateTime': _dateTime(end),
        'attendees': attendees,
      },
    );
    return Booking.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<Booking> updateBooking(
    int id, {
    required DateTime start,
    required DateTime end,
    required int attendees,
  }) async {
    final response = await _send(
      'PUT',
      _uri('/api/bookings/$id'),
      body: {
        'startDateTime': _dateTime(start),
        'endDateTime': _dateTime(end),
        'attendees': attendees,
      },
    );
    return Booking.fromJson(_decode(response) as Map<String, dynamic>);
  }

  /// There is no DELETE for bookings: cancelling is an update that keeps the row.
  Future<Booking> cancelBooking(int id) async {
    final response = await _send(
      'PUT',
      _uri('/api/bookings/$id'),
      body: {'status': 'CANCELLED'},
    );
    return Booking.fromJson(_decode(response) as Map<String, dynamic>);
  }
}
