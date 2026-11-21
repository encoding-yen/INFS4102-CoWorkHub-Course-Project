# CoWorkHub API contract

This is the shared contract for the Flutter client and the server. Follow the project brief first, then the endpoint names, fields, and messages agreed here. Resolve a disagreement in this note before changing either side independently.

## Scope from the brief

- Part 3 requires resource management and filtering, member creation and listing, member booking history, booking creation/editing/cancellation, pricing, and availability with the stated booking rules.
- Part 4 allows the team to choose URLs and resource creation design. This project uses separate `/rooms` and `/desks` paths and the JSON shown below.
- Exact field names, validation messages, case-insensitive email comparison, the pricing rounding rule, and the flat booking response are team choices that make the API consistent.
- Member editing is a small existing addition, not a minimum requirement of Parts 3–4. Its endpoint remains supported; the minimum member screen needs creation, listing, and booking history.

Use the existing controllers, services, repositories, request records, and simple loops. No additional API layers or features are needed for this contract.

## Common format

The server will live at `http://localhost:8080`.

Bodies are JSON. A request that has a body sends `Content-Type: application/json`.

A date and time looks like `2026-11-20T14:00:00`. No timezone and no `Z` on the end.

A price is a JSON number, for example `40.00`. `40` and `40.0` mean the same value; the client may display two decimal places.

A resource is `ACTIVE` or `OUT_OF_SERVICE`. Being free at 2pm is not a status. The server works that out from bookings.

## What each person can write before the others are done

The sample JSON below is enough to start.

- Screens can show the sample members, rooms, desks, and bookings as data typed into the app. The screens do not need a running server for that.
- The booking rules can be ordinary checks on two start times, two end times, a number of people, and an hourly price. Those checks do not need the Member or Room classes.
- The functions that will call the server can be written to send the JSON below. They will not succeed until the endpoint exists, and the function can still be written and read.
- The `Member`, `BookableResource`, `MeetingRoom`, and `Desk` classes let a booking point at a real member and resource. The booking service also uses the member and resource lookup methods.

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
| Other database constraint failure | 409 | Conflict | `The request conflicts with the stored data.` |
| Malformed JSON, wrong parameter type, unknown enum, or missing required query parameter | 400 | Bad Request | `The request is not valid. Check the JSON, the dates, and the required parameters.` |
| Unexpected server failure | 500 | Internal Server Error | `Something went wrong while handling the request.` |

Throw `BadRequestException` (400), `NotFoundException` (404), or `ConflictException` (409) from `com.coworkhub.exception`, and let `GlobalExceptionHandler` build this JSON. Do not invent a second shape.

Use field validation annotations with messages on request records and `@Valid` on request bodies. The handler returns one field error; when several fields are invalid, their reporting order is not specified. Subtype and booking checks belong in the services; no class-level validation is needed.

`BookingUpdateRequest` is checked in the service because editing and cancelling require different fields.

Editing a cancelled booking is also 400, message `A cancelled booking cannot be edited.`

## Members

| Method | Path | Success |
|---|---|---|
| GET | `/api/members` | 200 and the list |
| POST | `/api/members` | 201 and the new member |
| PUT | `/api/members/{id}` | 200 and the updated member |

There is no delete-member path. The update path supports editing a name or email if the member screen includes that action.

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

`fullName` and `email` must not be blank. The backend checks email format with `@Email`, not just the presence of `@`. Email uniqueness ignores case: `Maya@example.com` and `maya@example.com` belong to the same address for this check. Updating a member may keep that member's own email. Store names and emails as submitted, without trimming.

Field messages are `Full name is required.`, `Email is required.`, and `Email must be a valid address.`. The service checks duplicate emails and returns the 409 message above.

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

`name`, `location`, `capacity`, and `hourlyRate` are required. Names and locations must not be blank and are stored without trimming. On create, a missing or null `status` defaults to `ACTIVE`; otherwise it must be `ACTIVE` or `OUT_OF_SERVICE`. A room requires a Boolean `hasVideoConference` (false is valid). A desk requires nonblank `deskType` text; `STANDING` and `HOT_DESK` are examples, not a fixed list of allowed values.

`capacity` is a whole number of at least 1. A desk's capacity is exactly 1. Fractional capacity is rejected, not rounded or truncated. `hourlyRate` is zero or more.

An update sends all common fields, including `status`, plus the existing subtype's field. It is not a partial update. A room stays a room, and a desk stays a desk: the stored resource determines the type. For updates, a non-null `deskType` on a room or a non-null `hasVideoConference` on a desk is 400. `type` is a response field, not a field for changing a resource's type.

