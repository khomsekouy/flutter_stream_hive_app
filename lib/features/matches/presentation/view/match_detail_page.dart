import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/notifications/notification_manager.dart';
import 'package:flutter_stream_hive_app/core/router/app_router.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/home_sections.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Match-day details for a single fixture: a head-to-head header (teams, kick-
/// off, venue) plus a record of previous meetings.
///
/// The fixture is passed via `extra`; previous meetings are mock data generated
/// deterministically from the two team names (mirroring how the club standings
/// are faked), so the same pairing always shows the same history.
class MatchDetailPage extends StatelessWidget {
  const MatchDetailPage({required this.match, super.key});

  final LiveStream? match;

  @override
  Widget build(BuildContext context) {
    final match = this.match;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Match Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: match == null
          ? const Center(
              child: Text(
                'Match not found.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : _Body(match: match),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.match});

  final LiveStream match;

  void _openWatch(BuildContext context) => context.pushNamed(
    AppRoute.streamDetail,
    pathParameters: {'id': match.id},
    extra: match,
  );

  @override
  Widget build(BuildContext context) {
    final meetings = _previousMeetings(match);
    final record = _H2HRecord.from(match, meetings);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _MatchupHeader(match: match, onWatch: () => _openWatch(context)),
        const SizedBox(height: 24),
        const _SectionLabel('HEAD TO HEAD'),
        const SizedBox(height: 12),
        _H2HSummary(match: match, record: record),
        const SizedBox(height: 24),
        const _SectionLabel('PREVIOUS MEETINGS'),
        const SizedBox(height: 4),
        for (final meeting in meetings) _MeetingTile(meeting: meeting),
      ],
    );
  }
}

/// The top card: competition, both teams (crest + name), the score or "VS",
/// kick-off date/time, venue, and a status-aware primary action.
class _MatchupHeader extends StatelessWidget {
  const _MatchupHeader({required this.match, required this.onWatch});

  final LiveStream match;
  final VoidCallback onWatch;

  String get _kickOff {
    final start = match.startTime;
    if (start == null) return 'Date & time TBD';
    final local = start.toLocal();
    return '${DateFormat('EEE d MMM').format(local)} · '
        '${DateFormat('h:mm a').format(local)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            (match.competition ?? match.sport).toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _TeamColumn(team: match.homeTeam)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  match.hasScore
                      ? '${match.homeScore} : ${match.awayScore}'
                      : 'VS',
                  style: TextStyle(
                    color: match.hasScore
                        ? AppColors.gold
                        : AppColors.textSecondary,
                    fontSize: match.hasScore ? 30 : 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(child: _TeamColumn(team: match.awayTeam)),
            ],
          ),
          const SizedBox(height: 16),
          _MetaLine(icon: Icons.calendar_today, text: _kickOff),
          if (match.venue != null) ...[
            const SizedBox(height: 6),
            _MetaLine(icon: Icons.stadium_outlined, text: match.venue!),
          ],
          const SizedBox(height: 16),
          _PrimaryAction(status: match.status, onWatch: onWatch),
        ],
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  const _TeamColumn({required this.team});

  final String? team;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamCrest(team: team, size: 48),
        const SizedBox(height: 8),
        Text(
          team ?? 'TBD',
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Status-aware call to action. Live opens the watch screen; the rest are
/// placeholders for now.
class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.status, required this.onWatch});

  final StreamStatus status;
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (status) {
      StreamStatus.live => ('Watch Live', Icons.play_arrow),
      StreamStatus.upcoming => ('Set Reminder', Icons.notifications_none),
      StreamStatus.ended => ('Highlights', Icons.ondemand_video_outlined),
    };
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: status == StreamStatus.live
            ? onWatch
            : () => NotificationManager.info(context, '$label — coming soon'),
        style: FilledButton.styleFrom(
          backgroundColor: status == StreamStatus.live
              ? AppColors.live
              : AppColors.info,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// The aggregate W–D–W banner across all [_previousMeetings].
class _H2HSummary extends StatelessWidget {
  const _H2HSummary({required this.match, required this.record});

  final LiveStream match;
  final _H2HRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          _RecordColumn(
            value: record.homeWins,
            label: '${match.homeTeam ?? 'Home'} wins',
            color: AppColors.info,
          ),
          _RecordColumn(
            value: record.draws,
            label: 'Draws',
            color: AppColors.textSecondary,
          ),
          _RecordColumn(
            value: record.awayWins,
            label: '${match.awayTeam ?? 'Away'} wins',
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }
}

class _RecordColumn extends StatelessWidget {
  const _RecordColumn({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// One past result: date on the left, teams + scoreline, competition beneath.
class _MeetingTile extends StatelessWidget {
  const _MeetingTile({required this.meeting});

  final _Meeting meeting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Text(
                DateFormat('d MMM\nyyyy').format(meeting.date),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${meeting.homeTeam}  ${meeting.homeScore} - '
                    '${meeting.awayScore}  ${meeting.awayTeam}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meeting.competition,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

/// A single fabricated past meeting between the two clubs.
class _Meeting {
  const _Meeting({
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.competition,
  });

  final DateTime date;
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final String competition;
}

/// Win/draw tally for the current pairing, counted across the meetings.
class _H2HRecord {
  const _H2HRecord({
    required this.homeWins,
    required this.draws,
    required this.awayWins,
  });

  factory _H2HRecord.from(LiveStream match, List<_Meeting> meetings) {
    final home = match.homeTeam;
    var homeWins = 0;
    var awayWins = 0;
    var draws = 0;
    for (final m in meetings) {
      if (m.homeScore == m.awayScore) {
        draws++;
      } else {
        final winner = m.homeScore > m.awayScore ? m.homeTeam : m.awayTeam;
        if (winner == home) {
          homeWins++;
        } else {
          awayWins++;
        }
      }
    }
    return _H2HRecord(homeWins: homeWins, draws: draws, awayWins: awayWins);
  }

  final int homeWins;
  final int draws;
  final int awayWins;
}

/// Five deterministic past meetings for this pairing. Venue alternates so the
/// "home" side swaps each time, like a real fixture history.
List<_Meeting> _previousMeetings(LiveStream match) {
  final home = match.homeTeam ?? 'Home';
  final away = match.awayTeam ?? 'Away';
  final rng = Random('$home$away'.hashCode);
  final base = match.startTime?.toLocal() ?? DateTime.now();
  final day = DateTime(base.year, base.month, base.day);
  final competitions = [
    match.competition ?? 'League',
    'Cup',
    'Super Cup',
  ];

  return List.generate(5, (i) {
    final swap = i.isOdd;
    return _Meeting(
      date: day.subtract(Duration(days: 110 * (i + 1) + rng.nextInt(25))),
      homeTeam: swap ? away : home,
      awayTeam: swap ? home : away,
      homeScore: rng.nextInt(4),
      awayScore: rng.nextInt(4),
      competition: competitions[i % competitions.length],
    );
  });
}
