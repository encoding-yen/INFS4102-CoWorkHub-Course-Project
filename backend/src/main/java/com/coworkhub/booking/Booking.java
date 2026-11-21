// Owner: Amani
// What: The booking table. One reservation of one resource by one member.
// Checklist: a booking belongs to one member and one resource (@ManyToOne + @JoinColumn);
//            database-generated id; no-argument constructor.
// Depends on: Member and BookableResource (Erin, done).
//
// The database mapping below is already written so the server starts, because Erin's
// Member.bookings and BookableResource.bookings point at the fields named member and resource.
// Keep those two field names. Renaming them breaks Erin's mappedBy.
//
// TODO(Amani): Read this mapping until you can explain it: which column is the foreign key,
//              why this side has @JoinColumn, and why the other side uses mappedBy.
// TODO(Amani): Keep input validation in BookingCreateRequest and business checks in BookingService/BookingRules.
//              The required entity relationships and non-null database columns are already mapped here.
// Never return this class from a controller. Return BookingResponse instead, the flat JSON from docs/API.md.
// Lombok generates the getters, setters, and empty constructor. Do not switch this class to @Data.

package com.coworkhub.booking;

import com.coworkhub.member.Member;
import com.coworkhub.resource.BookableResource;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "booking")
@Getter
@Setter
@NoArgsConstructor
public class Booking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne(optional = false)
    @JoinColumn(name = "resource_id", nullable = false)
    private BookableResource resource;

    @Column(nullable = false)
    private LocalDateTime startDateTime;

    @Column(nullable = false)
    private LocalDateTime endDateTime;

    @Column(nullable = false)
    private Integer attendees;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private BookingStatus status;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal totalCost;
}
