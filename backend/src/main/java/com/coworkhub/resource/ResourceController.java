// Owner: Erin
// What: HTTP endpoints for rooms and desks. See docs/API.md, section Resources.
//       Creation uses separate subtype endpoints, /rooms and /desks. Document that choice in the report.
// Checklist: POST /rooms and POST /desks return 201 with "type"; GET filters; PUT updates;
//            DELETE returns 204 or 409; missing id returns 404; missing fields return 400.
// Depends on: ResourceService. Jassem's resource screens and Yyan's ApiClient call these paths.
//
// GET /api/resources/available is not here. It lives in Amani's AvailabilityController.

package com.coworkhub.resource;

import java.math.BigDecimal;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
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
@RequestMapping("/api/resources")
public class ResourceController {

    private final ResourceService resourceService;

    public ResourceController(ResourceService resourceService) {
        this.resourceService = resourceService;
    }

    @GetMapping
    public List<BookableResource> list(
            @RequestParam(required = false) ResourceType type,
            @RequestParam(required = false) Integer minCapacity,
            @RequestParam(required = false) String location,
            @RequestParam(required = false) BigDecimal maxHourlyRate) {
        // TODO(Erin): Build a ResourceFilter from the four parameters and return resourceService.findResources.
        throw new UnsupportedOperationException("TODO(Erin): GET /api/resources");
    }

    @PostMapping("/rooms")
    @ResponseStatus(HttpStatus.CREATED)
    public MeetingRoom createRoom(@RequestBody RoomRequest request) {
        // TODO(Erin): Add @Valid before @RequestBody, then call resourceService.createRoom.
        throw new UnsupportedOperationException("TODO(Erin): POST /api/resources/rooms");
    }

    @PostMapping("/desks")
    @ResponseStatus(HttpStatus.CREATED)
    public Desk createDesk(@RequestBody DeskRequest request) {
        // TODO(Erin): Add @Valid before @RequestBody, then call resourceService.createDesk.
        throw new UnsupportedOperationException("TODO(Erin): POST /api/resources/desks");
    }

    @PutMapping("/{id}")
    public BookableResource update(@PathVariable Long id, @RequestBody ResourceUpdateRequest request) {
        // TODO(Erin): Add @Valid, then call resourceService.update. Status 200.
        throw new UnsupportedOperationException("TODO(Erin): PUT /api/resources/{id}");
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        // TODO(Erin): Call resourceService.delete. Status 204 with an empty body, or 409 from the service.
        throw new UnsupportedOperationException("TODO(Erin): DELETE /api/resources/{id}");
    }
}
