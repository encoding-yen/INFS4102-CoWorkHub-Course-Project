// Owner: Amani
// What: Reads and writes booking rows.
// Checklist: overlap check against CONFIRMED bookings only; edit ignores the booking being edited;
//            GET /api/bookings?memberId= returns only that member's bookings.
// Depends on: Booking (done).
//
// The brief says to add derived query methods only when the application needs them.
// TODO(Amani): Keep the three used queries below: member history, confirmed overlap,
//              and confirmed overlap excluding the booking being edited.
// BookingService uses the overlap queries for creation, editing, and availability.
// The predicate is existingStart < newEnd AND existingEnd > newStart, matching BookingRules.overlaps.
// StartDateTimeBefore takes newEnd; EndDateTimeAfter takes newStart. Only CONFIRMED bookings block.

package com.coworkhub.booking;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface BookingRepository extends JpaRepository<Booking, Long> {
    List<Booking> findByMember_Id(Long memberId);

    // Is there a CONFIRMED booking on this resource with existingStart < newEnd AND existingEnd > newStart?
    boolean existsByResource_IdAndStatusAndStartDateTimeBeforeAndEndDateTimeAfter(
            Long resourceId, BookingStatus status, LocalDateTime newEnd, LocalDateTime newStart);

    // Same check while editing, ignoring the booking being edited.
    boolean existsByResource_IdAndStatusAndStartDateTimeBeforeAndEndDateTimeAfterAndIdNot(
            Long resourceId, BookingStatus status, LocalDateTime newEnd, LocalDateTime newStart, Long bookingId);
}
