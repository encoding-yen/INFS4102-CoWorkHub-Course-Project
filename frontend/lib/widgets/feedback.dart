// Owner: Jassem
// What: Short messages after an action, for example "Booking confirmed" or the server's 409 message.
// Checklist: each request shows a success message or the server's error message.
// Depends on: nothing.

import 'package:material_ui/material_ui.dart';

void showSuccess(BuildContext context, String message) {
  // TODO(Jassem): ScaffoldMessenger.of(context).showSnackBar with a success style.
  throw UnimplementedError('TODO(Jassem): showSuccess');
}

void showError(BuildContext context, String message) {
  // TODO(Jassem): A clearly visible error, a red SnackBar or an AlertDialog.
  //               The rejected overlapping booking in the demo must be easy to read.
  throw UnimplementedError('TODO(Jassem): showError');
}
