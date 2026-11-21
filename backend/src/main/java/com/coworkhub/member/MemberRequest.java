// Owner: Erin
// What: The JSON body for POST /api/members and PUT /api/members/{id}. See docs/API.md, section Members.
//       { "fullName": "Maya Chen", "email": "maya@example.com" }
// Checklist: a body with missing required fields returns 400 with a readable message.
// Depends on: nothing.
//
// TODO(Erin): Add @NotBlank to fullName, and @NotBlank plus @Email to email, each with a readable message,
//             for example @NotBlank(message = "Full name is required.").
//             Use the messages in API.md. Keep the submitted values without trimming.

package com.coworkhub.member;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record MemberRequest(
        @NotBlank(message = "Full name is required.")
        String fullName,
        @NotBlank(message = "Email is required.")
        @Email(message = "Email must be a valid address.")
        String email) {
}
