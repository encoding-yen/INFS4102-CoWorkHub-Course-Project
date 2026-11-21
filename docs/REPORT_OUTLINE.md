# Report outline

Owner: Yyan assembles `TeamName_Project_Report.pdf`. Each section lists who writes it.

Target length: about 5 to 6 pages. Clear content matters more than length.

TODO(Yyan): Agree a date with everyone for their sections, then assemble, export to PDF, and check every section below is present.

| # | Section | Writer | What it must contain |
|---|---|---|---|
| 1 | Project overview and business problem | Yyan | What a coworking space needs: browse rooms and desks, check availability, book, cancel, and avoid double bookings |
| 2 | System architecture diagram | Erin | Flutter UI → HTTP/JSON → Controller → Service → Repository → database, plus Docker around the backend and PostgreSQL |
| 3 | Domain model or ER diagram | Erin | member, bookable_resource, meeting_room, desk, booking; one-to-many from member and resource to booking; JOINED inheritance and why it was chosen |
| 4 | REST API summary | Erin (members, resources), Amani (bookings, availability) | Main endpoints, methods, and status codes. Note the separate room/desk creation paths; API.md holds the full contract |
| 5 | Business rules and how they are enforced | Amani | Overlap formula, back-to-back allowed, start before end, desk one attendee, room capacity, OUT_OF_SERVICE, cancel frees the slot, pricing rule, where each rule lives in code |
| 6 | Flutter screen captures of the main workflow | Jassem | Capture the working UI, for example resources, a successful booking with price, a rejected booking, and booking history; no fixed screenshot count |
| 7 | Docker and deployment | Yyan | Compose services, environment variables, named volume, `ddl-auto=update`, the exact start command |
| 8 | Testing evidence and important error cases | Amani (automated tests), everyone (manual checks) | Test results from `./mvnw test`, and curl or Swagger results for 400, 404, and 409 cases |
| 9 | Team contribution table | Yyan | Every member's name and what they built |
| 10 | AI and tool usage declaration | everyone | Which tools were used and how. Using AI does not remove the requirement to understand every submitted file |

TODO(Erin): Sections 2, 3, and the member and resource half of 4.
TODO(Amani): Section 5, the booking half of 4, and the automated test half of 8.
TODO(Jassem): Section 6.
TODO(Yyan): Sections 1, 7, and 9, and assembling the PDF.
TODO(everyone): Section 10, and your own manual checks for section 8.
