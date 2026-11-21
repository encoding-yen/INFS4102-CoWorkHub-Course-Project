// Owner: Amani
// What: GET /api/resources/available?start=2026-11-20T14:00:00&end=2026-11-20T16:00:00
//       Same optional filters as GET /api/resources. See docs/API.md, section Availability.
// Checklist: returns only ACTIVE resources with no conflicting CONFIRMED booking for that interval.
// Depends on: BookingService.findAvailableResources; ResourceFilter (Erin, done).
//
// This lives in the booking package on purpose. Erin's ResourceController owns the other /api/resources paths.
// Both controllers can serve /api/resources because their HTTP method/path mappings are distinct.

package com.coworkhub.booking;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.coworkhub.resource.BookableResource;
import com.coworkhub.resource.ResourceFilter;
import com.coworkhub.resource.ResourceType;

@RestController
public class AvailabilityController {

    private final BookingService bookingService;

    public AvailabilityController(BookingService bookingService) {
        this.bookingService = bookingService;
    }

    @GetMapping("/api/resources/available")
    public List<BookableResource> available(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end,
            @RequestParam(required = false) ResourceType type,
            @RequestParam(required = false) Integer minCapacity,
            @RequestParam(required = false) String location,
            @RequestParam(required = false) BigDecimal maxHourlyRate) {
        //  Build a ResourceFilter from the four filters and return
        //              bookingService.findAvailableResources(start, end, filter).
        ResourceFilter filter = new ResourceFilter(type, minCapacity, location, maxHourlyRate);
        return bookingService.findAvailableResources(start, end, filter);
    }
}
