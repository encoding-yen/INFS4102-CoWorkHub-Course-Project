// Owner: Erin
// What: Reads and writes member rows. JpaRepository already provides findAll, findById, save, existsById.
// Checklist: POST of an email that already exists returns 409.
// Depends on: Member.java (done).
//
// The brief says to add derived query methods only when the application needs them.
// TODO(Erin): Add a derived query for the duplicate-email check, for example:
//             boolean existsByEmailIgnoreCase(String email);
//             boolean existsByEmailIgnoreCaseAndIdNot(String email, Long id);   // for updates

package com.coworkhub.member;

import org.springframework.data.jpa.repository.JpaRepository;

public interface MemberRepository extends JpaRepository<Member, Long> {

    boolean existsByEmailIgnoreCase(String email);

    boolean existsByEmailIgnoreCaseAndIdNot(String email, Long id);
}
