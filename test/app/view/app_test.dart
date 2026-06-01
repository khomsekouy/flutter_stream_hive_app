import 'package:flutter_stream_hive_app/app/app.dart';
import 'package:flutter_stream_hive_app/core/di/injection.dart';
import 'package:flutter_stream_hive_app/features/live_stream/live_stream.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  group('App', () {
    testWidgets('renders LiveStreamPage', (tester) async {
      await tester.pumpWidget(const App());
      // Let the (fake) initial load complete so no timer is left pending.
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byType(LiveStreamPage), findsOneWidget);
    });
  });
}
