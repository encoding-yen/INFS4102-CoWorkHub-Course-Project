// Owner: Amani
// What: The JSON body for PUT /api/bookings/{id}. One endpoint does two jobs (docs/API.md, section Bookings):
//   Edit:   { "startDateTime": "...", "endDateTime": "...", "attendees": 3 }   status is null
//   Cancel: { "status": "CANCELLED" }                                          the other fields are ignored
// Depends on: BookingStatus (done).
//
// No @NotNull here, because each job leaves different fields empty. BookingService checks them instead.

package com.coworkhub.booking;

import java.time.LocalDateTime;

public record BookingUpdateRequest(
        LocalDateTime startDateTime,
        LocalDateTime endDateTime,
        Integer attendees,
        BookingStatus status) {
}
