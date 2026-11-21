// Owner: Amani
// What: A booking is CONFIRMED when created and CANCELLED when cancelled. There is no delete.
//       Only CONFIRMED bookings block a time slot. CANCELLED bookings stay visible in history.
// Depends on: nothing.

package com.coworkhub.booking;

public enum BookingStatus {
    CONFIRMED,
    CANCELLED
}
