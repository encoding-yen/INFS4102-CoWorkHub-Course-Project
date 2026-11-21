// Owner: Amani
// What: Tests for BookingRules. Plain JUnit, no database, so they run in under a second.
// Checklist: the automated tests cover each rejection; these results go in the report as testing evidence.
// Depends on: BookingRules (Amani).
//
// Run with ./mvnw test.

package com.coworkhub.booking;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import org.junit.jupiter.api.Test;

import com.coworkhub.exception.BadRequestException;

class BookingRulesTest {

    // All test times are on 20 November 2026.
    private LocalDateTime time(int hour, int minute) {
        return LocalDateTime.of(2026, 11, 20, hour, minute);
    }

    @Test
    void overlappingBookingsAreDetected() {
        // 14:00-15:30 existing, 15:00-16:00 new -> overlaps is true
        boolean result = BookingRules.overlaps(time(14, 0), time(15, 30), time(15, 0), time(16, 0));

        assertTrue(result);
    }

    @Test
    void bookingInsideAnotherIsDetected() {
        // 14:00-17:00 existing, 15:00-16:00 new -> overlaps is true
        boolean result = BookingRules.overlaps(time(14, 0), time(17, 0), time(15, 0), time(16, 0));

        assertTrue(result);
    }

    @Test
    void backToBackBookingsDoNotOverlap() {
        // 14:00-15:30 existing, 15:30-17:00 new -> overlaps is false
        boolean result = BookingRules.overlaps(time(14, 0), time(15, 30), time(15, 30), time(17, 0));

        assertFalse(result);
    }

    @Test
    void ninetyMinutesAtFortyPerHourCostsSixty() {
        // calculateTotalCost(40.00, 14:00, 15:30) equals 60.00
        BigDecimal cost = BookingRules.calculateTotalCost(new BigDecimal("40.00"), time(14, 0), time(15, 30));

        // compareTo is used so the test does not depend on the scale of the BigDecimal.
        assertEquals(0, cost.compareTo(new BigDecimal("60.00")));
    }

    @Test
    void endBeforeStartIsRejected() {
        // validateTimes(15:00, 14:00) throws BadRequestException
        assertThrows(BadRequestException.class,
                () -> BookingRules.validateTimes(time(15, 0), time(14, 0)));
    }

    @Test
    void endEqualToStartIsRejected() {
        // validateTimes(14:00, 14:00) throws BadRequestException
        assertThrows(BadRequestException.class,
                () -> BookingRules.validateTimes(time(14, 0), time(14, 0)));
    }

    @Test
    void deskAcceptsExactlyOneAttendee() {
        // validateAttendees(true, 1, 1) does not throw
        assertDoesNotThrow(() -> BookingRules.validateAttendees(true, 1, 1));
    }

    @Test
    void deskWithTwoAttendeesIsRejected() {
        // validateAttendees(true, 1, 2) throws BadRequestException
        assertThrows(BadRequestException.class,
                () -> BookingRules.validateAttendees(true, 1, 2));
    }

    @Test
    void roomOverCapacityIsRejected() {
        // validateAttendees(false, 8, 9) throws BadRequestException
        assertThrows(BadRequestException.class,
                () -> BookingRules.validateAttendees(false, 8, 9));
    }

    @Test
    void zeroAttendeesIsRejected() {
        // validateAttendees(false, 8, 0) throws BadRequestException
        assertThrows(BadRequestException.class,
                () -> BookingRules.validateAttendees(false, 8, 0));
    }
}