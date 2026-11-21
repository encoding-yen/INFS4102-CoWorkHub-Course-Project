# Demo and Q&A

Owner: everyone. The individual Q&A is 25 points and is graded per person. Saying "I only worked on the backend" or "I only worked on the frontend" is not enough.

## Live demo script

TODO(everyone): Decide who presents which step. Every member must speak.

1. Problem and architecture, using the report's diagram.
2. Run `docker compose up --build` and show the backend and PostgreSQL containers running.
3. Open the Flutter desktop app.
4. Create a member, then a meeting room.
5. Book the room from 14:00 to 15:30 for 4 people. Show the server-calculated total.
6. Create a second, adjacent booking from 15:30 to 16:30. Then try editing it to 15:00–16:00. Show the backend's overlap message in Flutter. This uses the normal edit form even though availability search hides already-booked time slots.
7. Cancel the first booking. Show it still appears in the bookings list as CANCELLED.
8. Book 14:00 to 15:30 again. It now succeeds because the cancelled booking no longer blocks the slot.
9. Try to delete the room. Show the 409 message, then set the room to OUT_OF_SERVICE instead.
10. Run `docker compose down`, then `docker compose up` again. Show that the data is still there.

## Trace one booking through every layer

Everyone should be able to explain each step from memory.

1. `frontend/lib/screens/new_booking_screen.dart`: `submit` validates the form and calls the ApiClient.
2. `frontend/lib/services/api_client.dart`: `createBooking` sends `POST /api/bookings` with JSON.
3. `backend/.../booking/BookingController.java`: `create` receives the JSON as `BookingCreateRequest`.
4. `backend/.../booking/BookingService.java`: `create` runs every rule, loads the member and resource, and calculates the price.
5. `backend/.../booking/BookingRepository.java`: check for an overlapping CONFIRMED booking with the derived existence query; the service calls `save` if allowed. Editing uses the query ending in `AndIdNot` to exclude the edited booking.
6. Database: one new row in the `booking` table, with `member_id` and `resource_id` as foreign keys.
7. Back up the layers: `BookingResponse` is turned into JSON, then `Booking.fromJson` in Dart, then the screen shows the total.
8. For a rejected booking: `ConflictException` → `GlobalExceptionHandler` → 409 JSON → `ApiException` → error message on screen.

## Practice changes

Practice each one in a part you did not write. These match the brief's examples of live Q&A tasks.

- Change one validation message, for example the desk attendee message.
- Add a small repository filter, for example find members whose name contains some text.
- Fix a status code, for example change one endpoint's success status.
- Add a field to a Dart model and show it on a screen.
- Explain what a Docker environment variable does, and why the backend depends on the database service.
- Explain why a specific booking was rejected.

TODO(everyone): Practice tracing a request and making a small change before the individual Q&A. These are practice suggestions, not a required count of extra features.
