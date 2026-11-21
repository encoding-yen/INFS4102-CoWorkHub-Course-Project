// Owner: Amani
// What: The JSON body for POST /api/bookings. The client sends ids, never status or totalCost.
//       { "memberId": 1, "resourceId": 1, "startDateTime": "2026-11-20T14:00:00",
//         "endDateTime": "2026-11-20T15:30:00", "attendees": 4 }
// Depends on: nothing.
//
// TODO(Amani): Add @NotNull to every field and @Valid in the controller. Use field constraints only.
//             Messages: "Member ID is required.", "Resource ID is required.",
//             "The start time must be before the end time." on both times,
//             and "A booking must have at least one attendee." on attendees.
//             BookingRules checks time ordering and attendee limits with simple if statements.

package com.coworkhub.booking;

import java.time.LocalDateTime;

import jakarta.validation.constraints.NotNull;

public record BookingCreateRequest(
        @NotNull(message = "Member ID is required.") Long memberId,
        @NotNull(message = "Resource ID is required.") Long resourceId,
        @NotNull(message = "The start time must be before the end time.") LocalDateTime startDateTime,
        @NotNull(message = "The start time must be before the end time.") LocalDateTime endDateTime,
        @NotNull(message = "A booking must have at least one attendee.") Integer attendees) {
}
