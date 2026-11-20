// Owner: Erin
// What: Throw this when a business rule rejects the input. GlobalExceptionHandler turns it into 400.
//       Used for end not after start, bad attendee counts, a desk with capacity other than 1,
//       and a cancel request with a status other than CANCELLED.
// Depends on: nothing. Amani throws it too.

package com.coworkhub.exception;

public class BadRequestException extends RuntimeException {

    public BadRequestException(String message) {
        super(message);
    }
}
