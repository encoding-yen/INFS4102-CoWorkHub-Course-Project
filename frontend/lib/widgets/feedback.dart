// Owner: Jassem
// What: Short messages after an action, for example "Booking confirmed" or the server's 409 message.
// Checklist: each request shows a success message or the server's error message.
// Depends on: nothing.

import 'package:material_ui/material_ui.dart';

void showSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.green.shade800),
  );
}

void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade800,
      duration: const Duration(seconds: 6),
    ),
  );
}
