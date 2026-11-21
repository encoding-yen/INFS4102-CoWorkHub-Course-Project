// Owner: Jassem
// What: Shown while any request is in progress.
// Checklist: each request shows a loading state.
// Depends on: nothing.

import 'package:material_ui/material_ui.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    // TODO(Jassem): A centered CircularProgressIndicator with the optional label under it.
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (label != null) ...[const SizedBox(height: 8), Text(label!)],
        ],
      ),
    );
  }
}
