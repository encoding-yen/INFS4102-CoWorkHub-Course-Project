// Owner: Erin
// What: Room and desk business logic. ResourceController calls this class.
// Checklist: create rooms and desks; filter; update including OUT_OF_SERVICE;
//            delete only when the resource has zero bookings, otherwise 409; missing id gives 404.
// Depends on: BookableResourceRepository (done), ResourceFilter, the exception classes (done).
// Used by: Amani's BookingService calls findById, and her availability search calls findResources.

package com.coworkhub.resource;

import com.coworkhub.exception.NotFoundException;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class ResourceService {

    private final BookableResourceRepository resourceRepository;

    public ResourceService(BookableResourceRepository resourceRepository) {
        this.resourceRepository = resourceRepository;
    }

    public List<BookableResource> findResources(ResourceFilter filter) {
        // TODO(Erin): Return every resource for which filter.matches(resource) is true.
        throw new UnsupportedOperationException("TODO(Erin): ResourceService.findResources");
    }

    public BookableResource findById(Long id) {
        // TODO(Erin): Return the resource, or throw new NotFoundException("Resource not found.").
        // Amani's BookingService depends on this exact behaviour for the 404 on a booking.
        return resourceRepository.findById(id).orElseThrow(() -> new NotFoundException("Resource not found."));
    }

    public MeetingRoom createRoom(RoomRequest request) {
        // TODO(Erin): Copy the request into a new MeetingRoom. Use ACTIVE when status is null. Save and return it.
        throw new UnsupportedOperationException("TODO(Erin): ResourceService.createRoom");
    }

    public Desk createDesk(DeskRequest request) {
        // TODO(Erin): If capacity is not 1, throw new BadRequestException("A desk must have capacity 1.").
        //             Copy the request into a new Desk. Use ACTIVE when status is null. Save and return it.
        throw new UnsupportedOperationException("TODO(Erin): ResourceService.createDesk");
    }

    public BookableResource update(Long id, ResourceUpdateRequest request) {
        // TODO(Erin):
        // 1. Load the resource with findById (404 if missing).
        // 2. Copy name, location, capacity, hourlyRate, and status.
        // 3. If it is a MeetingRoom, hasVideoConference is required; if it is a Desk, deskType is required
        //    and capacity must stay 1. Wrong or missing subtype fields throw BadRequestException (400).
        // 4. Save and return it.
        throw new UnsupportedOperationException("TODO(Erin): ResourceService.update");
    }

    public void delete(Long id) {
        // TODO(Erin):
        // 1. Load the resource with findById (404 if missing).
        // 2. If resource.getBookings() is not empty, including cancelled bookings, throw
        //    new ConflictException("This resource has bookings and cannot be deleted. Set it to OUT_OF_SERVICE instead.")
        //    Mark this method @Transactional so the bookings list can be read.
        // 3. Otherwise delete it.
        throw new UnsupportedOperationException("TODO(Erin): ResourceService.delete");
    }
}
