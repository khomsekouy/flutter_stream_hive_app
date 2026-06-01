/// Public surface of the live_stream feature.
///
/// Outside code (the app shell, routing) imports this barrel — never the
/// internals — so the feature's structure can change freely behind it.
library;

export 'domain/entities/live_stream.dart';
export 'domain/entities/match_score.dart';
export 'presentation/cubit/live_stream_cubit.dart';
export 'presentation/cubit/match_score_cubit.dart';
export 'presentation/view/live_stream_page.dart';
export 'presentation/view/stream_detail_page.dart';
