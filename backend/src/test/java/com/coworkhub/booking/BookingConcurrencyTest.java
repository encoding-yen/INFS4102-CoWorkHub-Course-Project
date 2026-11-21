package com.coworkhub.booking;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.junit.jupiter.api.AfterEach;
import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import com.coworkhub.exception.ConflictException;
import com.coworkhub.member.Member;
import com.coworkhub.member.MemberRepository;
import com.coworkhub.resource.BookableResourceRepository;
import com.coworkhub.resource.MeetingRoom;
import com.coworkhub.resource.ResourceStatus;


@SpringBootTest
class BookingConcurrencyTest {

    @Autowired
    private BookingService bookingService;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private BookableResourceRepository resourceRepository;

    private Member member;
    private MeetingRoom room;

    @BeforeEach
    void setUp() {
        member = new Member();
        member.setFullName("Concurrency Member");
        member.setEmail("concurrency." + System.currentTimeMillis() + "@example.com");
        memberRepository.save(member);

        room = new MeetingRoom();
        room.setName("Concurrency Room");
        room.setLocation("Floor 1");
        room.setCapacity(8);
        room.setHourlyRate(new BigDecimal("40.00"));
        room.setStatus(ResourceStatus.ACTIVE);
        resourceRepository.save(room);
    }

    @AfterEach
    void cleanUp() {
        // The data was really committed, so remove it. Bookings first, because they point at the others.
        bookingRepository.deleteAll();
        resourceRepository.delete(room);
        memberRepository.delete(member);
    }

    private LocalDateTime time(int hour, int minute) {
        return LocalDateTime.of(2026, 11, 20, hour, minute);
    }

    @Test
    void fourSimultaneousEditsIntoTheSameSlotAllowOnlyOne() throws Exception {
        // Four separate bookings on the same room: 08-09, 10-11, 12-13, 14-15.
        List<Long> bookingIds = new ArrayList<>();
        for (int hour = 8; hour <= 14; hour += 2) {
            BookingCreateRequest request = new BookingCreateRequest(
                    member.getId(), room.getId(), time(hour, 0), time(hour + 1, 0), 4);
            bookingIds.add(bookingService.create(request).id());
        }

        // All four are edited into the same slot, 16:00-17:00, at the same moment.
        BookingUpdateRequest edit = new BookingUpdateRequest(time(16, 0), time(17, 0), 4, null);

        ExecutorService pool = Executors.newFixedThreadPool(4);
        CountDownLatch ready = new CountDownLatch(4);
        CountDownLatch go = new CountDownLatch(1);
        List<Future<String>> futures = new ArrayList<>();

        for (Long bookingId : bookingIds) {
            futures.add(pool.submit(() -> {
                ready.countDown();
                go.await(); // every thread waits here so they all start together
                try {
                    bookingService.update(bookingId, edit);
                    return "OK";
                } catch (ConflictException e) {
                    return "CONFLICT";
                } catch (Exception e) {
                    return "OTHER: " + e;
                }
            }));
        }

        ready.await(); // all four threads are waiting
        go.countDown(); // release them together

        int ok = 0;
        int conflict = 0;
        int other = 0;
        for (Future<String> future : futures) {
            String result = future.get();
            if (result.equals("OK")) {
                ok++;
            } else if (result.equals("CONFLICT")) {
                conflict++;
            } else {
                other++;
                System.out.println(result);
            }
        }
        pool.shutdown();

        assertEquals(1, ok, "exactly one edit should succeed");
        assertEquals(3, conflict, "the other three should be rejected with a conflict");
        assertEquals(0, other, "no unexpected errors");
    }
}