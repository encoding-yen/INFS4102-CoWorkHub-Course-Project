# CoWorkHub task index

Every file in the project has a header with its owner, what it does, the checklist items it covers, and what it waits on. Inside the file, each piece of work is marked `TODO(Name)`.

Find your TODOs:

```bash
grep -rn "TODO(Erin)"   backend frontend docs README.md docker-compose.yml .env.example
grep -rn "TODO(Amani)"  backend
grep -rn "TODO(Jassem)" frontend
grep -rn "TODO(Yyan)"   .
```

The shared contract is [API.md](API.md). Field names, paths, status codes, and error messages come from there.

## What is already done

Nobody has to write these, but everyone must be able to explain them in the Q&A.

- `backend/pom.xml`, the Maven wrapper, and `application.properties`. The server starts with `./mvnw spring-boot:run`.
- Database mapping on `Member`, `BookableResource`, `MeetingRoom`, `Desk`, and `Booking`: JOINED inheritance, generated ids, Lombok `@NoArgsConstructor`, `@ManyToOne` and `@JoinColumn` on the booking, `@OneToMany(mappedBy)` on member and resource, and `@JsonIgnore` on the two bookings lists. Lombok `@Getter` and `@Setter` generate the accessors. Use those, never `@Data`, because `@Data` loops through the two-way booking relationship.
- Route annotations on every controller method. `http://localhost:8080/swagger-ui.html` lists every endpoint. Calling one returns an error until its TODO is done.
- The exception classes and `ApiError`. The handler methods inside `GlobalExceptionHandler` are still TODO.
- Flutter: the `http` package, the macOS network permission, the model fields, sample data, and an app that opens a placeholder window.

## Order of work and dependencies

```mermaid
flowchart LR
  apiNote[docs/API.md] --> erinWork[Erin: services, controllers, error handler]
  apiNote --> amaniRules[Amani: BookingRules and its tests]
  apiNote --> jassemScreens[Jassem: screens on sample data]
  apiNote --> yyanStart[Yyan: ApiClient, Dockerfile, Compose]
  erinWork --> amaniService[Amani: BookingService, controllers, service tests]
  amaniRules --> amaniService
  erinWork --> yyanLive[Yyan: ApiClient tested against the server]
  amaniService --> yyanLive
  yyanLive --> jassemLive[Jassem: screens switched to ApiClient]
  jassemLive --> everyone[Everyone: screenshots, report, demo]
```

### Erin, backend foundation

Nothing blocks Erin. Amani's service waits on steps 1 and 2, so do those first.

1. `exception/GlobalExceptionHandler.java`: all handler bodies. Every 400, 404, and 409 in the project depends on this.
2. `member/MemberService.findById` and `resource/ResourceService.findById`. Amani's booking code calls both.
3. `member/`: `MemberRepository` derived query, `MemberRequest` validation, `MemberService`, `MemberController` with `@Valid`.
4. `resource/`: `ResourceFilter.matches`, request validation, `ResourceService`, `ResourceController` with `@Valid`.
5. Bean Validation annotations on `Member`, `BookableResource`, and `Desk`.
6. Check each item with curl or Swagger, as listed in the checklist below.
7. Report note: why JOINED, and the member and resource endpoints with their status codes.

### Amani, booking rules and endpoints

1. Start today: `booking/BookingRules.java` and `src/test/.../BookingRulesTest.java`. These need nothing from anyone.
2. Start today: `booking/BookingRepository.java` derived queries, `BookingResponse.from`, and validation on `BookingCreateRequest`.
3. After Erin's step 2: `booking/BookingService.java`, then `BookingController.java` and `AvailabilityController.java`.
4. After Erin's step 1: confirm the 400, 404, and 409 responses with curl.
5. After step 3: `src/test/.../BookingServiceTest.java`.
6. Report note: the pricing rule, the status codes, and the test results for the rejected cases.

### Jassem, Flutter screens

