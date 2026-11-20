// Owner: Erin
// What: A desk. Its own row in the desk table holds the desk-only field;
//       the shared fields live in bookable_resource under the same id.
// Checklist: desks are distinguishable from rooms ("type": "DESK").
// Depends on: BookableResource (done).
// Rule owned by Amani: a desk accepts exactly one attendee.
//
// TODO(Erin): Add @NotBlank to deskType, for example "STANDING" or "HOT_DESK".

package com.coworkhub.resource;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "desk")
@Getter
@Setter
@NoArgsConstructor
public class Desk extends BookableResource {

    @Column(nullable = false)
    private String deskType;

    @Override
    public String getType() {
        return "DESK";
    }
}
