// Owner: Jassem (Yyan checks the field names match the server JSON)
// What: A member as the server sends it. See docs/API.md, section Members.
//       { "id": 1, "fullName": "Maya Chen", "email": "maya@example.com" }
// Depends on: nothing.

class Member {
  const Member({required this.id, required this.fullName, required this.email});

  final int id;
  final String fullName;
  final String email;

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
    );
  }
}
