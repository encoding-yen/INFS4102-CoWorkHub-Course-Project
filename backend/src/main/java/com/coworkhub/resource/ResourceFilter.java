// Owner: Erin
// What: The optional filters of GET /api/resources. Any field may be null, meaning "do not filter on this".
//       Amani's GET /api/resources/available reuses the same filters.
// Depends on: ResourceType (done).

package com.coworkhub.resource;

import java.math.BigDecimal;

public record ResourceFilter(
        ResourceType type,
        Integer minCapacity,
        String location,
        BigDecimal maxHourlyRate) {

    public boolean matches(BookableResource resource) {
        // TODO(Erin): Return true only when every non-null filter matches:
        //   type          MEETING_ROOM means resource instanceof MeetingRoom, DESK means instanceof Desk
        //   minCapacity   resource capacity >= minCapacity
        //   location      resource location contains this text, ignoring case
        //   maxHourlyRate resource hourlyRate <= maxHourlyRate (compare BigDecimal with compareTo)
        throw new UnsupportedOperationException("TODO(Erin): ResourceFilter.matches");
    }
}