| Invalid field | Message |
|---|---|
| Blank or missing name | `Name is required.` |
| Blank or missing location | `Location is required.` |
| Missing capacity | `Capacity is required.` |
| Capacity below 1 | `Capacity must be at least 1.` |
| Desk capacity above 1 | `A desk must have capacity 1.` |
| Missing hourly rate | `Hourly rate is required.` |
| Negative hourly rate | `Hourly rate must be zero or more.` |
| Missing update status | `Status is required.` |
| Missing room video-conference field | `Video conference availability is required.` |
| Blank or missing desk type | `Desk type is required.` |
| Desk type supplied when updating a room | `A meeting room cannot have a desk type.` |
| Video-conference field supplied when updating a desk | `A desk cannot have video conference availability.` |

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

The resource list includes both `ACTIVE` and `OUT_OF_SERVICE` resources. Time-slot availability is checked by the separate availability endpoint.

## Bookings

The window sends who, which resource, when, and how many people. The server chooses `CONFIRMED` and calculates `totalCost`.

All five create fields shown below are required. `attendees` is a whole number. Missing member or resource IDs are 400; supplied IDs that do not exist are 404. Clients do not send `status` or `totalCost` on create.

Missing-ID messages are `Member ID is required.` and `Resource ID is required.`. Missing times use `The start time must be before the end time.`; missing attendees use `A booking must have at least one attendee.`.

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

Price is `hourlyRate × minutes / 60`, rounded to two decimals, halves rounded up. Use elapsed whole minutes (`Duration.between(start, end).toMinutes()`). Forty per hour for 90 minutes is `60.00`.

The server refuses the save when any of these is true:

- The end is not after the start. 400, `The start time must be before the end time.`
- Attendees is missing or under 1. 400, `A booking must have at least one attendee.`
- The resource is a desk and attendees is not exactly 1. 400, `A desk can only be booked for one attendee.`
- The resource is a room and attendees is over its capacity. 400, `The number of attendees exceeds this room's capacity.`
- The member or the resource does not exist. 404.
- The resource is `OUT_OF_SERVICE`. 409, `This resource is out of service and cannot be booked.`
- Another `CONFIRMED` booking on that resource overlaps. 409, `This resource already has a confirmed booking that overlaps the requested time.`

Overlap means the existing booking starts before the new end, and the existing booking ends after the new start. A booking that starts at the exact minute another ends is allowed. Cancelled bookings do not block a time slot. While editing, the booking being edited does not count as overlapping itself.

Edit request. Send all three fields:

```json
{
  "startDateTime": "2026-11-20T16:00:00",
  "endDateTime": "2026-11-20T17:00:00",
  "attendees": 3
}
```

The server keeps the same member and resource, runs the same time, attendee, resource-status, and overlap checks, and calculates `totalCost` again. Leave `status` out for an edit. For this API, a cancelled booking remains history and cannot be edited.

Cancel request:

```json
{
  "status": "CANCELLED"
}
```

The row stays in the list. That time is free for a new booking. The only status an update request may send is `CANCELLED`. Sending `CONFIRMED` is 400, `Only CANCELLED may be requested as a booking status.` A cancel changes only status; keep the member, resource, times, attendees, and total cost. Other edit fields are ignored on cancellation. Cancelling an already cancelled booking simply returns that booking unchanged.

`BookingService` calls `BookingResponse.from` and returns the flat response. The controller returns that result. Returning the database booking object directly would nest the whole member and resource, which is not this shape. A separate mapper class or framework is unnecessary.

## Availability

`GET /api/resources/available?start=2026-11-20T14:00:00&end=2026-11-20T16:00:00`

`start` and `end` are required. The same optional filters as `GET /api/resources` may be added.

Apply the same start-before-end check as booking creation. A search does not reserve anything; creating or editing a booking must check availability again before saving.

The response is 200 and a resource list in the resource shape above. Include a resource only when it is `ACTIVE` and no `CONFIRMED` booking overlaps that interval.

Put this path in its own class, `AvailabilityController`, in the booking package. The other `/api/resources` paths stay in the resource controller. Spring can serve both.

## Which code this lines up with

| Paper section | Who writes the server part | Who writes the screen |
|---|---|---|
| Members, and resources except availability | The backend foundation | Member and resource screens |
| Bookings and availability | Booking rules and endpoints | New-booking screen and bookings screen |
| The calls that send this JSON | The HTTP client | The screens call that client instead of keeping sample data |
