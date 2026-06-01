import 'package:flutter_stream_hive_app/app/app.dart';
import 'package:flutter_stream_hive_app/core/di/injection.dart';
import 'package:flutter_stream_hive_app/features/live_stream/live_stream.dart';
import 'package:flutter_stream_hive_app/features/splash/splash.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  group('App', () {
    testWidgets('shows SplashPage first, then navigates to LiveStreamPage', (
      tester,
    ) async {
      await tester.pumpWidget(const App());
      expect(find.byType(SplashPage), findsOneWidget);

      // Fire the splash hold-timer, build the home route, then flush the
      // (fake) list load so no timer is left pending.
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(SplashPage), findsNothing);
      expect(find.byType(LiveStreamPage), findsOneWidget);
    });
  });
}
