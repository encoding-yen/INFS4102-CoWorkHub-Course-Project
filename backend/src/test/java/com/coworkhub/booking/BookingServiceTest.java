// Owner: Amani
// What: Tests for BookingService against an in-memory H2 database (src/test/resources/application.properties).
//       Each test runs in a transaction that is rolled back, so tests do not affect each other.
// Checklist: the automated tests cover each rejection; these results go in the report as testing evidence.
// Depends on: BookingService (Amani) AND Erin's MemberService/ResourceService being finished.

package com.coworkhub.booking;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.coworkhub.exception.BadRequestException;
import com.coworkhub.exception.ConflictException;
import com.coworkhub.exception.NotFoundException;
import com.coworkhub.member.Member;
import com.coworkhub.member.MemberRepository;
import com.coworkhub.resource.BookableResource;
import com.coworkhub.resource.BookableResourceRepository;
import com.coworkhub.resource.Desk;
import com.coworkhub.resource.MeetingRoom;
import com.coworkhub.resource.ResourceFilter;
import com.coworkhub.resource.ResourceStatus;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@Transactional
class BookingServiceTest {

    @Autowired
    private BookingService bookingService;

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private BookableResourceRepository resourceRepository;

    private Member member;
    private MeetingRoom room;
    private Desk desk;

    @BeforeEach
    void setUp() {
        member = new Member();
        member.setFullName("Test Member");
        member.setEmail("test.member@example.com");
        memberRepository.save(member);

        room = new MeetingRoom();
        room.setName("Test Room");
        room.setLocation("Floor 1");
        room.setCapacity(8);
        room.setHourlyRate(new BigDecimal("40.00"));
        room.setStatus(ResourceStatus.ACTIVE);
        resourceRepository.save(room);

        desk = new Desk();
        desk.setName("Test Desk");
        desk.setLocation("Floor 1");
        desk.setCapacity(1);
        desk.setHourlyRate(new BigDecimal("10.00"));
        desk.setStatus(ResourceStatus.ACTIVE);
        desk.setDeskType("HOT_DESK");
        resourceRepository.save(desk);
    }

    // All test bookings are on 20 November 2026.
    private LocalDateTime time(int hour, int minute) {
        return LocalDateTime.of(2026, 11, 20, hour, minute);
    }

    private BookingResponse bookRoom(LocalDateTime start, LocalDateTime end, int attendees) {
        BookingCreateRequest request = new BookingCreateRequest(
                member.getId(), room.getId(), start, end, attendees);
        return bookingService.create(request);
    }

    @Test
    void createSetsConfirmedAndCalculatesTotalCost() {
        BookingResponse response = bookRoom(time(14, 0), time(15, 30), 4);

        assertNotNull(response.id());
        assertEquals(BookingStatus.CONFIRMED, response.status());
        assertEquals(new BigDecimal("60.00"), response.totalCost());
    }

    @Test
    void unknownMemberIsNotFound() {
        BookingCreateRequest request = new BookingCreateRequest(
                999L, room.getId(), time(14, 0), time(15, 30), 4);

        assertThrows(NotFoundException.class, () -> bookingService.create(request));
    }

    @Test
    void unknownResourceIsNotFound() {
        BookingCreateRequest request = new BookingCreateRequest(
                member.getId(), 999L, time(14, 0), time(15, 30), 4);

        assertThrows(NotFoundException.class, () -> bookingService.create(request));
    }

    @Test
    void endBeforeStartIsRejected() {
        BookingCreateRequest request = new BookingCreateRequest(
                member.getId(), room.getId(), time(15, 0), time(14, 0), 4);

        assertThrows(BadRequestException.class, () -> bookingService.create(request));
    }

    @Test
    void deskAttendeeRuleIsEnforced() {
        // Exactly one attendee is accepted.
        BookingCreateRequest oneAttendee = new BookingCreateRequest(
                member.getId(), desk.getId(), time(14, 0), time(15, 0), 1);
        BookingResponse response = bookingService.create(oneAttendee);
        assertNotNull(response.id());

        // Two attendees are rejected.
        BookingCreateRequest twoAttendees = new BookingCreateRequest(
                member.getId(), desk.getId(), time(16, 0), time(17, 0), 2);
        assertThrows(BadRequestException.class, () -> bookingService.create(twoAttendees));
    }

    @Test
    void roomCapacityRuleIsEnforced() {
        // Exactly the capacity (8) is accepted.
        BookingResponse response = bookRoom(time(14, 0), time(15, 0), 8);
        assertNotNull(response.id());

        // One above the capacity (9) is rejected.
        BookingCreateRequest tooMany = new BookingCreateRequest(
                member.getId(), room.getId(), time(16, 0), time(17, 0), 9);
        assertThrows(BadRequestException.class, () -> bookingService.create(tooMany));
    }

    @Test
    void overlappingConfirmedBookingIsRejected() {
        bookRoom(time(14, 0), time(15, 30), 4);

        BookingCreateRequest overlapping = new BookingCreateRequest(
                member.getId(), room.getId(), time(15, 0), time(16, 0), 4);
        assertThrows(ConflictException.class, () -> bookingService.create(overlapping));
    }

