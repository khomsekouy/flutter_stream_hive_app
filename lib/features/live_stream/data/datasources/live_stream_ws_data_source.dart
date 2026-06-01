import 'dart:convert';

import 'package:flutter_stream_hive_app/features/live_stream/data/models/match_score_dto.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Real-time score access over a WebSocket.
// ignore: one_member_abstracts
abstract class LiveStreamWsDataSource {
  Stream<MatchScoreDto> watchMatchScore(String matchId);
}

/// Production implementation — connects to the scores WebSocket and decodes
/// each frame into a [MatchScoreDto].
class LiveStreamWsDataSourceImpl implements LiveStreamWsDataSource {
  LiveStreamWsDataSourceImpl({Uri? endpoint})
    : _endpoint =
          endpoint ?? Uri.parse('wss://api.streamhive.example.com/v1/scores');

  final Uri _endpoint;

  @override
  Stream<MatchScoreDto> watchMatchScore(String matchId) {
    final channel = WebSocketChannel.connect(
      _endpoint.replace(queryParameters: {'matchId': matchId}),
    );
    return channel.stream.map(
      (event) => MatchScoreDto.fromJson(
        jsonDecode(event as String) as Map<String, dynamic>,
      ),
    );
  }
}

/// Emits a simulated, ticking score so the real-time UI works without a live
/// backend. Swap for [LiveStreamWsDataSourceImpl] in `injection.dart`.
class FakeLiveStreamWsDataSource implements LiveStreamWsDataSource {
  @override
  Stream<MatchScoreDto> watchMatchScore(String matchId) async* {
    var home = 0;
    var away = 0;
    for (var minute = 1; minute <= 90; minute++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (minute % 13 == 0) home++;
      if (minute % 17 == 0) away++;
      yield MatchScoreDto(
        matchId: matchId,
        homeScore: home,
        awayScore: away,
        minute: minute,
      );
    }
  }
}
