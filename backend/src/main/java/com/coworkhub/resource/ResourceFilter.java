// Owner: Erin
// What: The optional filters of GET /api/resources. Any field may be null, meaning "do not filter on this".
//       Amani's GET /api/resources/available reuses the same filters.
// Depends on: ResourceType (done).

package com.coworkhub.resource;

import java.math.BigDecimal;
import java.util.Locale;

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
        if (type == ResourceType.MEETING_ROOM && !(resource instanceof MeetingRoom)) {
            return false;
        }
        if (type == ResourceType.DESK && !(resource instanceof Desk)) {
            return false;
        }
        if (minCapacity != null && resource.getCapacity() < minCapacity) {
            return false;
        }
        if (location != null && !resource.getLocation().toLowerCase(Locale.ROOT)
                .contains(location.toLowerCase(Locale.ROOT))) {
            return false;
        }
        if (maxHourlyRate != null && resource.getHourlyRate().compareTo(maxHourlyRate) > 0) {
            return false;
        }
        return true;
    }
}
