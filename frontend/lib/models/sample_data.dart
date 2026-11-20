// Owner: Jassem
// What: Fake data copied from docs/API.md, so screens can be built before the server and ApiClient work.
// Depends on: the model classes (done).
//
// TODO(Jassem): Use these lists while building screens.
// TODO(Jassem): Once Yyan's ApiClient works, switch every screen to ApiClient and DELETE THIS FILE
//               before submission. The demo must show real data from the server.

import 'booking.dart';
import 'member.dart';
import 'resource.dart';

const List<Member> sampleMembers = [
  Member(id: 1, fullName: 'Maya Chen', email: 'maya@example.com'),
];

const List<Resource> sampleResources = [
  Resource(
    id: 1,
    type: 'MEETING_ROOM',
    name: 'Atlas Room',
    location: 'Floor 2',
    capacity: 8,
    hourlyRate: 40.00,
    status: 'ACTIVE',
    hasVideoConference: true,
  ),
  Resource(
    id: 2,
    type: 'DESK',
    name: 'Desk D4',
    location: 'Floor 1',
    capacity: 1,
    hourlyRate: 8.00,
    status: 'ACTIVE',
    deskType: 'STANDING',
  ),
];

final List<Booking> sampleBookings = [
  Booking(
    id: 10,
    memberId: 1,
    memberName: 'Maya Chen',
    resourceId: 1,
    resourceName: 'Atlas Room',
    startDateTime: DateTime(2026, 11, 20, 14, 0),
    endDateTime: DateTime(2026, 11, 20, 15, 30),
    attendees: 4,
    status: 'CONFIRMED',
    totalCost: 60.00,
  ),
];
