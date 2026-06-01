part of 'stream_detail_cubit.dart';

enum StreamDetailStatus { initial, loading, success, failure }

class StreamDetailState extends Equatable {
  const StreamDetailState({
    this.status = StreamDetailStatus.initial,
    this.stream,
    this.errorMessage,
  });

  final StreamDetailStatus status;
  final LiveStream? stream;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, stream, errorMessage];
}
