// Owner: Amani
// What: HTTP endpoints for bookings. See docs/API.md, section Bookings.
// Checklist: POST returns 201; PUT edits or cancels; GET includes cancelled; GET ?memberId= filters;
//            there is no delete-booking endpoint.
// Depends on: BookingService. Jassem's booking screens and Yyan's ApiClient call these paths.
//
// Do NOT add a @DeleteMapping. Cancelling is a PUT with { "status": "CANCELLED" }.

package com.coworkhub.booking;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/bookings")
public class BookingController {

    private final BookingService bookingService;

    public BookingController(BookingService bookingService) {
        this.bookingService = bookingService;
    }

    @GetMapping
    public List<BookingResponse> list(@RequestParam(required = false) Long memberId) {
        // TODO(Amani): memberId null -> bookingService.findAll(); otherwise bookingService.findByMember(memberId).
        throw new UnsupportedOperationException("TODO(Amani): GET /api/bookings");
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public BookingResponse create(@RequestBody BookingCreateRequest request) {
        // TODO(Amani): Add @Valid before @RequestBody, then call bookingService.create.
        throw new UnsupportedOperationException("TODO(Amani): POST /api/bookings");
    }

    @PutMapping("/{id}")
    public BookingResponse update(@PathVariable Long id, @RequestBody BookingUpdateRequest request) {
        // TODO(Amani): Call bookingService.update. Status 200.
        throw new UnsupportedOperationException("TODO(Amani): PUT /api/bookings/{id}");
    }
}
