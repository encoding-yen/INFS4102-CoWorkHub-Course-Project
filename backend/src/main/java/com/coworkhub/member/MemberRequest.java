// Owner: Erin
// What: The JSON body for POST /api/members and PUT /api/members/{id}. See docs/API.md, section Members.
//       { "fullName": "Maya Chen", "email": "maya@example.com" }
// Checklist: a body with missing required fields returns 400 with a readable message.
// Depends on: nothing.
//
// TODO(Erin): Add @NotBlank to fullName, and @NotBlank plus @Email to email, each with a readable message,
//             for example @NotBlank(message = "Full name is required.").

package com.coworkhub.member;

public record MemberRequest(
        String fullName,
        String email) {
}
