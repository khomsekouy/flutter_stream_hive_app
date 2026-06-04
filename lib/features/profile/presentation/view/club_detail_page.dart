import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/di/injection.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/home_sections.dart';
import 'package:flutter_stream_hive_app/features/profile/presentation/content/club_detail_content.dart';
import 'package:flutter_stream_hive_app/features/profile/presentation/content/profile_content.dart';
import 'package:flutter_stream_hive_app/features/profile/presentation/favorites/favorite_teams_store.dart';

/// Club information screen with Table / Players / Matchday tabs, opened by
/// tapping a club crest.
class ClubDetailPage extends StatelessWidget {
  const ClubDetailPage({required this.clubName, this.country, super.key});

  final String clubName;
  final String? country;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            clubName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryLight,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Table'),
              Tab(text: 'Players'),
              Tab(text: 'Matchday'),
            ],
          ),
        ),
        body: Column(
          children: [
            _ClubHeader(clubName: clubName, country: country),
            const Divider(height: 1, color: AppColors.outline),
            Expanded(
              child: TabBarView(
                children: [
                  _TableTab(clubName: clubName),
                  const _PlayersTab(),
                  _MatchdayTab(clubName: clubName),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubHeader extends StatelessWidget {
  const _ClubHeader({required this.clubName, this.country});

  final String clubName;
  final String? country;

  @override
  Widget build(BuildContext context) {
    final store = getIt<FavoriteTeamsStore>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.surfaceHigh,
              shape: BoxShape.circle,
            ),
            child: TeamCrest(team: clubName, size: 44),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clubName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (country != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    country!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              final isFav = store.isFavorite(clubName);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.live : AppColors.textSecondary,
                ),
                tooltip: isFav ? 'Remove from favourites' : 'Add to favourites',
                onPressed: () => store.toggle(
                  FavoriteTeam(name: clubName, country: country ?? ''),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// League standings, highlighting the current club.
class _TableTab extends StatelessWidget {
  const _TableTab({required this.clubName});

  final String clubName;

  List<StandingRow> _standings() {
    return [
      for (var i = 0; i < kAllClubs.length; i++)
        _rowFor(i, kAllClubs[i].name),
    ];
  }

  StandingRow _rowFor(int i, String team) {
    final won = (22 - i).clamp(2, 28);
    final drawn = (i % 5) + 2;
    final lost = (30 - won - drawn).clamp(0, 30);
    return StandingRow(
      position: i + 1,
      team: team,
      played: won + drawn + lost,
      won: won,
      drawn: drawn,
      lost: lost,
      points: won * 3 + drawn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _standings();
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const _TableHeaderRow(),
        const Divider(height: 1, color: AppColors.outline),
        for (final row in rows)
          _StandingTile(row: row, highlight: row.team == clubName),
      ],
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  static const _style = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  Widget _stat(String label, double width) => SizedBox(
    width: width,
    child: Text(label, style: _style, textAlign: TextAlign.center),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          const SizedBox(width: 24, child: Text('#', style: _style)),
          const SizedBox(width: 8),
          const Expanded(child: Text('Club', style: _style)),
          _stat('P', 28),
          _stat('W', 28),
          _stat('D', 28),
          _stat('L', 28),
          _stat('Pts', 34),
        ],
      ),
    );
  }
}

class _StandingTile extends StatelessWidget {
  const _StandingTile({required this.row, required this.highlight});

  final StandingRow row;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final textColor = highlight
        ? AppColors.primaryLight
        : AppColors.textPrimary;
    Widget cell(String value, double width, {bool bold = false}) => SizedBox(
      width: width,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
    return Container(
      color: highlight ? AppColors.surfaceHigh : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${row.position}',
              style: TextStyle(color: textColor, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          TeamCrest(team: row.team, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              row.team,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          cell('${row.played}', 28),
          cell('${row.won}', 28),
          cell('${row.drawn}', 28),
          cell('${row.lost}', 28),
          cell('${row.points}', 34, bold: true),
        ],
      ),
    );
  }
}

/// The squad, grouped by position.
class _PlayersTab extends StatelessWidget {
  const _PlayersTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: kSampleSquad.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, indent: 60, color: AppColors.outline),
      itemBuilder: (context, i) {
        final player = kSampleSquad[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.surfaceHigh,
            child: Text(
              '${player.number}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            player.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Text(
            player.position,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }
}

/// Upcoming fixtures for the club.
class _MatchdayTab extends StatelessWidget {
  const _MatchdayTab({required this.clubName});

  final String clubName;

  List<Fixture> _fixtures() {
    const comps = ['Premier League', 'Champions League', 'Domestic Cup'];
    final others = kAllClubs.where((c) => c.name != clubName).toList();
    final count = others.length < kSampleFixtureDates.length
        ? others.length
        : kSampleFixtureDates.length;
    return [
      for (var i = 0; i < count; i++)
        Fixture(
          competition: comps[i % comps.length],
          opponent: others[i].name,
          dateLabel: kSampleFixtureDates[i],
          isHome: i.isEven,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final fixtures = _fixtures();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: fixtures.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _FixtureCard(fixture: fixtures[i]),
    );
  }
}

class _FixtureCard extends StatelessWidget {
  const _FixtureCard({required this.fixture});

  final Fixture fixture;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          TeamCrest(team: fixture.opponent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${fixture.isHome ? 'vs' : '@'} ${fixture.opponent}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fixture.competition,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            fixture.dateLabel,
            textAlign: TextAlign.end,
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
