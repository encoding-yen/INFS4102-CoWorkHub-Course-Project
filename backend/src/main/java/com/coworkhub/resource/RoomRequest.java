// Owner: Erin
// What: The JSON body for POST /api/resources/rooms. See docs/API.md, section Resources.
// Checklist: missing fields return 400 with a readable message.
// Depends on: nothing.
//
// TODO(Erin): Add validation: @NotBlank name and location, @NotNull @Min(1) capacity,
//             @NotNull @DecimalMin("0.00") hourlyRate, @NotNull hasVideoConference.
//             status may be null on create; the service stores ACTIVE in that case.

package com.coworkhub.resource;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public record RoomRequest(
        @NotBlank(message = "Name is required.")
        String name,
        @NotBlank(message = "Location is required.")
        String location,
        @NotNull(message = "Capacity is required.")
        @Min(value = 1, message = "Capacity must be at least 1.")
        Integer capacity,
        @NotNull(message = "Hourly rate is required.")
        @DecimalMin(value = "0.00", message = "Hourly rate must be zero or more.")
        BigDecimal hourlyRate,
        ResourceStatus status,
        @NotNull(message = "Video conference availability is required.")
        Boolean hasVideoConference) {
}
