// Owner: Erin
// What: The JSON body for POST /api/resources/rooms. See docs/API.md, section Resources.
// Checklist: missing fields return 400 with a readable message.
// Depends on: nothing.
//
// TODO(Erin): Add validation: @NotBlank name and location, @NotNull @Min(1) capacity,
//             @NotNull @DecimalMin("0.00") hourlyRate, @NotNull hasVideoConference.
//             status may be null on create; the service stores ACTIVE in that case.

package com.coworkhub.resource;

import java.math.BigDecimal;

public record RoomRequest(
        String name,
        String location,
        Integer capacity,
        BigDecimal hourlyRate,
        ResourceStatus status,
        Boolean hasVideoConference) {
}
