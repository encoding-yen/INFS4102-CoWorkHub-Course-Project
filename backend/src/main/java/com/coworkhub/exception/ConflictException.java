// Owner: Erin
// What: Throw this when a request clashes with existing data. GlobalExceptionHandler turns it into 409.
//       Used for a duplicate email, deleting a resource with bookings, an overlapping booking,
//       and booking an OUT_OF_SERVICE resource.
// Depends on: nothing. Amani throws it too.

package com.coworkhub.exception;

public class ConflictException extends RuntimeException {

    public ConflictException(String message) {
        super(message);
    }
}
