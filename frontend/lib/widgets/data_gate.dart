// What: Wraps a screen's content. While the shared data is loading it shows LoadingView;
//       if the first load failed it shows the server's message with a Retry button;
//       once the data has loaded it shows the screen's own content.
// Used by: every screen that reads from AppData.

import 'package:material_ui/material_ui.dart';

import '../state/app_data.dart';
import 'error_view.dart';
import 'loading_view.dart';

class DataGate extends StatelessWidget {
  const DataGate({super.key, required this.data, required this.builder});

  final AppData data;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    if (data.loaded) return builder(context);

    final message = data.error;
    if (message != null && !data.loading) {
      return ErrorView(message: message, onRetry: data.refresh);
    }
    return const LoadingView(label: 'Loading...');
  }
}
