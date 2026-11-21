// Owner: Erin
// What: The member table. A customer who can make bookings.
// Checklist: database-generated id; no-argument constructor; unique email;
//            a member response does not contain an endlessly nested list of bookings.
// Depends on: nothing. Amani's Booking.member field points back at this class.
//
// The database mapping below is already written so the server starts.
// TODO(Erin): Add Bean Validation annotations: @NotBlank on fullName, @NotBlank and @Email on email.
// TODO(Erin): Be ready to explain @OneToMany(mappedBy = "member") and why @JsonIgnore stops the JSON loop.
// Lombok generates the getters, setters, and empty constructor. Do not switch this class to @Data.

package com.coworkhub.member;

import com.coworkhub.booking.Booking;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import java.util.ArrayList;
import java.util.List;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "member")
@Getter
@Setter
@NoArgsConstructor
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Full name is required.")
    @Column(nullable = false)
    private String fullName;

    @NotBlank(message = "Email is required.")
    @Email(message = "Email must be a valid address.")
    @Column(nullable = false, unique = true)
    private String email;

    @OneToMany(mappedBy = "member")
    @Getter(onMethod_ = @JsonIgnore)
    @Setter(AccessLevel.NONE)
    private List<Booking> bookings = new ArrayList<>();
}
