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

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import com.coworkhub.exception.BadRequestException;
import com.coworkhub.exception.ConflictException;
import com.coworkhub.exception.NotFoundException;
import com.coworkhub.member.Member;
import com.coworkhub.member.MemberService;
import com.coworkhub.resource.BookableResource;
import com.coworkhub.resource.Desk;
import com.coworkhub.resource.ResourceFilter;
import com.coworkhub.resource.ResourceService;
import com.coworkhub.resource.ResourceStatus;


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
        // Load every booking, CANCELLED included. Use a loop to build the response list
        //              with BookingResponse.from. The controller returns this list directly.
        // Every booking, CANCELLED included, mapped with BookingResponse.from.
        List<Booking> bookings = bookingRepository.findAll();
        return toResponseList(bookings);

    }

    public List<BookingResponse> findByMember(Long memberId) {
        // memberService.findById(memberId) first, so an unknown member gives 404.
        //              Then bookingRepository.findByMember_Id(memberId), mapped with BookingResponse.from.
        memberService.findById(memberId);
        List<Booking> bookings = bookingRepository.findByMember_Id(memberId);
        return toResponseList(bookings);
    }

    @Transactional(isolation = Isolation.READ_COMMITTED)
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
        LocalDateTime start = request.startDateTime();
        LocalDateTime end = request.endDateTime();

        // 1. Times (400)
        BookingRules.validateTimes(start, end);
        bookingRepository.lockResourceById(request.resourceId());

        // 2. and 3. Member and resource must exist (404)
        Member member = memberService.findById(request.memberId());
        BookableResource resource = resourceService.findById(request.resourceId());

        // 4. 5. 6. Attendees (400), out of service (409), overlap (409)
        checkResourceRules(resource, start, end, request.attendees(), null);

        // 7. Build and save the booking
        Booking booking = new Booking();
        booking.setMember(member);
        booking.setResource(resource);
        booking.setStartDateTime(start);
        booking.setEndDateTime(end);
        booking.setAttendees(request.attendees());
        booking.setStatus(BookingStatus.CONFIRMED);
        booking.setTotalCost(BookingRules.calculateTotalCost(resource.getHourlyRate(), start, end));
        Booking saved = bookingRepository.save(booking);

        // 8. Return the flat response
        return BookingResponse.from(saved);
    }

    @Transactional(isolation = Isolation.READ_COMMITTED)
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
        Optional<Booking> found = bookingRepository.findById(id);
        if (found.isEmpty()) {
            throw new NotFoundException("Booking not found.");
        }
        Booking booking = found.get();

        // Cancel: the status field is present. The other fields are ignored.
        if (request.status() != null) {
            if (request.status() != BookingStatus.CANCELLED) {
                throw new BadRequestException("The status can only be changed to CANCELLED.");
            }
            booking.setStatus(BookingStatus.CANCELLED);
            Booking cancelled = bookingRepository.save(booking);
            return BookingResponse.from(cancelled);
        }

        // Edit: the status field is missing.
        if (booking.getStatus() == BookingStatus.CANCELLED) {
            throw new BadRequestException("A cancelled booking cannot be edited.");
        }

        LocalDateTime start = request.startDateTime();
        LocalDateTime end = request.endDateTime();
        BookingRules.validateTimes(start, end);

        BookableResource resource = booking.getResource();
        bookingRepository.lockResourceById(resource.getId());
        // Pass this booking's id so the overlap check ignores the booking itself.
        checkResourceRules(resource, start, end, request.attendees(), booking.getId());

        booking.setStartDateTime(start);
        booking.setEndDateTime(end);
        booking.setAttendees(request.attendees());
        booking.setTotalCost(BookingRules.calculateTotalCost(resource.getHourlyRate(), start, end));
        Booking saved = bookingRepository.save(booking);
        return BookingResponse.from(saved);
    }

    public List<BookableResource> findAvailableResources(LocalDateTime start, LocalDateTime end, ResourceFilter filter) {
        // TODO(Amani):
        // 1. BookingRules.validateTimes(start, end)   400
        // 2. resourceService.findResources(filter)    Erin's filtered list
        // 3. Keep a resource only when it is ACTIVE and has no CONFIRMED booking overlapping [start, end).
        //    Loop over findByResource_IdAndStatus(resource id, CONFIRMED) and call BookingRules.overlaps.
        // 1. Times (400)
        BookingRules.validateTimes(start, end);

        // 2. Erin's filtered list
        List<BookableResource> candidates = resourceService.findResources(filter);

        // 3. Keep a resource only when it is ACTIVE and has no CONFIRMED overlapping booking.
        List<BookableResource> available = new ArrayList<>();
        for (BookableResource resource : candidates) {
            if (resource.getStatus() == ResourceStatus.ACTIVE) {
                boolean booked = bookingRepository.existsByResource_IdAndStatusAndStartDateTimeBeforeAndEndDateTimeAfter(
                        resource.getId(), BookingStatus.CONFIRMED, end, start);
                if (!booked) {
                    available.add(resource);
                }
            }
        }
        return available;
    }

    // The checks shared by create and edit, in the order from the brief:
    // attendees (400), out of service (409), overlap with a CONFIRMED booking (409).
    // bookingIdToIgnore is null when creating, and the booking's own id when editing.
    private void checkResourceRules(
            BookableResource resource,
            LocalDateTime start,
            LocalDateTime end,
            Integer attendees,
            Long bookingIdToIgnore) {

        boolean isDesk = resource instanceof Desk;
        BookingRules.validateAttendees(isDesk, resource.getCapacity(), attendees);

        if (resource.getStatus() == ResourceStatus.OUT_OF_SERVICE) {
            throw new ConflictException("This resource is out of service and cannot be booked.");
        }

        boolean overlap;
        if (bookingIdToIgnore == null) {
            overlap = bookingRepository.existsByResource_IdAndStatusAndStartDateTimeBeforeAndEndDateTimeAfter(
                    resource.getId(), BookingStatus.CONFIRMED, end, start);
        } else {
            overlap = bookingRepository.existsByResource_IdAndStatusAndStartDateTimeBeforeAndEndDateTimeAfterAndIdNot(
                    resource.getId(), BookingStatus.CONFIRMED, end, start, bookingIdToIgnore);
        }
        if (overlap) {
            throw new ConflictException(
                    "This resource already has a confirmed booking that overlaps the requested time.");
        }
    }

    private List<BookingResponse> toResponseList(List<Booking> bookings) {
        List<BookingResponse> responses = new ArrayList<>();
        for (Booking booking : bookings) {
            responses.add(BookingResponse.from(booking));
        }
        return responses;
    }

}
