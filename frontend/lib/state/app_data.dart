// What: The one shared copy of the app's data (members, resources, bookings).
//       Every screen reads from here and listens to it, so a change made on any screen
//       (create, edit, cancel, delete) shows up on every other screen straight away.
// How it works: every change goes to the server through ApiClient, then the three lists are
//       reloaded from the server and the listeners are told. The server stays the source of truth,
//       so names inside bookings (member and resource names) are always up to date too.

import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../models/member.dart';
import '../models/resource.dart';
import '../services/api_client.dart';

class AppData extends ChangeNotifier {
  AppData(this.api);

  /// The only way this class talks to the server.
  final ApiClient api;

  List<Member> members = const [];
  List<Resource> resources = const [];
  List<Booking> bookings = const [];

  /// True once the three lists have loaded at least once.
  bool loaded = false;

  /// True while the first load is running.
  bool loading = false;

  /// The message of the last failed load. Screens show it with a Retry button until the first load works.
  String? error;

  int _generation = 0;

  /// Reloads members, resources, and bookings, then tells every listening screen.
  Future<void> refresh() async {
    final generation = ++_generation;
    if (!loaded) {
      loading = true;
      error = null;
      notifyListeners();
    }

    try {
      final newMembers = await api.getMembers();
      final newResources = await api.getResources();
      final newBookings = await api.getBookings();

      // A newer refresh started while this one was waiting. Its result wins.
      if (generation != _generation) return;

      members = newMembers;
      resources = newResources;
      bookings = newBookings;
      loaded = true;
      error = null;
    } on ApiException catch (e) {
      if (generation != _generation) return;
      error = e.message;
    } catch (_) {
      if (generation != _generation) return;
      error = 'The server sent data the app could not read.';
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  /// Sends one change to the server, then reloads everything so all screens agree.
  /// An ApiException from the server is passed on so the calling form can show its message.
  Future<T> _change<T>(Future<T> Function() action) async {
    final result = await action();
    await refresh();
    return result;
  }

  // Members ---------------------------------------------------------------

  Future<Member> createMember({required String fullName, required String email}) {
    return _change(() => api.createMember(fullName: fullName, email: email));
  }

  Future<Member> updateMember(int id, {required String fullName, required String email}) {
    return _change(() => api.updateMember(id, fullName: fullName, email: email));
  }

  // Resources -------------------------------------------------------------

  Future<Resource> createRoom({
    required String name,
    required String location,
    required int capacity,
    required double hourlyRate,
    required bool hasVideoConference,
    String status = 'ACTIVE',
  }) {
    return _change(
      () => api.createRoom(
        name: name,
        location: location,
        capacity: capacity,
        hourlyRate: hourlyRate,
        hasVideoConference: hasVideoConference,
        status: status,
      ),
    );
  }

  Future<Resource> createDesk({
    required String name,
    required String location,
    required double hourlyRate,
    required String deskType,
    String status = 'ACTIVE',
  }) {
    return _change(
      () => api.createDesk(
        name: name,
        location: location,
        hourlyRate: hourlyRate,
        deskType: deskType,
        status: status,
      ),
    );
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
  }) {
    return _change(
      () => api.updateResource(
        id,
        name: name,
        location: location,
        capacity: capacity,
        hourlyRate: hourlyRate,
        status: status,
        hasVideoConference: hasVideoConference,
        deskType: deskType,
      ),
    );
  }

  /// A 409 (the resource has bookings) arrives as an ApiException with the server's message.
  Future<void> deleteResource(int id) {
    return _change(() => api.deleteResource(id));
  }

  /// A search only reads from the server, so it changes nothing and reloads nothing.
  Future<List<Resource>> findAvailable({required DateTime start, required DateTime end}) {
    return api.getAvailableResources(start: start, end: end);
  }

  // Bookings --------------------------------------------------------------

  Future<Booking> createBooking({
    required int memberId,
    required int resourceId,
    required DateTime start,
    required DateTime end,
    required int attendees,
  }) {
    return _change(
      () => api.createBooking(
        memberId: memberId,
        resourceId: resourceId,
        start: start,
        end: end,
        attendees: attendees,
      ),
    );
  }

  Future<Booking> updateBooking(
    int id, {
    required DateTime start,
    required DateTime end,
    required int attendees,
  }) {
    return _change(() => api.updateBooking(id, start: start, end: end, attendees: attendees));
  }

  Future<Booking> cancelBooking(int id) {
    return _change(() => api.cancelBooking(id));
  }
}
