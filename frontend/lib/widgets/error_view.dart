// Owner: Jassem
// What: Shown when a list fails to load, for example when the server is not running.
// Checklist: each request shows the server's error message.
// Depends on: nothing. The message usually comes from ApiException.message (Yyan).

import 'package:material_ui/material_ui.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // TODO(Jassem): Show the message as readable text. An icon and Retry button are optional.
    return const Placeholder();
  }
}