    @Test
    void backToBackBookingIsAllowed() {
        bookRoom(time(14, 0), time(15, 30), 4);

        BookingResponse second = bookRoom(time(15, 30), time(17, 0), 4);
        assertNotNull(second.id());
    }

    @Test
    void outOfServiceResourceIsRejected() {
        room.setStatus(ResourceStatus.OUT_OF_SERVICE);
        resourceRepository.save(room);

        BookingCreateRequest request = new BookingCreateRequest(
                member.getId(), room.getId(), time(14, 0), time(15, 30), 4);
        assertThrows(ConflictException.class, () -> bookingService.create(request));
    }

    @Test
    void editIgnoresItselfAndRecalculatesTotalCost() {
        BookingResponse created = bookRoom(time(14, 0), time(15, 30), 4);

        // 14:30-16:30 overlaps the booking's own old time, which must be ignored.
        BookingUpdateRequest edit = new BookingUpdateRequest(time(14, 30), time(16, 30), 4, null);
        BookingResponse updated = bookingService.update(created.id(), edit);

        assertEquals(new BigDecimal("80.00"), updated.totalCost());
        assertEquals(BookingStatus.CONFIRMED, updated.status());
    }

    @Test
    void editIntoAnotherBookingIsRejected() {
        bookRoom(time(14, 0), time(15, 0), 4);
        BookingResponse bookingB = bookRoom(time(16, 0), time(17, 0), 4);

        BookingUpdateRequest edit = new BookingUpdateRequest(time(14, 30), time(15, 30), 4, null);
        assertThrows(ConflictException.class, () -> bookingService.update(bookingB.id(), edit));
    }

    @Test
    void cancelKeepsTheRowAndFreesTheSlot() {
        BookingResponse created = bookRoom(time(14, 0), time(15, 30), 4);

        BookingUpdateRequest cancel = new BookingUpdateRequest(null, null, null, BookingStatus.CANCELLED);
        BookingResponse cancelled = bookingService.update(created.id(), cancel);
        assertEquals(BookingStatus.CANCELLED, cancelled.status());

        // The cancelled booking is still in the list.
        List<BookingResponse> all = bookingService.findAll();
        boolean found = false;
        for (BookingResponse booking : all) {
            if (booking.id().equals(created.id())) {
                found = true;
            }
        }
        assertTrue(found);

        // The same slot can be booked again.
        BookingResponse again = bookRoom(time(14, 0), time(15, 30), 4);
        assertNotNull(again.id());
    }

    @Test
    void cancelWithStatusOtherThanCancelledIsRejected() {
        BookingResponse created = bookRoom(time(14, 0), time(15, 30), 4);

        BookingUpdateRequest request = new BookingUpdateRequest(null, null, null, BookingStatus.CONFIRMED);
        BadRequestException error = assertThrows(BadRequestException.class,
                () -> bookingService.update(created.id(), request));
        assertEquals("Only CANCELLED may be requested as a booking status.", error.getMessage());
    }

    @Test
    void findByMemberReturnsOnlyThatMembersBookings() {
        Member other = new Member();
        other.setFullName("Other Member");
        other.setEmail("other.member@example.com");
        memberRepository.save(other);

        bookRoom(time(14, 0), time(15, 0), 4);
        BookingCreateRequest otherRequest = new BookingCreateRequest(
                other.getId(), room.getId(), time(16, 0), time(17, 0), 4);
        bookingService.create(otherRequest);

        List<BookingResponse> result = bookingService.findByMember(member.getId());

        assertEquals(1, result.size());
        assertEquals(member.getId(), result.get(0).memberId());
    }

    @Test
    void availabilityReturnsOnlyActiveResourcesWithoutConfirmedOverlap() {
        // The first room is booked 14:00-15:30.
        bookRoom(time(14, 0), time(15, 30), 4);

        // The desk is out of service.
        desk.setStatus(ResourceStatus.OUT_OF_SERVICE);
        resourceRepository.save(desk);

        // The second room is free.
        MeetingRoom freeRoom = new MeetingRoom();
        freeRoom.setName("Free Room");
        freeRoom.setLocation("Floor 2");
        freeRoom.setCapacity(6);
        freeRoom.setHourlyRate(new BigDecimal("30.00"));
        freeRoom.setStatus(ResourceStatus.ACTIVE);
        resourceRepository.save(freeRoom);

        ResourceFilter emptyFilter = new ResourceFilter(null, null, null, null);
        List<BookableResource> available =
                bookingService.findAvailableResources(time(14, 0), time(16, 0), emptyFilter);

        assertTrue(containsResource(available, freeRoom.getId()));
        assertFalse(containsResource(available, room.getId()));
        assertFalse(containsResource(available, desk.getId()));
    }

    private boolean containsResource(List<BookableResource> resources, Long id) {
        for (BookableResource resource : resources) {
            if (resource.getId().equals(id)) {
                return true;
            }
        }
        return false;
    }
}
