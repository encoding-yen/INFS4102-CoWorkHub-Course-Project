# CoWorkHub message menu

This is the shared paper for the project. The window and the server both use these names. If code and this paper disagree, change the code.

The server will live at `http://localhost:8080`.

Bodies are JSON. A request that has a body sends `Content-Type: application/json`.

A date and time looks like `2026-11-20T14:00:00`. No timezone and no `Z` on the end.

A price looks like `40.00`.

A resource is `ACTIVE` or `OUT_OF_SERVICE`. Being free at 2pm is not a status. The server works that out from bookings.

## What each person can write before the others are done

The sample JSON below is enough to start.

- Screens can show the sample members, rooms, desks, and bookings as data typed into the app. The screens do not need a running server for that.
- The booking rules can be ordinary checks on two start times, two end times, a number of people, and an hourly price. Those checks do not need the Member or Room classes.
- The functions that will call the server can be written to send the JSON below. They will not succeed until the endpoint exists, and the function can still be written and read.
- The Member, Room, and Desk classes are the piece the booking-save code waits for. After those classes exist, a booking can point at a real member and a real room.

## Errors

Every failure comes back in this shape. The screen shows `message`.

```json
{
  "status": 409,
  "error": "Conflict",
  "message": "This resource already has a confirmed booking that overlaps the requested time."
}
```

| What happened | Status | `error` | `message` |
|---|---|---|---|
| Missing field, bad date, end not after start, bad attendee count, bad capacity | 400 | Bad Request | A sentence that says what is wrong |
| Unknown member, resource, or booking | 404 | Not Found | `Member not found.` or `Resource not found.` or `Booking not found.` |
| Email already used | 409 | Conflict | `A member with this email already exists.` |
| Overlapping confirmed booking | 409 | Conflict | `This resource already has a confirmed booking that overlaps the requested time.` |
| Resource is out of service | 409 | Conflict | `This resource is out of service and cannot be booked.` |
| Delete a resource that has any booking, including a cancelled one | 409 | Conflict | `This resource has bookings and cannot be deleted. Set it to OUT_OF_SERVICE instead.` |

Throw `BadRequestException` (400), `NotFoundException` (404), or `ConflictException` (409) from `com.coworkhub.exception`, and let `GlobalExceptionHandler` build this JSON. Do not invent a second shape.

Editing a cancelled booking is also 400, message `A cancelled booking cannot be edited.`

## Members

| Method | Path | Success |
|---|---|---|
| GET | `/api/members` | 200 and the list |
| POST | `/api/members` | 201 and the new member |
| PUT | `/api/members/{id}` | 200 and the updated member |

There is no delete-member path. The update path is there so the management screen can edit a name or email.

Request:

```json
{
  "fullName": "Maya Chen",
  "email": "maya@example.com"
}
```

Response:

```json
{
  "id": 1,
  "fullName": "Maya Chen",
  "email": "maya@example.com"
}
```

`fullName` and `email` are required. The email must contain `@`. Two members cannot share an email.

## Resources

Create rooms and desks on separate paths. Lists say which is which with `type`.

| Method | Path | Success |
|---|---|---|
| GET | `/api/resources` | 200 and the matching resources |
| POST | `/api/resources/rooms` | 201 and the new room |
| POST | `/api/resources/desks` | 201 and the new desk |
| PUT | `/api/resources/{id}` | 200 and the updated resource |
| DELETE | `/api/resources/{id}` | 204 and an empty body |

Create a room:

```json
{
  "name": "Atlas Room",
  "location": "Floor 2",
  "capacity": 8,
  "hourlyRate": 40.00,
  "status": "ACTIVE",
  "hasVideoConference": true
}
```

Room response:

```json
{
  "id": 1,
  "type": "MEETING_ROOM",
  "name": "Atlas Room",
  "location": "Floor 2",
  "capacity": 8,
  "hourlyRate": 40.00,
  "status": "ACTIVE",
  "hasVideoConference": true
}
```

Create a desk:

```json
{
  "name": "Desk D4",
  "location": "Floor 1",
  "capacity": 1,
  "hourlyRate": 8.00,
  "status": "ACTIVE",
  "deskType": "STANDING"
}
```

Desk response:

```json
{
  "id": 2,
  "type": "DESK",
  "name": "Desk D4",
  "location": "Floor 1",
  "capacity": 1,
  "hourlyRate": 8.00,
  "status": "ACTIVE",
  "deskType": "STANDING"
}
```

