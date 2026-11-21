// Owner: Erin
// What: Member business logic. Controllers call this class. This class calls MemberRepository.
// Checklist: create returns a database-generated id; duplicate email gives 409; missing id gives 404.
// Depends on: MemberRepository (done), the exception classes (done).
// Used by: Amani's BookingService calls findById to load the member of a new booking.

package com.coworkhub.member;

import com.coworkhub.exception.ConflictException;
import com.coworkhub.exception.NotFoundException;
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
        return memberRepository.findAll();
    }

    public Member findById(Long id) {
        // TODO(Erin): Return the member, or throw new NotFoundException("Member not found.").
        // Amani's BookingService depends on this exact behaviour for the 404 on a booking.
        return memberRepository.findById(id).orElseThrow(() -> new NotFoundException("Member not found."));
    }

    public Member create(MemberRequest request) {
        // TODO(Erin):
        // 1. Trim fullName and email.
        // 2. If the email is already used, throw new ConflictException("A member with this email already exists.").
        // 3. Copy the fields into a new Member and save it. The database assigns the id.
        String fullName = request.fullName().trim();
        String email = request.email().trim();
        if (memberRepository.existsByEmailIgnoreCase(email)) {
            throw new ConflictException("A member with this email already exists.");
        }
        Member member = new Member();
        member.setFullName(fullName);
        member.setEmail(email);
        return memberRepository.save(member);
    }

    public Member update(Long id, MemberRequest request) {
        // TODO(Erin):
        // 1. Load the member with findById (404 if missing).
        // 2. Trim the fields. If the new email belongs to a different member, throw ConflictException (409).
        // 3. Copy the fields onto the existing member and save it.
        Member member = findById(id);
        String fullName = request.fullName().trim();
        String email = request.email().trim();
        if (memberRepository.existsByEmailIgnoreCaseAndIdNot(email, id)) {
            throw new ConflictException("A member with this email already exists.");
        }
        member.setFullName(fullName);
        member.setEmail(email);
        return memberRepository.save(member);
    }
}
