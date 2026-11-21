// Owner: Erin
// What: Resource filtering, subtype rules, and deletion checks against the test H2 database.
// Depends on: ResourceService and the existing entity mappings; booking endpoints are not needed.

package com.coworkhub.resource;

import com.coworkhub.booking.Booking;
import com.coworkhub.booking.BookingStatus;
import com.coworkhub.exception.BadRequestException;
import com.coworkhub.exception.ConflictException;
import com.coworkhub.exception.NotFoundException;
import com.coworkhub.member.Member;
import jakarta.persistence.EntityManager;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
class ResourceServiceTest {

    @Autowired
    private ResourceService resourceService;

    @Autowired
    private EntityManager entityManager;

    @Test
    void createsBothSubtypesWithDefaultStatusAndUntrimmedNames() {
        MeetingRoom room = createRoom();
        Desk desk = createDesk();
        entityManager.flush();
        entityManager.clear();

        MeetingRoom savedRoom = (MeetingRoom) resourceService.findById(room.getId());
        Desk savedDesk = (Desk) resourceService.findById(desk.getId());
        assertEquals("MEETING_ROOM", savedRoom.getType());
        assertEquals(" Atlas Room ", savedRoom.getName());
        assertEquals(ResourceStatus.ACTIVE, savedRoom.getStatus());
        assertTrue(savedRoom.isHasVideoConference());
        assertEquals("DESK", savedDesk.getType());
        assertEquals(ResourceStatus.ACTIVE, savedDesk.getStatus());
        assertEquals("STANDING", savedDesk.getDeskType());
        assertEquals(1, savedDesk.getCapacity());
    }

    @Test
    void createPreservesExplicitStatusAndAcceptsZeroRate() {
        MeetingRoom room = resourceService.createRoom(new RoomRequest(
                "Room", "Floor 1", 1, BigDecimal.ZERO, ResourceStatus.OUT_OF_SERVICE, false));
        Desk desk = resourceService.createDesk(new DeskRequest(
                "Desk", "Floor 1", 1, BigDecimal.ZERO, ResourceStatus.OUT_OF_SERVICE, "HOT_DESK"));
        entityManager.flush();
        entityManager.clear();

        assertEquals(ResourceStatus.OUT_OF_SERVICE, resourceService.findById(room.getId()).getStatus());
        assertEquals(ResourceStatus.OUT_OF_SERVICE, resourceService.findById(desk.getId()).getStatus());
        assertEquals(0, resourceService.findById(desk.getId()).getHourlyRate().compareTo(BigDecimal.ZERO));
    }

    @Test
    void optionalFiltersCombineAndIncludeCapacityAndPriceBoundaries() {
        MeetingRoom room = createRoom();
        Desk desk = createDesk();
        assertEquals(2, resourceService.findResources(new ResourceFilter(null, null, null, null)).size());
        assertEquals(List.of(room), resourceService.findResources(
                new ResourceFilter(ResourceType.MEETING_ROOM, 8, "LoOr", new BigDecimal("40"))));
        assertEquals(List.of(desk), resourceService.findResources(
                new ResourceFilter(ResourceType.DESK, null, null, null)));
        assertTrue(resourceService.findResources(new ResourceFilter(null, 9, null, null)).isEmpty());
        assertTrue(resourceService.findResources(new ResourceFilter(null, null, "Roof", null)).isEmpty());
        assertEquals(List.of(desk), resourceService.findResources(
                new ResourceFilter(null, null, null, new BigDecimal("39.99"))));
        assertTrue(resourceService.findResources(
                new ResourceFilter(ResourceType.DESK, 2, "floor", new BigDecimal("50"))).isEmpty());
    }

    @Test
    void deskCreateRejectsMissingOrNonUnitCapacity() {
        Integer[] capacities = {null, 0, 2};
        for (Integer capacity : capacities) {
            BadRequestException error = assertThrows(BadRequestException.class,
                    () -> resourceService.createDesk(new DeskRequest(
                            "Desk", "Floor 1", capacity, BigDecimal.ONE, null, "STANDING")));
            assertEquals("A desk must have capacity 1.", error.getMessage());
        }
    }

    @Test
    void updatesBothSubtypesAndCanRetireResources() {
        MeetingRoom room = createRoom();
        Desk desk = createDesk();
        resourceService.update(room.getId(), new ResourceUpdateRequest(
                " Updated room ", "Floor 3", 4, new BigDecimal("25"),
                ResourceStatus.OUT_OF_SERVICE, false, null));
        resourceService.update(desk.getId(), new ResourceUpdateRequest(
                "Updated desk", "Floor 3", 1, new BigDecimal("10"),
                ResourceStatus.OUT_OF_SERVICE, null, "HOT_DESK"));
        entityManager.flush();
        entityManager.clear();

        MeetingRoom savedRoom = (MeetingRoom) resourceService.findById(room.getId());
        Desk savedDesk = (Desk) resourceService.findById(desk.getId());
        assertEquals(" Updated room ", savedRoom.getName());
        assertEquals("Floor 3", savedRoom.getLocation());
        assertEquals(4, savedRoom.getCapacity());
        assertEquals(0, savedRoom.getHourlyRate().compareTo(new BigDecimal("25")));
        assertFalse(savedRoom.isHasVideoConference());
        assertEquals(ResourceStatus.OUT_OF_SERVICE, savedRoom.getStatus());
        assertEquals("HOT_DESK", savedDesk.getDeskType());
        assertEquals(ResourceStatus.OUT_OF_SERVICE, savedDesk.getStatus());
    }

