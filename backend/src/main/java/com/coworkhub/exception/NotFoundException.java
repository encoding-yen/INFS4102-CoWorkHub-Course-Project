// Owner: Erin
// What: Throw this when an id does not exist. GlobalExceptionHandler turns it into 404.
//       Example: throw new NotFoundException("Member not found.");
// Depends on: nothing. Amani throws it too.

package com.coworkhub.exception;

public class NotFoundException extends RuntimeException {

    public NotFoundException(String message) {
        super(message);
    }
}
