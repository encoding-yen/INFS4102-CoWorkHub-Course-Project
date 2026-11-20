// Owner: Erin
// What: The JSON body for PUT /api/resources/{id}. Same fields as create.
//       Send hasVideoConference when the id is a room, and deskType when the id is a desk.
//       A room stays a room and a desk stays a desk.
// Checklist: PUT updates a resource, including a change to OUT_OF_SERVICE.
// Depends on: nothing.
//
// TODO(Erin): Add validation: @NotBlank name and location, @NotNull @Min(1) capacity,
//             @NotNull @DecimalMin("0.00") hourlyRate, @NotNull status.

package com.coworkhub.resource;

import java.math.BigDecimal;

public record ResourceUpdateRequest(
        String name,
        String location,
        Integer capacity,
        BigDecimal hourlyRate,
        ResourceStatus status,
        Boolean hasVideoConference,
        String deskType) {
}
