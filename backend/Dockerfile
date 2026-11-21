# Owner: Yyan
# What: Builds the backend image from source. Used by docker-compose.yml.
# Checklist: multi-stage; builds the jar from the Maven source inside the image;
#            does not need a pre-existing backend/target/ folder (target/ is excluded from the ZIP).
# Depends on: backend/pom.xml and the Maven wrapper (Erin, done). The server must start, which it already does.
#
# TODO(Yyan): Write the two stages below.
#
# Stage 1 - build
#   FROM a JDK 17 image with Maven, for example maven:3.9-eclipse-temurin-17 (or eclipse-temurin:17-jdk + ./mvnw)
#   WORKDIR /app
#   COPY pom.xml
#   COPY src
#   RUN mvn -q -DskipTests package
#
# Stage 2 - run
#   FROM a JRE 17 image, for example eclipse-temurin:17-jre
#   WORKDIR /app
#   COPY --from=build /app/target/*.jar app.jar
#   EXPOSE 8080
#   ENTRYPOINT ["java", "-jar", "app.jar"]
