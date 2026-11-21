// Owner: Erin
// What: Starts the Spring Boot server on port 8080.
// Depends on: nothing.

package com.coworkhub;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class CoworkhubApplication {

    public static void main(String[] args) {
        SpringApplication.run(CoworkhubApplication.class, args);
    }
}
