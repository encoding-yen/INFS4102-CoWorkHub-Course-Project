// Owner: Amani
// What: The booking rules as plain Java on times and numbers. No database, no Spring.
// Checklist: overlap detected; back-to-back allowed; 90 minutes at 40 per hour costs 60.00;
//            end before start rejected; desk accepts exactly one attendee; room rejects attendees above capacity.
// Depends on: BadRequestException (Erin, done). Nothing else. START HERE TODAY.
// Used by: BookingService for creation, editing, and availability. Tested by BookingRulesTest.

package com.coworkhub.booking;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDateTime;

import com.coworkhub.exception.BadRequestException;

public final class BookingRules {

    private BookingRules() {
    }

    public static boolean overlaps(
            LocalDateTime existingStart,
            LocalDateTime existingEnd,
            LocalDateTime newStart,
            LocalDateTime newEnd) {
        // Overlap exists if existingStart < newEnd AND existingEnd > newStart (brief 3.4).
        //              A booking that starts at the exact minute another ends is NOT an overlap.
        return existingStart.isBefore(newEnd) && existingEnd.isAfter(newStart);
    }

    public static BigDecimal calculateTotalCost(BigDecimal hourlyRate, LocalDateTime start, LocalDateTime end) {
        // hourlyRate x minutes / 60, rounded to 2 decimals with RoundingMode.HALF_UP.
        //              Use Duration.between(start, end).toMinutes(). 40.00 for 90 minutes is 60.00.
        //              Put this pricing rule in your report note.
        long minutes = Duration.between(start, end).toMinutes();
        BigDecimal cost = hourlyRate.multiply(BigDecimal.valueOf(minutes));
        return cost.divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP);
    }
    

    public static void validateTimes(LocalDateTime start, LocalDateTime end) {
        // If start or end is null, or start is not before end, throw
        //              new BadRequestException("The start time must be before the end time.")
        if (start == null || end == null || !start.isBefore(end)) {
            throw new BadRequestException("The start time must be before the end time.");
        }
    }

    public static void validateAttendees(boolean isDesk, int capacity, Integer attendees) {
        // 
        //   attendees null or < 1          -> BadRequestException("A booking must have at least one attendee.")
        //   isDesk and attendees != 1       -> BadRequestException("A desk can only be booked for one attendee.")
        //   room and attendees > capacity   -> BadRequestException("The number of attendees exceeds this room's capacity.")
        if (attendees == null || attendees < 1) {
            throw new BadRequestException("A booking must have at least one attendee.");
        }
        if (isDesk && attendees != 1) {
            throw new BadRequestException("A desk can only be booked for one attendee.");
        }
        if (!isDesk && attendees > capacity) {
            throw new BadRequestException("The number of attendees exceeds this room's capacity.");
        }
    
    }
}