1. Start today: `fromJson` in `lib/models/`, then every screen in `lib/screens/` and every widget in `lib/widgets/`, using `lib/models/sample_data.dart`.
2. Start today: the navigation in `lib/main.dart`.
3. After Yyan's ApiClient works: replace the sample data with ApiClient calls on every screen, add loading, success, and error states, and refresh after each save.
4. Delete `lib/models/sample_data.dart`.
5. Take the screen captures for the report.

### Yyan, connection, Docker, and submission

1. Start today: `frontend/lib/services/api_client.dart`, every method written against API.md.
2. Start today: `backend/Dockerfile`, `docker-compose.yml`, and `.env.example`. The server already starts, so Docker can be tested now.
3. After Erin's and Amani's controllers work: test each ApiClient method against the running server.
4. `README.md`: team names and the exact run steps, tested on a machine without PostgreSQL.
5. Collect everyone's report sections into `TeamName_Project_Report.pdf`, using [REPORT_OUTLINE.md](REPORT_OUTLINE.md).
6. Build `TeamName_Project.zip` without generated folders.

### Everyone

Use [DEMO_AND_QA.md](DEMO_AND_QA.md). Each person writes the report section for their own part and practices tracing one booking through every layer.

## Delegation sheet checklist mapped to files

### Erin

| Checklist item | Where |
|---|---|
| POST /api/members returns 201 and a database-generated id | `MemberController.create`, `MemberService.create` |
| POST of that same email returns 409 | `MemberService.create`, `MemberRepository`, `GlobalExceptionHandler.handleConflict` |
| GET /api/members lists members | `MemberController.list` |
| PUT /api/members/{id} updates a member | `MemberController.update`, `MemberService.update` |
| POST /api/resources/rooms and /desks return 201 with "type" and the fields | `ResourceController`, `ResourceService.createRoom` and `createDesk`; `type` comes from the `getType()` method in each subclass |
| GET /api/resources filters by type, minimum capacity, location, maximum price | `ResourceController.list`, `ResourceFilter.matches` |
| PUT /api/resources/{id} updates, including OUT_OF_SERVICE | `ResourceService.update` |
| DELETE succeeds only with zero bookings | `ResourceService.delete` |
| DELETE returns 409 with any booking, including cancelled | `ResourceService.delete` |
| Missing id 404; missing fields 400 with a readable message | `findById` methods, `@Valid`, `GlobalExceptionHandler` |
| No endlessly nested list of bookings | Done: `@JsonIgnore` on `Member.bookings` and `BookableResource.bookings` |
| Rows survive a restart with ddl-auto=update | Done: `application.properties` |
| Report note on JOINED and endpoints | Explanation at the top of `BookableResource.java` |

### Amani

| Checklist item | Where |
|---|---|
| POST /api/bookings returns 201, CONFIRMED, totalCost set by the server | `BookingController.create`, `BookingService.create` |
| 90 minutes at 40 per hour costs 60.00 | `BookingRules.calculateTotalCost`, `BookingRulesTest` |
| End before start returns 400 | `BookingRules.validateTimes` |
| Missing member or resource returns 404 | `BookingService.create` calls Erin's `findById` |
| A desk accepts one attendee only | `BookingRules.validateAttendees` |
| A room rejects attendees above capacity | `BookingRules.validateAttendees` |
| Overlapping CONFIRMED bookings return 409 | `BookingRules.overlaps`, `BookingRepository`, `BookingService.create` |
| Back-to-back booking allowed | `BookingRules.overlaps` |
| Edit rechecks, ignores itself, recalculates totalCost | `BookingService.update`, `...AndIdNot` query |
| OUT_OF_SERVICE resource cannot be booked | `BookingService.create` and `update` |
| Cancel keeps the row and frees the time | `BookingService.update`; only CONFIRMED is checked for overlap |
| GET /api/bookings shows cancelled bookings | `BookingService.findAll` |
| GET /api/bookings?memberId= returns that member's bookings | `BookingService.findByMember` |
| GET /api/resources/available returns ACTIVE, conflict-free resources | `AvailabilityController`, `BookingService.findAvailableResources` |
| No delete-booking endpoint | `BookingController` has no `@DeleteMapping` |
| Automated tests cover each rejection | `BookingRulesTest`, `BookingServiceTest` |
| Report note: pricing, status codes, test results | `BookingRules.calculateTotalCost` comment and the test output |

