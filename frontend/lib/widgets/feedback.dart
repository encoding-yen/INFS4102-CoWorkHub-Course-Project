// Owner: Jassem
// What: Short messages after an action, for example "Booking confirmed" or the server's 409 message.
// Checklist: each request shows a success message or the server's error message.
// Depends on: nothing.

import 'package:material_ui/material_ui.dart';

void showSuccess(BuildContext context, String message) {
  // TODO(Jassem): Show the message in a basic SnackBar.
  throw UnimplementedError('TODO(Jassem): showSuccess');
}

void showError(BuildContext context, String message) {
  // TODO(Jassem): Show the error message in a basic SnackBar; custom styling is unnecessary.
  //               The rejected overlapping booking in the demo must be easy to read.
  throw UnimplementedError('TODO(Jassem): showError');
}
