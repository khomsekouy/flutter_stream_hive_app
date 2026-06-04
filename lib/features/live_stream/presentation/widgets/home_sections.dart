import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/content/home_content.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/club_logo.dart';

/// "Title ............ View All ›" row that heads each home section.
class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.onViewAll, super.key});

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 8, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.info,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A team crest from the bundled assets, falling back to a neutral shield when
/// we don't ship a logo for that club.
class TeamCrest extends StatelessWidget {
  const TeamCrest({required this.team, this.size = 36, super.key});

  final String? team;
  final double size;

  @override
  Widget build(BuildContext context) {
    final logo = ClubLogo.forTeam(team);
    if (logo == null) {
      return Icon(Icons.shield_outlined, size: size, color: AppColors.outline);
    }
    return logo.image(width: size, height: size, fit: BoxFit.contain);
  }
}

/// A `Card`-style surface used by the match rows.
class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A live match card: a header (LIVE badge + label + match clock), big circular
/// crests with the score between them, and a viewers / comments footer.
class LiveMatchCard extends StatelessWidget {
  const LiveMatchCard({required this.match, this.onTap, super.key});

  final LiveStream match;
  final VoidCallback? onTap;

  /// Compact count, e.g. `12.4K` / `1.2M`.
  static String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Header: LIVE badge + label, match clock trailing. ----
          Row(
            children: [
              const _LiveBadge(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  match.competition ?? 'Live score',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (match.minute != null)
                Text(
                  "${match.minute}'",
                  style: const TextStyle(
                    color: AppColors.live,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // ---- Crests + score ----
          Row(
            children: [
              Expanded(child: _TeamColumn(team: match.homeTeam)),
              _ScoreLine(match: match),
              Expanded(child: _TeamColumn(team: match.awayTeam)),
            ],
          ),
          const SizedBox(height: 18),

          const Divider(height: 1, color: AppColors.outline),
          const SizedBox(height: 12),

          // ---- Footer: viewers + comments ----
          Row(
            children: [
              _StatItem(
                icon: Icons.visibility_outlined,
                text: '${_formatCount(match.viewerCount)} viewers',
              ),
              const Spacer(),
              _StatItem(
                icon: Icons.mode_comment_outlined,
                text: '${_formatCount(match.commentCount)} comments',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A large circular crest with the team name centered beneath it.
class _TeamColumn extends StatelessWidget {
  const _TeamColumn({required this.team});

  final String? team;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.surfaceHigh,
            shape: BoxShape.circle,
          ),
          child: TeamCrest(team: team, size: 40),
        ),
        const SizedBox(height: 10),
        Text(
          team ?? 'TBD',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
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

/// The centered scoreline, e.g. `3 : 2`, or `vs` before kick-off.
class _ScoreLine extends StatelessWidget {
  const _ScoreLine({required this.match});

  final LiveStream match;

  @override
  Widget build(BuildContext context) {
    if (!match.hasScore) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'vs',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    const numberStyle = TextStyle(
      color: AppColors.textPrimary,
      fontSize: 34,
      fontWeight: FontWeight.w800,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${match.homeScore}', style: numberStyle),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              ':',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text('${match.awayScore}', style: numberStyle),
        ],
      ),
    );
  }
}

/// An icon + label pair used in the live card footer (viewers / comments).
class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _TeamSide extends StatelessWidget {
  const _TeamSide({required this.team});

  final String? team;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TeamCrest(team: team),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            team ?? 'TBD',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.live,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: AppColors.white),
          SizedBox(width: 5),
          Text(
            'LIVE',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// An upcoming match row: the two teams up top, then competition / kick-off /
/// venue with a "Details" button.
class UpcomingMatchCard extends StatelessWidget {
  const UpcomingMatchCard({
    required this.match,
    required this.kickOff,
    this.onDetails,
    super.key,
  });

  final LiveStream match;

  /// Pre-formatted kick-off, e.g. `Tonight, 8:00 PM`.
  final String kickOff;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      onTap: onDetails,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _TeamSide(team: match.homeTeam)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'VS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(child: _TeamSide(team: match.awayTeam)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.outline),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (match.competition != null)
                      Text(
                        match.competition!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 4),
                    _MetaLine(icon: Icons.calendar_today, text: kickOff),
                    if (match.venue != null) ...[
                      const SizedBox(height: 3),
                      _MetaLine(icon: Icons.place_outlined, text: match.venue!),
                    ],
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: onDetails,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.info,
                  side: const BorderSide(color: AppColors.info),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Details'),
              ),
            ],
          ),
        ],
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
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// Horizontally-scrolling league filter chips.
class LeagueFilterBar extends StatelessWidget {
  const LeagueFilterBar({
    required this.filters,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<LeagueFilter> filters;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final isActive = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isActive ? AppColors.info : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.info : AppColors.outline,
                ),
              ),
              child: Text(
                filters[i].label,
                style: TextStyle(
                  color: isActive ? AppColors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A highlight reel card for the horizontal Highlights rail.
class HighlightCard extends StatelessWidget {
  const HighlightCard({required this.highlight, this.onTap, super.key});

  final Highlight highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 230,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: highlight.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, _) =>
                          const ColoredBox(color: AppColors.surfaceHigh),
                      errorWidget: (context, _, _) =>
                          const ColoredBox(color: AppColors.surfaceHigh),
                    ),
                    const ColoredBox(color: Colors.black26),
                    const Center(
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black45,
                        child: Icon(
                          Icons.play_arrow,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          highlight.duration,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              highlight.title,
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
              highlight.league,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A Latest News list row.
class NewsTile extends StatelessWidget {
  const NewsTile({required this.article, this.onTap, super.key});

  final NewsArticle article;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: article.thumbnailUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (context, _) => const SizedBox(
                  width: 64,
                  height: 64,
                  child: ColoredBox(color: AppColors.surfaceHigh),
                ),
                errorWidget: (context, _, _) => const SizedBox(
                  width: 64,
                  height: 64,
                  child: ColoredBox(color: AppColors.surfaceHigh),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.timeAgo,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const _NewsBookmarkButton(),
          ],
        ),
      ),
    );
  }
}

/// Tappable bookmark for a news row: toggles between saved and unsaved.
class _NewsBookmarkButton extends StatefulWidget {
  const _NewsBookmarkButton();

  @override
  State<_NewsBookmarkButton> createState() => _NewsBookmarkButtonState();
}

class _NewsBookmarkButtonState extends State<_NewsBookmarkButton> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      tooltip: _saved ? 'Remove from saved' : 'Save',
      icon: Icon(
        _saved ? Icons.bookmark : Icons.bookmark_border,
        size: 20,
        color: _saved ? AppColors.info : AppColors.textSecondary,
      ),
      onPressed: () => setState(() => _saved = !_saved),
    );
  }
}