### Jassem

| Checklist item | Where |
|---|---|
| Home navigation and summary counts | `main.dart`, `home_screen.dart` |
| Resource list separates rooms and desks with every required field | `resources_screen.dart` |
| Resource list filters; details can be opened | `resource_filter_bar.dart`, `ResourcesScreen.showDetails` |
| Create and update a room, a desk, and a member; set OUT_OF_SERVICE | `resource_form_screen.dart`, `member_form_screen.dart` |
| Deleting a resource with bookings shows the server's 409 message | `ResourcesScreen.deleteResource` |
| New booking collects all fields and shows availability results | `new_booking_screen.dart` |
| Form blocks empty name, empty email, end before start, empty attendees | the validators in each form screen |
| Bookings screen shows current, past, and cancelled bookings with status and cost | `bookings_screen.dart`, `Booking.isPast` |
| Bookings can be edited and cancelled | `BookingsScreen.editBooking` and `cancelBooking`, `booking_edit_screen.dart` |
| Choosing a member shows that member's bookings | `MembersScreen.selectMember` |
| Loading, then success or the server's error message | `loading_view.dart`, `error_view.dart`, `feedback.dart` |
| List refreshes after create, update, or cancel | each screen reloads when its form returns `true` |
| Ordinary Flutter desktop widgets, no OS-specific code | all of `lib/` |

### Yyan

| Checklist item | Where |
|---|---|
| ApiClient is the only HTTP caller, async/await, GET/POST/PUT/DELETE for every endpoint | `lib/services/api_client.dart` |
| Dart models match the JSON | `lib/models/` compared with API.md |
| Multi-stage Dockerfile that builds from source without target/ | `backend/Dockerfile`, `backend/.dockerignore` |
| Compose: backend and PostgreSQL, environment variables, named volume | `docker-compose.yml` |
| ddl-auto=update in Docker | Done in `application.properties`; Compose must not override it |
| .env.example has placeholders only | `.env.example` |
| README names everyone and gives exact run steps | `README.md` |
| Clean machine: copy .env, compose up, curl /api/resources returns a list | test after Erin's resource controller works |
| compose down then up keeps the data | named volume in `docker-compose.yml` |
| .gitignore excludes target, build, .dart_tool, .env | Done: `.gitignore` |
| ZIP contents without generated folders | submission step |
| PDF report sections | `docs/REPORT_OUTLINE.md` |

### Everyone

| Checklist item | Where |
|---|---|
| Live demo: Docker start, one successful booking with price, one rejected overlap shown in the window | `docs/DEMO_AND_QA.md` |
| Every member speaks | `docs/DEMO_AND_QA.md` |
| Every member can trace a booking from Flutter to the database | `docs/DEMO_AND_QA.md`, trace section |
| Every member can make a small change in code they did not write | `docs/DEMO_AND_QA.md`, practice changes |
| Every member named in README and contribution table | `README.md`, `docs/REPORT_OUTLINE.md` |

## Brief requirements mapped to files

