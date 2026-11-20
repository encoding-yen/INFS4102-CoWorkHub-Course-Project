// Owner: Erin
// What: Fails if the server cannot start, for example because an entity mapping is broken.
// Depends on: nothing. Run it after any change to an entity class.

package com.coworkhub;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class CoworkhubApplicationTests {

    @Test
    void contextLoads() {
    }
}
