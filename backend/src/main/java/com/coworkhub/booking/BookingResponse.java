// Owner: Amani
// What: The flat booking JSON every booking endpoint returns. See docs/API.md, section Bookings.
//       Returning Booking directly would nest the whole member and resource. This record avoids that.
// Depends on: Booking (done). Jassem's Booking model and Yyan's ApiClient read these exact field names.

package com.coworkhub.booking;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record BookingResponse(
        Long id,
        Long memberId,
        String memberName,
        Long resourceId,
        String resourceName,
        LocalDateTime startDateTime,
        LocalDateTime endDateTime,
        Integer attendees,
        BookingStatus status,
        BigDecimal totalCost) {

    public static BookingResponse from(Booking booking) {
        // TODO(Amani): Copy the fields. memberId and memberName come from booking.getMember();
        //              resourceId and resourceName come from booking.getResource().
        throw new UnsupportedOperationException("TODO(Amani): BookingResponse.from");
    }
}
