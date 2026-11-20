// Owner: Amani
// What: Reads and writes booking rows.
// Checklist: overlap check against CONFIRMED bookings only; edit ignores the booking being edited;
//            GET /api/bookings?memberId= returns only that member's bookings.
// Depends on: Booking (done).
//
// The brief says to add derived query methods only when the application needs them.
// TODO(Amani): Add the derived queries you use. Suggested names, which Spring turns into SQL automatically:
//
//   List<Booking> findByMember_Id(Long memberId);
//
//   // Is there a CONFIRMED booking on this resource with existingStart < newEnd AND existingEnd > newStart?
//   boolean existsByResource_IdAndStatusAndStartDateTimeBeforeAndEndDateTimeAfter(
//           Long resourceId, BookingStatus status, LocalDateTime newEnd, LocalDateTime newStart);
//
//   // Same check while editing, ignoring the booking being edited.
//   boolean existsByResource_IdAndStatusAndStartDateTimeBeforeAndEndDateTimeAfterAndIdNot(
//           Long resourceId, BookingStatus status, LocalDateTime newEnd, LocalDateTime newStart, Long bookingId);
//
// Note the argument order: StartDateTimeBefore takes newEnd, EndDateTimeAfter takes newStart.

package com.coworkhub.booking;

import org.springframework.data.jpa.repository.JpaRepository;

public interface BookingRepository extends JpaRepository<Booking, Long> {
}
