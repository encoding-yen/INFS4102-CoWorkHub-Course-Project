// Owner: Amani
// What: The booking rules as plain Java on times and numbers. No database, no Spring.
// Checklist: overlap detected; back-to-back allowed; 90 minutes at 40 per hour costs 60.00;
//            end before start rejected; desk accepts exactly one attendee; room rejects attendees above capacity.
// Depends on: BadRequestException (Erin, done). Nothing else. START HERE TODAY.
// Used by: BookingService for creation, editing, and availability. Tested by BookingRulesTest.

package com.coworkhub.booking;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public final class BookingRules {

    private BookingRules() {
    }

    public static boolean overlaps(
            LocalDateTime existingStart,
            LocalDateTime existingEnd,
            LocalDateTime newStart,
            LocalDateTime newEnd) {
        // TODO(Amani): Overlap exists if existingStart < newEnd AND existingEnd > newStart (brief 3.4).
        //              A booking that starts at the exact minute another ends is NOT an overlap.
        //              The service supplies CONFIRMED bookings only and skips the edited booking's own id.
        throw new UnsupportedOperationException("TODO(Amani): BookingRules.overlaps");
    }

    public static BigDecimal calculateTotalCost(BigDecimal hourlyRate, LocalDateTime start, LocalDateTime end) {
        // TODO(Amani): hourlyRate x minutes / 60, rounded to 2 decimals with RoundingMode.HALF_UP.
        //              Use Duration.between(start, end).toMinutes(). 40.00 for 90 minutes is 60.00.
        //              Put this pricing rule in your report note.
        throw new UnsupportedOperationException("TODO(Amani): BookingRules.calculateTotalCost");
    }

    public static void validateTimes(LocalDateTime start, LocalDateTime end) {
        // TODO(Amani): If start or end is null, or start is not before end, throw
        //              new BadRequestException("The start time must be before the end time.")
        throw new UnsupportedOperationException("TODO(Amani): BookingRules.validateTimes");
    }

    public static void validateAttendees(boolean isDesk, int capacity, Integer attendees) {
        // TODO(Amani):
        //   attendees null or < 1          -> BadRequestException("A booking must have at least one attendee.")
        //   isDesk and attendees != 1       -> BadRequestException("A desk can only be booked for one attendee.")
        //   room and attendees > capacity   -> BadRequestException("The number of attendees exceeds this room's capacity.")
        throw new UnsupportedOperationException("TODO(Amani): BookingRules.validateAttendees");
    }
}
