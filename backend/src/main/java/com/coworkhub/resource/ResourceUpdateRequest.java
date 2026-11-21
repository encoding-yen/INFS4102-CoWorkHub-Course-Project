// Owner: Erin
// What: The JSON body for PUT /api/resources/{id}. Send all common fields, including status.
//       Send hasVideoConference when the id is a room, and deskType when the id is a desk.
//       A room stays a room and a desk stays a desk.
// Checklist: PUT updates a resource, including a change to OUT_OF_SERVICE.
// Depends on: nothing.
//
// TODO(Erin): Add validation: @NotBlank name and location, @NotNull @Min(1) capacity,
//             @NotNull @DecimalMin("0.00") hourlyRate, @NotNull status.
//             ResourceService checks the field required by the stored subtype with simple if statements.

package com.coworkhub.resource;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public record ResourceUpdateRequest(
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
        @NotNull(message = "Status is required.")
        ResourceStatus status,
        Boolean hasVideoConference,
        String deskType) {
}
