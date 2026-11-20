// Owner: Erin
// What: A meeting room. Its own row in the meeting_room table holds the room-only field;
//       the shared fields live in bookable_resource under the same id.
// Checklist: rooms are distinguishable from desks ("type": "MEETING_ROOM").
// Depends on: BookableResource (done).
// Rule owned by Amani: attendees cannot exceed a room's capacity.

package com.coworkhub.resource;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "meeting_room")
@Getter
@Setter
@NoArgsConstructor
public class MeetingRoom extends BookableResource {

    @Column(nullable = false)
    private boolean hasVideoConference;

    @Override
    public String getType() {
        return "MEETING_ROOM";
    }
}
