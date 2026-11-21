// Owner: Amani
// What: Booking business logic. Every booking rule is enforced here, before anything is saved.
// Checklist: POST returns CONFIRMED with totalCost; missing member/resource 404; end before start 400;
//            desk/room attendee rules 400; overlap 409; back-to-back allowed; OUT_OF_SERVICE 409;
//            edit rechecks and ignores itself and recalculates totalCost; cancel keeps the row and frees the slot;
//            list includes cancelled bookings; memberId filter; availability search.
// Depends on:
//   BookingRules (Amani)                       start today
//   BookingRepository derived queries (Amani)  start today
//   MemberService.findById (Erin)              loads members or throws 404
//   ResourceService.findById/findResources (Erin) loads and filters resources
//   GlobalExceptionHandler (Erin)              builds the shared 400/404/409 responses

package com.coworkhub.booking;

import com.coworkhub.member.MemberService;
import com.coworkhub.resource.BookableResource;
import com.coworkhub.resource.ResourceFilter;
import com.coworkhub.resource.ResourceService;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class BookingService {

    private final BookingRepository bookingRepository;
    private final MemberService memberService;
    private final ResourceService resourceService;

    public BookingService(
            BookingRepository bookingRepository,
            MemberService memberService,
            ResourceService resourceService) {
        this.bookingRepository = bookingRepository;
        this.memberService = memberService;
        this.resourceService = resourceService;
    }

    public List<BookingResponse> findAll() {
        // TODO(Amani): Load every booking, CANCELLED included. Use a loop to build the response list
        //              with BookingResponse.from. The controller returns this list directly.
        throw new UnsupportedOperationException("TODO(Amani): BookingService.findAll");
    }

    public List<BookingResponse> findByMember(Long memberId) {
        // TODO(Amani): memberService.findById(memberId) first, so an unknown member gives 404.
        //              Then bookingRepository.findByMember_Id(memberId), mapped with BookingResponse.from.
        throw new UnsupportedOperationException("TODO(Amani): BookingService.findByMember");
    }

    public BookingResponse create(BookingCreateRequest request) {
        // TODO(Amani): Mark this method @Transactional. In this order:
        // 1. BookingRules.validateTimes(start, end)                              400
        // 2. memberService.findById(memberId)                                    404
        // 3. resourceService.findById(resourceId)                                404
        // 4. BookingRules.validateAttendees(resource instanceof Desk, capacity, attendees)   400
        // 5. resource status OUT_OF_SERVICE -> ConflictException("This resource is out of service and cannot be booked.")  409
        // 6. CONFIRMED overlap on this resource -> ConflictException(
        //       "This resource already has a confirmed booking that overlaps the requested time.")              409
        //    Use findByResource_IdAndStatus(resource id, CONFIRMED), then a loop calling BookingRules.overlaps.
        // 7. New Booking: member, resource, times, attendees, status CONFIRMED,
        //    totalCost = BookingRules.calculateTotalCost(resource hourlyRate, start, end). Save it.
        // 8. Return BookingResponse.from(saved).
        throw new UnsupportedOperationException("TODO(Amani): BookingService.create");
    }

    public BookingResponse update(Long id, BookingUpdateRequest request) {
        // TODO(Amani): Mark this method @Transactional. Load the booking (404 "Booking not found.").
        //
        // Cancel, when request.status() is not null:
        //   status must be CANCELLED, otherwise BadRequestException(
        //       "Only CANCELLED may be requested as a booking status.") (400).
        //   Set CANCELLED and keep every other field, including totalCost. Ignore edit fields in this request.
        //   Already CANCELLED can return unchanged. Only CONFIRMED bookings block a time slot.
        //
        // Edit, when request.status() is null:
        //   Editing a CANCELLED booking -> BadRequestException("A cancelled booking cannot be edited.") (400).
        //   Run the same checks as create: times, attendees, OUT_OF_SERVICE, overlap.
        //   For overlap, loop over this resource's CONFIRMED bookings, skip this booking's id,
        //   and call BookingRules.overlaps on the others. Keep the same member and resource.
        //   Recalculate totalCost. Save.
        //
        // Return BookingResponse.from(saved).
        throw new UnsupportedOperationException("TODO(Amani): BookingService.update");
    }

    public List<BookableResource> findAvailableResources(LocalDateTime start, LocalDateTime end, ResourceFilter filter) {
        // TODO(Amani):
        // 1. BookingRules.validateTimes(start, end)   400
        // 2. resourceService.findResources(filter)    Erin's filtered list
        // 3. Keep a resource only when it is ACTIVE and has no CONFIRMED booking overlapping [start, end).
        //    Loop over findByResource_IdAndStatus(resource id, CONFIRMED) and call BookingRules.overlaps.
        throw new UnsupportedOperationException("TODO(Amani): BookingService.findAvailableResources");
    }
}
