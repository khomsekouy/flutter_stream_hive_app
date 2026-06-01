import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/usecases/get_stream_by_id.dart';

part 'stream_detail_state.dart';

/// Resolves the stream shown on the detail/watch screen.
///
/// Two entry paths:
/// * **From the list** — the [LiveStream] is already in memory, passed to the
///   constructor as `initial`. We seed `success` immediately, no network.
/// * **Deep link** — only an id arrived in the URL, so `initial` is null and
///   [load] fetches it via [GetStreamById].
class StreamDetailCubit extends Cubit<StreamDetailState> {
  StreamDetailCubit({
    required GetStreamById getStreamById,
    required String streamId,
    LiveStream? initial,
  }) : _getStreamById = getStreamById,
       _streamId = streamId,
       super(
         initial != null
             ? StreamDetailState(
                 status: StreamDetailStatus.success,
                 stream: initial,
               )
             : const StreamDetailState(),
       );

  final GetStreamById _getStreamById;
  final String _streamId;

  Future<void> load() async {
    // Already seeded from the list — nothing to fetch.
    if (state.status == StreamDetailStatus.success) return;

    emit(const StreamDetailState(status: StreamDetailStatus.loading));

    final result = await _getStreamById(_streamId);

    result.fold(
      (failure) => emit(
        StreamDetailState(
          status: StreamDetailStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (stream) => emit(
        StreamDetailState(
          status: StreamDetailStatus.success,
          stream: stream,
        ),
      ),
    );
  }
}
