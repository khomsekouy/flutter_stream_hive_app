import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/usecases/get_live_streams.dart';

part 'live_stream_state.dart';

/// Drives the live-stream list screen.
class LiveStreamCubit extends Cubit<LiveStreamState> {
  LiveStreamCubit({required GetLiveStreams getLiveStreams})
    : _getLiveStreams = getLiveStreams,
      super(const LiveStreamState());

  final GetLiveStreams _getLiveStreams;

  Future<void> loadLiveStreams({String? sport}) async {
    emit(state.copyWith(status: LiveStreamStatus.loading));

    final result = await _getLiveStreams(GetLiveStreamsParams(sport: sport));

    result.fold(
      (failure) => emit(
        LiveStreamState(
          status: LiveStreamStatus.failure,
          streams: state.streams,
          errorMessage: failure.message,
        ),
      ),
      (streams) => emit(
        LiveStreamState(
          status: LiveStreamStatus.success,
          streams: streams,
        ),
      ),
    );
  }
}
