// Owner: Amani
// What: Tests for BookingRules. Plain JUnit, no database, so they run in under a second.
// Checklist: the automated tests cover each rejection; these results go in the report as testing evidence.
// Depends on: BookingRules (Amani). START HERE TODAY.
//
// Each test is disabled until written. Remove @Disabled, write the body, run ./mvnw test.
// Use assertTrue/assertFalse/assertEquals and assertThrows(BadRequestException.class, () -> ...).

package com.coworkhub.booking;

import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

class BookingRulesTest {

    @Test
    @Disabled("TODO(Amani)")
    void overlappingBookingsAreDetected() {
        // 14:00-15:30 existing, 15:00-16:00 new -> overlaps is true
    }

    @Test
    @Disabled("TODO(Amani)")
    void bookingInsideAnotherIsDetected() {
        // 14:00-17:00 existing, 15:00-16:00 new -> overlaps is true
    }

    @Test
    @Disabled("TODO(Amani)")
    void backToBackBookingsDoNotOverlap() {
        // 14:00-15:30 existing, 15:30-17:00 new -> overlaps is false
    }

    @Test
    @Disabled("TODO(Amani)")
    void ninetyMinutesAtFortyPerHourCostsSixty() {
        // calculateTotalCost(40.00, 14:00, 15:30) equals 60.00 (compare with compareTo or isEqualByComparingTo)
    }

    @Test
    @Disabled("TODO(Amani)")
    void endBeforeStartIsRejected() {
        // validateTimes(15:00, 14:00) throws BadRequestException
    }

    @Test
    @Disabled("TODO(Amani)")
    void endEqualToStartIsRejected() {
        // validateTimes(14:00, 14:00) throws BadRequestException
    }

    @Test
    @Disabled("TODO(Amani)")
    void deskAcceptsExactlyOneAttendee() {
        // validateAttendees(true, 1, 1) does not throw
    }

    @Test
    @Disabled("TODO(Amani)")
    void deskWithTwoAttendeesIsRejected() {
        // validateAttendees(true, 1, 2) throws BadRequestException
    }

    @Test
    @Disabled("TODO(Amani)")
    void roomOverCapacityIsRejected() {
        // validateAttendees(false, 8, 9) throws BadRequestException
    }

    @Test
    @Disabled("TODO(Amani)")
    void zeroAttendeesIsRejected() {
        // validateAttendees(false, 8, 0) throws BadRequestException
    }
}
