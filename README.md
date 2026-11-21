# CoWorkHub

<!--
Owner: Yyan
Checklist: README names every team member and gives the exact steps to start Docker,
           then run the Flutter desktop app on the host machine.
-->

A desktop application for booking meeting rooms and desks in a coworking space.
Flutter desktop client, Spring Boot REST API, Spring Data JPA, PostgreSQL, Docker Compose.

## Team

| Member (ID) | Part |
|---|---|
| Erin (60301179) | Backend foundation: entities, member and resource API, error handling |
| Amani (60305749) | Booking rules and endpoints |
| Jassem (60303214) | Flutter screens |
| Yyan (60306991) | HTTP client, Docker, README, report, submission |

Team name: Group 1

## Where things are

| Path | Contents |
|---|---|
| `docs/API.md` | The shared contract: every endpoint, request, response, and error message |
| `docs/TASKS.md` | Every TODO by person, in order, with dependencies and brief coverage |
| `docs/REPORT_OUTLINE.md` | Report sections and who writes each |
| `docs/DEMO_AND_QA.md` | Demo script and Q&A practice |
| `backend/` | Spring Boot project |
| `frontend/` | Flutter desktop project |

## Run the server with Docker

You need Docker Desktop (or Docker Engine with the Compose plugin). PostgreSQL and Java do not need to be installed.

```bash
cp .env.example .env        # then open .env and replace change-me with your own password
docker compose up --build
```

The first build downloads Maven dependencies and takes a few minutes. The server is ready when the log shows `Started CoworkhubApplication`.

Check it works:

```bash
curl http://localhost:8080/api/resources
```

It returns a JSON list (`[]` on a fresh database). API documentation: http://localhost:8080/swagger-ui.html

Stop and restart without losing data:

```bash
docker compose down         # stops the containers; the named volume coworkhub-db-data keeps the data
docker compose up           # the same members, resources, and bookings are still there
```

Never run `docker compose down -v`: `-v` deletes the volume and the data with it. The tables are created and updated by Hibernate with `ddl-auto=update`, which never drops existing rows.

## Run the desktop app

Start the server first (Docker above, or the development steps below). Then, on the host machine with Flutter installed:

```bash
cd frontend
flutter pub get
flutter run -d macos   # or -d windows, or -d linux
```

The app talks to `http://localhost:8080` through `lib/services/api_client.dart`. If the server is not running, screens show "Could not reach the server".

## Run the backend without Docker (development)

The backend needs Java 17 or newer. With no environment variables it uses a local H2 file database in `backend/data/`.

```bash
cd backend
./mvnw spring-boot:run
./mvnw test
```

- API documentation: http://localhost:8080/swagger-ui.html
- H2 console: http://localhost:8080/h2-console (JDBC URL `jdbc:h2:file:./data/coworkhub`, user `sa`, no password)

On macOS with several JDKs installed, select one first, for example `export JAVA_HOME=$(/usr/libexec/java_home -v 17)`.
