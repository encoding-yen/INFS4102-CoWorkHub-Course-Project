// Owner: Erin
// What: The one error JSON shape for the whole API. See docs/API.md, section Errors.
//       { "status": 409, "error": "Conflict", "message": "..." }
//       Jassem's screens show "message". Yyan's ApiException reads these three fields.
// Depends on: nothing.

package com.coworkhub.exception;

public record ApiError(int status, String error, String message) {
}
