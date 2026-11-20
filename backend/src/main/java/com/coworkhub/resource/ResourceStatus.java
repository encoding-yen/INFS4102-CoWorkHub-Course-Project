// Owner: Erin
// What: Whether a room or desk can be booked at all. Being free at a certain time is not a status;
//       Amani's availability search works that out from bookings.
// Depends on: nothing.

package com.coworkhub.resource;

public enum ResourceStatus {
    ACTIVE,
    OUT_OF_SERVICE
}
