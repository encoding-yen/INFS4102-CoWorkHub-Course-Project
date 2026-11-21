// Owner: Amani
// What: Tests for BookingService against an in-memory H2 database (src/test/resources/application.properties).
//       Each test runs in a transaction that is rolled back, so tests do not affect each other.
// Checklist: the automated tests cover each rejection; these results go in the report as testing evidence.
// Depends on: BookingService (Amani) AND Erin's MemberService/ResourceService being finished.
//             Run these once the services are available in your checkout; disabled tests prove no behavior.
//
// Set up data with the autowired repositories: save a Member, a MeetingRoom (capacity 8, 40.00/h, ACTIVE),
// and a Desk (capacity 1). Then call bookingService and assert on the result or assertThrows.

package com.coworkhub.booking;

import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@Transactional
class BookingServiceTest {

    @Autowired
    private BookingService bookingService;

    @Test
    @Disabled("TODO(Amani)")
    void createSetsConfirmedAndCalculatesTotalCost() {
        // Book the room 14:00-15:30 for 4 people -> status CONFIRMED, totalCost 60.00, id not null
    }

    @Test
    @Disabled("TODO(Amani)")
    void unknownMemberIsNotFound() {
        // memberId 999 -> NotFoundException
    }

    @Test
    @Disabled("TODO(Amani)")
    void unknownResourceIsNotFound() {
        // resourceId 999 -> NotFoundException
    }

    @Test
    @Disabled("TODO(Amani)")
    void overlappingConfirmedBookingIsRejected() {
        // Book 14:00-15:30, then 15:00-16:00 on the same room -> ConflictException
    }

    @Test
    @Disabled("TODO(Amani)")
    void backToBackBookingIsAllowed() {
        // Book 14:00-15:30, then 15:30-17:00 on the same room -> succeeds
    }

    @Test
    @Disabled("TODO(Amani)")
    void outOfServiceResourceIsRejected() {
        // Set the room OUT_OF_SERVICE, then book it -> ConflictException
    }

    @Test
    @Disabled("TODO(Amani)")
    void editIgnoresItselfAndRecalculatesTotalCost() {
        // Book 14:00-15:30, then edit the same booking to 14:30-16:30 -> succeeds, totalCost 80.00
    }

    @Test
    @Disabled("TODO(Amani)")
    void editIntoAnotherBookingIsRejected() {
        // Book A 14:00-15:00 and B 16:00-17:00, edit B to 14:30-15:30 -> ConflictException
    }

    @Test
    @Disabled("TODO(Amani)")
    void cancelKeepsTheRowAndFreesTheSlot() {
        // Book 14:00-15:30, cancel it -> status CANCELLED and still in findAll;
        // then book 14:00-15:30 again -> succeeds
    }

    @Test
    @Disabled("TODO(Amani)")
    void cancelWithStatusOtherThanCancelledIsRejected() {
        // update with status CONFIRMED -> BadRequestException
    }

    @Test
    @Disabled("TODO(Amani)")
    void findByMemberReturnsOnlyThatMembersBookings() {
        // Two members, one booking each -> findByMember returns one booking
    }

    @Test
    @Disabled("TODO(Amani)")
    void availabilityReturnsOnlyActiveResourcesWithoutConfirmedOverlap() {
        // Room booked 14:00-15:30, desk OUT_OF_SERVICE, second room free
        // -> findAvailableResources(14:00, 16:00, empty filter) returns only the second room
    }
}
