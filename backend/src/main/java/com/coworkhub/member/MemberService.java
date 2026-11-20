// Owner: Erin
// What: Member business logic. Controllers call this class. This class calls MemberRepository.
// Checklist: create returns a database-generated id; duplicate email gives 409; missing id gives 404.
// Depends on: MemberRepository (done), the exception classes (done).
// Used by: Amani's BookingService calls findById to load the member of a new booking.

package com.coworkhub.member;

import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class MemberService {

    private final MemberRepository memberRepository;

    public MemberService(MemberRepository memberRepository) {
        this.memberRepository = memberRepository;
    }

    public List<Member> findAll() {
        // TODO(Erin): Return every member.
        throw new UnsupportedOperationException("TODO(Erin): MemberService.findAll");
    }

    public Member findById(Long id) {
        // TODO(Erin): Return the member, or throw new NotFoundException("Member not found.").
        // Amani's BookingService depends on this exact behaviour for the 404 on a booking.
        throw new UnsupportedOperationException("TODO(Erin): MemberService.findById");
    }

    public Member create(MemberRequest request) {
        // TODO(Erin):
        // 1. Trim fullName and email.
        // 2. If the email is already used, throw new ConflictException("A member with this email already exists.").
        // 3. Copy the fields into a new Member and save it. The database assigns the id.
        throw new UnsupportedOperationException("TODO(Erin): MemberService.create");
    }

    public Member update(Long id, MemberRequest request) {
        // TODO(Erin):
        // 1. Load the member with findById (404 if missing).
        // 2. Trim the fields. If the new email belongs to a different member, throw ConflictException (409).
        // 3. Copy the fields onto the existing member and save it.
        throw new UnsupportedOperationException("TODO(Erin): MemberService.update");
    }
}
