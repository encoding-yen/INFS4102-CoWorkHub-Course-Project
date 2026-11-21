// Owner: Amani
// What: Reads and writes booking rows.
// Checklist: overlap check against CONFIRMED bookings only; edit ignores the booking being edited;
//            GET /api/bookings?memberId= returns only that member's bookings.
// Depends on: Booking (done).
//
// The brief says to add derived query methods only when the application needs them.
// TODO(Amani): Add these two derived queries. Spring turns them into SQL automatically:
//
//   List<Booking> findByMember_Id(Long memberId);
//
//   List<Booking> findByResource_IdAndStatus(Long resourceId, BookingStatus status);
//
// BookingService loads CONFIRMED bookings for a resource and loops through them using BookingRules.overlaps.
// On edit, skip the booking whose id equals the id being edited. Reuse this approach for availability.
// No separate overlap query or ...AndIdNot query is needed for this basic implementation.

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
