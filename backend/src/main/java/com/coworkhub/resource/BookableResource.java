// Owner: Erin
// What: The shared part of every room and desk, stored in the bookable_resource table.
// Checklist: JPA inheritance (JOINED); database-generated id; no-argument constructor;
//            JSON includes "type": "MEETING_ROOM" or "DESK" plus name, location, capacity, hourlyRate, status;
//            a resource response does not contain an endlessly nested list of bookings.
// Depends on: nothing. Amani's Booking.resource field points back at this class.
//
// The database mapping below is already written so the server starts.
//
// Why JOINED, for the report: rooms and desks share most columns but each has its own extra field.
// JOINED keeps the shared columns in one table and each extra field in its own table,
// so there are no empty columns for the other subtype and every booking can point at one resource id.
//
// TODO(Erin): Add Bean Validation annotations: @NotBlank name and location, @NotNull @Min(1) capacity,
//             @NotNull @DecimalMin("0.00") hourlyRate, @NotNull status.
// TODO(Erin): Write the short report note that explains JOINED and lists the member and resource endpoints.
// Lombok generates the getters, setters, and empty constructor. Do not switch this class to @Data.

package com.coworkhub.resource;

import com.coworkhub.booking.Booking;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Inheritance;
import jakarta.persistence.InheritanceType;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "bookable_resource")
@Inheritance(strategy = InheritanceType.JOINED)
@Getter
@Setter
@NoArgsConstructor
public abstract class BookableResource {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String location;

    @Column(nullable = false)
    private Integer capacity;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal hourlyRate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ResourceStatus status = ResourceStatus.ACTIVE;

    @OneToMany(mappedBy = "resource")
    @Getter(onMethod_ = @JsonIgnore)
    @Setter(AccessLevel.NONE)
    private List<Booking> bookings = new ArrayList<>();

    // Each subclass returns its own name. Jackson writes this as the "type" field in JSON.
    public abstract String getType();
}
