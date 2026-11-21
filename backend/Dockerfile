# Owner: Yyan
# What: Builds the backend image from source. Used by docker-compose.yml.
# Checklist: multi-stage; builds the jar from the Maven source inside the image;
#            does not need a pre-existing backend/target/ folder (target/ is excluded from the ZIP).
# Depends on: backend/pom.xml and the Maven wrapper (Erin, done). The server must start, which it already does.
#
# TODO(Yyan): Write the two stages below.
#
# Stage 1 - build: compile the source and package the jar with Maven.
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -q -B -DskipTests package

# Stage 2 - run: only a Java 17 runtime and the finished jar.
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
