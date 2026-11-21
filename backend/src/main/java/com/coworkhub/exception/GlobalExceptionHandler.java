// Owner: Erin
// What: Turns every exception into the ApiError JSON shape with the right status code.
//       Controllers and services never build error responses themselves; they throw.
// Checklist: missing id gives 404; missing required fields give 400 with a readable message;
//            invalid operations return appropriate status codes and useful messages (brief 3.4).
// Depends on: ApiError and the three exception classes (done).
// Used by: every controller, including Amani's. Amani's 400/404/409 responses only work once this is done,
//          so finish it early.

package com.coworkhub.exception;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<ApiError> handleNotFound(NotFoundException exception) {
        // TODO(Erin): Return status 404 with new ApiError(404, "Not Found", exception.getMessage()).
        return ResponseEntity.status(404).body(new ApiError(404, "Not Found", exception.getMessage()));
    }

    @ExceptionHandler(ConflictException.class)
    public ResponseEntity<ApiError> handleConflict(ConflictException exception) {
        // TODO(Erin): Return status 409 with new ApiError(409, "Conflict", exception.getMessage()).
        return ResponseEntity.status(409).body(new ApiError(409, "Conflict", exception.getMessage()));
    }

    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<ApiError> handleBadRequest(BadRequestException exception) {
        // TODO(Erin): Return status 400 with new ApiError(400, "Bad Request", exception.getMessage()).
        return ResponseEntity.status(400).body(new ApiError(400, "Bad Request", exception.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiError> handleValidation(MethodArgumentNotValidException exception) {
        // TODO(Erin): A @Valid body failed. Return 400 with a readable sentence.
        String message = exception.getBindingResult().getFieldError().getDefaultMessage();
        return ResponseEntity.status(400).body(new ApiError(400, "Bad Request", message));
    }

    @ExceptionHandler({
        HttpMessageNotReadableException.class,
        MethodArgumentTypeMismatchException.class,
        MissingServletRequestParameterException.class
    })
    public ResponseEntity<ApiError> handleUnreadableRequest(Exception exception) {
        // TODO(Erin): Broken JSON, a bad date such as "2026-13-40T99:00", an unknown enum such as type=CHAIR,
        //             or a missing required query parameter such as start. Return 400 with a short message.
        return ResponseEntity.status(400).body(new ApiError(400, "Bad Request",
                "The request is not valid. Check the JSON, the dates, and the required parameters."));
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ApiError> handleDataIntegrity(DataIntegrityViolationException exception) {
        // TODO(Erin): The database refused a save, usually the unique email constraint.
        //             Return 409 with "A member with this email already exists." or a general conflict message.
        return ResponseEntity.status(409).body(new ApiError(409, "Conflict", "A member with this email already exists."));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiError> handleUnexpected(Exception exception) {
        // TODO(Erin): Anything else. Return 500 with "Something went wrong while handling the request."
        //             Do not send the Java stack trace to the client.
        return ResponseEntity.status(500).body(new ApiError(500, "Internal Server Error",
                "Something went wrong while handling the request."));
    }
}