| Brief section | Requirement | Where | Owner |
|---|---|---|---|
| 1 | Separate UI, HTTP, business logic, data access, and database layers | `screens/` → `api_client.dart` → `*Controller` → `*Service` → `*Repository` → database | all |
| 2 | JPA inheritance with a justified strategy | `BookableResource.java` | Erin |
| 2 | Booking belongs to one member and one resource with `@ManyToOne` and `@JoinColumn` | `Booking.java` | Amani |
| 2 | One-to-many with `mappedBy` | `Member.java`, `BookableResource.java` | Erin |
| 2 | Generated ids, no-argument constructors | every entity | Erin, Amani |
| 2 | JpaRepository, derived queries only when needed | `*Repository.java` | Erin, Amani |
| 2 | Jackson annotations against circular JSON | `@JsonIgnore` on the bookings lists; flat `BookingResponse` | Erin, Amani |
| 3.1 | Display all resources, rooms distinguished from desks | `ResourceController.list`, `resources_screen.dart` | Erin, Jassem |
| 3.1 | Create, update, delete resources; reject delete with any booking | `ResourceService`, `resource_form_screen.dart` | Erin, Jassem |
| 3.1 | Show name, type, location, capacity, rate, status | `Resource` model, `resources_screen.dart` | Jassem |
| 3.1 | Availability calculated, not stored as a status | `BookingService.findAvailableResources` | Amani |
| 3.1 | Filter by type, capacity, location, or price | `ResourceFilter`, `resource_filter_bar.dart` | Erin, Jassem |
| 3.2 | Create and display members; name and unique email | `MemberService`, `members_screen.dart` | Erin, Jassem |
| 3.2 | Display a selected member's bookings | `BookingService.findByMember`, `MembersScreen.selectMember` | Amani, Jassem |
| 3.3 | Create a booking from ids; server sets status and cost | `BookingService.create` | Amani |
| 3.3 | Update a booking when the new slot is valid | `BookingService.update` | Amani |
| 3.3 | Cancel through an update endpoint, keeping history | `BookingService.update`, `BookingsScreen.cancelBooking` | Amani, Jassem |
| 3.3 | Display current and past bookings | `bookings_screen.dart` | Jassem |
| 3.3 | Total from rate and duration | `BookingRules.calculateTotalCost` | Amani |
| 3.4 | No overlapping CONFIRMED bookings; adjacent allowed; exclude self on update | `BookingRules.overlaps`, `BookingRepository` | Amani |
| 3.4 | Start before end | `BookingRules.validateTimes` | Amani |
| 3.4 | Desk one attendee; room within capacity | `BookingRules.validateAttendees` | Amani |
| 3.4 | OUT_OF_SERVICE cannot be booked | `BookingService` | Amani |
| 3.4 | Cancelling frees the slot; cancelled stays in history | `BookingService` | Amani |
| 3.4 | Correct status codes and useful messages | `GlobalExceptionHandler`, API.md messages | Erin |
| Checkpoint | Invalid booking rejected at the backend and shown in Flutter | `BookingService`, `NewBookingScreen.submit`, `feedback.dart` | Amani, Jassem |
| 4 | Subtype choice documented | separate `/rooms` and `/desks` endpoints; `ResourceController` header and report | Erin |
| 4 | Every endpoint in the table | `MemberController`, `ResourceController`, `BookingController`, `AvailabilityController` | Erin, Amani |
| 5 | Dashboard, resources, availability and new booking, bookings, management | `lib/screens/` | Jassem |
| 5 | Dart models map JSON | `lib/models/` | Jassem, Yyan |
| 5 | HTTP calls in a dedicated client class | `lib/services/api_client.dart` | Yyan |
| 5 | Future, async, and await | `api_client.dart`, the screen load and save methods | Yyan, Jassem |
| 5 | Loading, success, and error states | `lib/widgets/` | Jassem |
| 5 | Validate forms before sending | form screen validators | Jassem |
| 5 | Refresh the UI after create, update, cancel | screen reload methods | Jassem |
| 5 | Folders `models/`, `services/`, `screens/`, `widgets/` | `frontend/lib/` | Jassem |
| 6 | Multi-stage backend Dockerfile from source, not depending on target/ | `backend/Dockerfile` | Yyan |
| 6 | PostgreSQL in Compose, connected through environment variables | `docker-compose.yml`, `application.properties` | Yyan, Erin |
| 6 | Persistent volume; no create or create-drop | `docker-compose.yml`, `application.properties` | Yyan, Erin |
| 6 | No real secrets; `.env.example` | `.env.example`, `.gitignore` | Yyan |
| 6 | `docker compose up --build` documented | `README.md` | Yyan |
| Cross-platform | No unnecessary platform-specific code | `frontend/lib/` | Jassem |
| Deliverable 1 | ZIP with `backend/`, `frontend/`, Compose, Dockerfiles, README, `.env.example`; no generated folders | submission | Yyan |
| Deliverable 2 | Report with every required section | `docs/REPORT_OUTLINE.md` | Yyan, everyone |
| Deliverable 3 | Presentation, live demo, Docker shown, everyone participates, individual Q&A | `docs/DEMO_AND_QA.md` | everyone |
