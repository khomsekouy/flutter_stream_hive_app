import 'package:flutter_stream_hive_app/app/app.dart';
import 'package:flutter_stream_hive_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
