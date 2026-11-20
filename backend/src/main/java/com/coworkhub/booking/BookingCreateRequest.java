// Owner: Amani
// What: The JSON body for POST /api/bookings. The client sends ids, never status or totalCost.
//       { "memberId": 1, "resourceId": 1, "startDateTime": "2026-11-20T14:00:00",
//         "endDateTime": "2026-11-20T15:30:00", "attendees": 4 }
// Depends on: nothing.
//
// TODO(Amani): Add @NotNull to every field, with a readable message, and @Valid in the controller.

package com.coworkhub.booking;

import java.time.LocalDateTime;

public record BookingCreateRequest(
        Long memberId,
        Long resourceId,
        LocalDateTime startDateTime,
        LocalDateTime endDateTime,
        Integer attendees) {
}