`name`, `location`, `capacity`, and `hourlyRate` are required. On create, `status` may be left out and the server stores `ACTIVE`. A room requires `hasVideoConference`. A desk requires `deskType`.

`capacity` is a whole number of at least 1. A desk's capacity is 1. `hourlyRate` is zero or more. An update sends the same fields as create. A room stays a room, and a desk stays a desk.

Delete succeeds only when that resource has no bookings at all. A cancelled booking still counts. To retire a room or desk without deleting history, set `status` to `OUT_OF_SERVICE`.

### Filters

`GET /api/resources?type=MEETING_ROOM&minCapacity=4&location=floor&maxHourlyRate=50`

Every filter is optional. They all apply together. No filters means every resource.

| Parameter | Meaning |
|---|---|
| `type` | `MEETING_ROOM` or `DESK` |
| `minCapacity` | Capacity is at least this |
| `location` | Location contains this text, ignoring capitals |
| `maxHourlyRate` | Hourly rate is at most this |

An unknown `type` is 400.

## Bookings

The window sends who, which resource, when, and how many people. The server chooses `CONFIRMED` and calculates `totalCost`.

| Method | Path | Success |
|---|---|---|
| GET | `/api/bookings` | 200 and every booking, cancelled ones included |
| GET | `/api/bookings?memberId=1` | 200 and that member's bookings. 404 if the member does not exist |
| POST | `/api/bookings` | 201 and the new booking |
| PUT | `/api/bookings/{id}` | 200 and the updated booking |

There is no delete-booking path. Cancel keeps the row and changes its status.

Create request:

```json
{
  "memberId": 1,
  "resourceId": 1,
  "startDateTime": "2026-11-20T14:00:00",
  "endDateTime": "2026-11-20T15:30:00",
  "attendees": 4
}
```

Response:

```json
{
  "id": 10,
  "memberId": 1,
  "memberName": "Maya Chen",
  "resourceId": 1,
  "resourceName": "Atlas Room",
  "startDateTime": "2026-11-20T14:00:00",
  "endDateTime": "2026-11-20T15:30:00",
  "attendees": 4,
  "status": "CONFIRMED",
  "totalCost": 60.00
}
```

Price is `hourlyRate × minutes / 60`, rounded to two decimals, halves rounded up. Forty per hour for 90 minutes is `60.00`.

The server refuses the save when any of these is true:

- The end is not after the start. 400, `The start time must be before the end time.`
- Attendees is missing or under 1. 400, `A booking must have at least one attendee.`
- The resource is a desk and attendees is not exactly 1. 400, `A desk can only be booked for one attendee.`
- The resource is a room and attendees is over its capacity. 400, `The number of attendees exceeds this room's capacity.`
- The member or the resource does not exist. 404.
- The resource is `OUT_OF_SERVICE`. 409, `This resource is out of service and cannot be booked.`
- Another `CONFIRMED` booking on that resource overlaps. 409, `This resource already has a confirmed booking that overlaps the requested time.`

Overlap means the existing booking starts before the new end, and the existing booking ends after the new start. A booking that starts at the exact minute another ends is allowed. Cancelled bookings do not overlap anything. While editing, the booking being edited does not count as overlapping itself.

Edit request. Send all three fields:

```json
{
  "startDateTime": "2026-11-20T16:00:00",
  "endDateTime": "2026-11-20T17:00:00",
  "attendees": 3
}
```

The server runs the same checks and calculates `totalCost` again.

Cancel request:

```json
{
  "status": "CANCELLED"
}
```

The row stays in the list. That time is free for a new booking. The only status a request may send is `CANCELLED`. Sending `CONFIRMED` is 400. A cancel does not change the time or the number of people.

Build this flat response in the controller. Returning the database booking object directly would nest the whole member and the whole room inside it, which is not this shape.

## Availability

`GET /api/resources/available?start=2026-11-20T14:00:00&end=2026-11-20T16:00:00`

`start` and `end` are required. The same optional filters as `GET /api/resources` may be added.

The response is 200 and a resource list in the resource shape above. Include a resource only when it is `ACTIVE` and no `CONFIRMED` booking overlaps that interval.

Put this path in its own class, `AvailabilityController`, in the booking package. The other `/api/resources` paths stay in the resource controller. Spring can serve both.

## Which code this lines up with

| Paper section | Who writes the server part | Who writes the screen |
|---|---|---|
| Members, and resources except availability | The backend foundation | Member and resource screens |
| Bookings and availability | Booking rules and endpoints | New-booking screen and bookings screen |
| The calls that send this JSON | The HTTP client | The screens call that client instead of keeping sample data |
