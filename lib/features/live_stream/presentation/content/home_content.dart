import 'package:flutter_stream_hive_app/gen/assets.gen.dart';

/// Presentation-only sample content for the home dashboard.
/// A marquee match shown in the top hero carousel.
class FeaturedMatch {
  const FeaturedMatch({
    required this.homeTeam,
    required this.awayTeam,
    required this.competition,
    required this.banner,
    this.isLive = true,
  });

  final String homeTeam;
  final String awayTeam;
  final String competition;

  /// Full-bleed background artwork.
  final AssetGenImage banner;
  final bool isLive;
}

/// A highlights reel teaser (horizontal carousel card).
class Highlight {
  const Highlight({
    required this.title,
    required this.league,
    required this.duration,
    required this.thumbnailUrl,
  });

  final String title;
  final String league;

  /// Pre-formatted clip length, e.g. `05:24`.
  final String duration;
  final String thumbnailUrl;
}

/// A news article teaser (Latest News list row).
class NewsArticle {
  const NewsArticle({
    required this.title,
    required this.timeAgo,
    required this.thumbnailUrl,
  });

  final String title;

  /// Pre-formatted relative time, e.g. `2 hours ago`.
  final String timeAgo;
  final String thumbnailUrl;
}

/// A single live chat comment on a stream.
class LiveComment {
  const LiveComment({
    required this.author,
    required this.text,
    required this.timeAgo,
  });

  final String author;
  final String text;

  /// Pre-formatted relative time, e.g. `1m`.
  final String timeAgo;
}

/// One chip in the "Top Leagues" filter row.
class LeagueFilter {
  const LeagueFilter({required this.label, this.competition});

  final String label;

  /// The `LiveStream.competition` value this chip filters to. Null means
  /// "All" (no filtering).
  final String? competition;
}

/// Hero carousel content. Backgrounds reuse the bundled banner artwork.
final List<FeaturedMatch> kFeaturedMatches = [
  FeaturedMatch(
    homeTeam: 'Real Madrid',
    awayTeam: 'Barcelona',
    competition: 'Champions League',
    banner: Assets.images.banners.banner001,
  ),
  FeaturedMatch(
    homeTeam: 'Bayern München',
    awayTeam: 'Juventus',
    competition: 'Champions League',
    banner: Assets.images.banners.banner002,
  ),
  FeaturedMatch(
    homeTeam: 'Arsenal',
    awayTeam: 'Chelsea',
    competition: 'Premier League',
    banner: Assets.images.banners.banner001,
  ),
];

/// The league filter chips, in display order.
const List<LeagueFilter> kLeagueFilters = [
  LeagueFilter(label: 'All'),
  LeagueFilter(label: 'Champions League', competition: 'Champions League'),
  LeagueFilter(label: 'Premier League', competition: 'Premier League'),
  LeagueFilter(label: 'La Liga', competition: 'La Liga'),
  LeagueFilter(label: 'Serie A', competition: 'Serie A'),
  LeagueFilter(label: 'Bundesliga', competition: 'Bundesliga'),
];

/// Sample highlight reels.
const List<Highlight> kHighlights = [
  Highlight(
    title: 'Real Madrid 3 - 2 Barcelona',
    league: 'Champions League',
    duration: '05:24',
    thumbnailUrl: 'https://picsum.photos/seed/hl-rma-bar/480/270',
  ),
  Highlight(
    title: 'Man City 4 - 1 Liverpool',
    league: 'Premier League',
    duration: '04:18',
    thumbnailUrl: 'https://picsum.photos/seed/hl-mci-liv/480/270',
  ),
  Highlight(
    title: 'Atlético 2 - 1 Sevilla',
    league: 'La Liga',
    duration: '03:56',
    thumbnailUrl: 'https://picsum.photos/seed/hl-atm-sev/480/270',
  ),
  Highlight(
    title: 'Inter 2 - 2 Juventus',
    league: 'Serie A',
    duration: '06:11',
    thumbnailUrl: 'https://picsum.photos/seed/hl-int-juv/480/270',
  ),
];

/// Sample live chat comments for the stream detail screen.
const List<LiveComment> kLiveComments = [
  LiveComment(author: 'Alex V.', text: 'What a goal! 🔥', timeAgo: '1m'),
  LiveComment(
    author: 'Jamie M.',
    text: 'Arsenal are playing amazing today! 👏',
    timeAgo: '1m',
  ),
  LiveComment(
    author: 'Priya S.',
    text: 'That defending was unreal 😮',
    timeAgo: '2m',
  ),
  LiveComment(
    author: 'Marco B.',
    text: 'Best match of the season so far!',
    timeAgo: '3m',
  ),
];

/// Sample news articles.
const List<NewsArticle> kLatestNews = [
  NewsArticle(
    title: 'City Rangers signs new striker from Premier League',
    timeAgo: '2 hours ago',
    thumbnailUrl: 'https://picsum.photos/seed/news-striker/200/200',
  ),
  NewsArticle(
    title: 'Champions League semi-final draw announced',
    timeAgo: '5 hours ago',
    thumbnailUrl: 'https://picsum.photos/seed/news-ucl-draw/200/200',
  ),
  NewsArticle(
    title: 'Real Madrid confirm pre-season tour fixtures',
    timeAgo: '8 hours ago',
    thumbnailUrl: 'https://picsum.photos/seed/news-rma-tour/200/200',
  ),
];