    @Test
    void roomUpdateRejectsMissingOrWrongSubtypeFieldsWithoutChangingTheRoom() {
        MeetingRoom room = createRoom();
        assertThrows(BadRequestException.class, () -> resourceService.update(room.getId(),
                updateRequest(8, null, null)));
        assertThrows(BadRequestException.class, () -> resourceService.update(room.getId(),
                updateRequest(8, false, "STANDING")));
        assertEquals(" Atlas Room ", room.getName());
        assertTrue(room.isHasVideoConference());
    }

    @Test
    void deskUpdateRejectsMissingOrWrongSubtypeFieldsAndNonUnitCapacity() {
        Desk desk = createDesk();
        String[] deskTypes = {null, "", "  "};
        for (String deskType : deskTypes) {
            assertThrows(BadRequestException.class, () -> resourceService.update(desk.getId(),
                    updateRequest(1, null, deskType)));
        }
        assertThrows(BadRequestException.class, () -> resourceService.update(desk.getId(),
                updateRequest(1, false, "STANDING")));
        BadRequestException error = assertThrows(BadRequestException.class,
                () -> resourceService.update(desk.getId(), updateRequest(2, null, "STANDING")));
        assertEquals("A desk must have capacity 1.", error.getMessage());
        assertEquals(1, desk.getCapacity());
    }

    @Test
    void deletesBothSubtypesWhenTheyHaveNoBookings() {
        MeetingRoom room = createRoom();
        Desk desk = createDesk();
        resourceService.delete(room.getId());
        resourceService.delete(desk.getId());
        entityManager.flush();
        entityManager.clear();

        assertThrows(NotFoundException.class, () -> resourceService.findById(room.getId()));
        assertThrows(NotFoundException.class, () -> resourceService.findById(desk.getId()));
        assertTrue(resourceService.findResources(new ResourceFilter(null, null, null, null)).isEmpty());
    }

    @ParameterizedTest
    @EnumSource(BookingStatus.class)
    void anyHistoricalBookingPreventsDeletion(BookingStatus status) {
        MeetingRoom room = createRoom();
        Member member = new Member();
        member.setFullName("Maya Chen");
        member.setEmail("maya@example.com");
        entityManager.persist(member);
        Booking booking = new Booking();
        booking.setMember(member);
        booking.setResource(room);
        booking.setStartDateTime(LocalDateTime.of(2020, 1, 1, 14, 0));
        booking.setEndDateTime(LocalDateTime.of(2020, 1, 1, 15, 0));
        booking.setAttendees(1);
        booking.setStatus(status);
        booking.setTotalCost(new BigDecimal("40.00"));
        entityManager.persist(booking);
        entityManager.flush();
        entityManager.clear();

        ConflictException error = assertThrows(ConflictException.class,
                () -> resourceService.delete(room.getId()));
        assertEquals("This resource has bookings and cannot be deleted. Set it to OUT_OF_SERVICE instead.",
                error.getMessage());
        assertNotNull(resourceService.findById(room.getId()));
        assertNotNull(entityManager.find(Booking.class, booking.getId()));
    }

    @Test
    void missingResourceUpdateAndDeleteUseTheContractMessage() {
        NotFoundException updateError = assertThrows(NotFoundException.class,
                () -> resourceService.update(-1L, updateRequest(8, true, null)));
        NotFoundException deleteError = assertThrows(NotFoundException.class, () -> resourceService.delete(-1L));
        assertEquals("Resource not found.", updateError.getMessage());
        assertEquals("Resource not found.", deleteError.getMessage());
    }

    private MeetingRoom createRoom() {
        return resourceService.createRoom(new RoomRequest(
                " Atlas Room ", "Floor 2", 8, new BigDecimal("40.00"), null, true));
    }

    private Desk createDesk() {
        return resourceService.createDesk(new DeskRequest(
                "Desk D4", "Floor 1", 1, new BigDecimal("8.00"), null, "STANDING"));
    }

    private ResourceUpdateRequest updateRequest(Integer capacity, Boolean videoConference, String deskType) {
        return new ResourceUpdateRequest("Updated", "Floor 2", capacity, new BigDecimal("40.00"),
                ResourceStatus.ACTIVE, videoConference, deskType);
    }
}
