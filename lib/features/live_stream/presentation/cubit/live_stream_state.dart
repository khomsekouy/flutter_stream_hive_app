part of 'live_stream_cubit.dart';

enum LiveStreamStatus { initial, loading, success, failure }

class LiveStreamState extends Equatable {
  const LiveStreamState({
    this.status = LiveStreamStatus.initial,
    this.streams = const [],
    this.errorMessage,
  });

  final LiveStreamStatus status;
  final List<LiveStream> streams;
  final String? errorMessage;

  LiveStreamState copyWith({
    LiveStreamStatus? status,
    List<LiveStream>? streams,
    String? errorMessage,
  }) {
    return LiveStreamState(
      status: status ?? this.status,
      streams: streams ?? this.streams,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, streams, errorMessage];
}
