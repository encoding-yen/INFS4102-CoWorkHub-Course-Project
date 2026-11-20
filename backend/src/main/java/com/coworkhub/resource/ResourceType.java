// Owner: Erin
// What: The value of the type filter, GET /api/resources?type=MEETING_ROOM or ?type=DESK.
//       The same names appear as "type" in every resource JSON response.
// Checklist: an unknown type returns 400. Spring rejects a value that is not in this enum,
//            and GlobalExceptionHandler turns that into the 400 error shape.
// Depends on: nothing.

package com.coworkhub.resource;

public enum ResourceType {
    MEETING_ROOM,
    DESK
}
