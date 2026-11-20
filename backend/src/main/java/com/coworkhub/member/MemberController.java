// Owner: Erin
// What: HTTP endpoints for members. See docs/API.md, section Members.
// Checklist: POST returns 201; duplicate email returns 409; GET lists members; PUT updates a member;
//            missing id returns 404; missing fields return 400.
// Depends on: MemberService. Jassem's members screen and Yyan's ApiClient call these paths.
//
// There is deliberately no DELETE endpoint for members.

package com.coworkhub.member;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/members")
public class MemberController {

    private final MemberService memberService;

    public MemberController(MemberService memberService) {
        this.memberService = memberService;
    }

    @GetMapping
    public List<Member> list() {
        // TODO(Erin): Return memberService.findAll(). Status 200.
        throw new UnsupportedOperationException("TODO(Erin): GET /api/members");
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Member create(@RequestBody MemberRequest request) {
        // TODO(Erin): Add @Valid before @RequestBody so missing fields return 400, then call memberService.create.
        throw new UnsupportedOperationException("TODO(Erin): POST /api/members");
    }

    @PutMapping("/{id}")
    public Member update(@PathVariable Long id, @RequestBody MemberRequest request) {
        // TODO(Erin): Add @Valid, then call memberService.update. Status 200.
        throw new UnsupportedOperationException("TODO(Erin): PUT /api/members/{id}");
    }
}
