// Owner: Erin
// What: The JSON body for POST /api/resources/desks. See docs/API.md, section Resources.
// Checklist: missing fields return 400 with a readable message.
// Depends on: nothing.
//
// TODO(Erin): Add validation: @NotBlank name, location, and deskType, @NotNull @Min(1) capacity,
//             @NotNull @DecimalMin("0.00") hourlyRate.
//             A desk's capacity must be 1. Check that in ResourceService and throw BadRequestException if not.
//             status may be null on create; the service stores ACTIVE in that case.

package com.coworkhub.resource;

import java.math.BigDecimal;

public record DeskRequest(
        String name,
        String location,
        Integer capacity,
        BigDecimal hourlyRate,
        ResourceStatus status,
        String deskType) {
}
