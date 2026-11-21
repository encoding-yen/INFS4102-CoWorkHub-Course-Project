# CoWorkHub

<!--
Owner: Yyan
Checklist: README names every team member and gives the exact steps to start Docker,
           then run the Flutter desktop app on the host machine.
TODO(Yyan): Fill every TODO below and test the steps on a machine without PostgreSQL installed.
-->

A desktop application for booking meeting rooms and desks in a coworking space.
Flutter desktop client, Spring Boot REST API, Spring Data JPA, PostgreSQL, Docker Compose.

## Team

<!-- TODO(Yyan): Full names matching the report's contribution table. -->

| Member | Part |
|---|---|
| Erin | Backend foundation: entities, member and resource API, error handling |
| Amani | Booking rules and endpoints |
| Jassem | Flutter screens |
| Yyan | HTTP client, Docker, README, report, submission |

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

<!-- TODO(Yyan): Exact commands once docker-compose.yml works. Expected shape: -->

```bash
cp .env.example .env
docker compose up --build
```

<!-- TODO(Yyan): How to check it works, for example curl http://localhost:8080/api/resources returns a list.
     How to stop it (docker compose down) and how the data survives a restart. -->

## Run the desktop app

<!-- TODO(Yyan): Exact steps. Expected shape: -->

```bash
cd frontend
flutter pub get
flutter run -d macos   # or -d windows, or -d linux
```

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
