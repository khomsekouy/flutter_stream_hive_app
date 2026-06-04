import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';

/// Presentation-only sample content for the Profile screen.
///
/// Profile has no backend yet, so the screen is driven from here (same pattern
/// as the home dashboard's sample content). Lift into a feature + cubit when
/// the account API lands.

/// The signed-in user's headline details.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.memberSince,
    this.isPremium = true,
  });

  final String name;
  final String email;
  final String avatarUrl;

  /// Pre-formatted join date, e.g. `May 2023`.
  final String memberSince;
  final bool isPremium;
}

/// A headline stat tile (matches watched, favourites, …).
class ProfileStat {
  const ProfileStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;
}

/// A followed club in "My Favorites".
class FavoriteTeam {
  const FavoriteTeam({required this.name, required this.country});

  final String name;
  final String country;
}

/// A "Recent Activity" entry (a watched clip).
class ActivityItem {
  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.duration,
    required this.thumbnailUrl,
  });

  final String title;

  /// e.g. `Champions League • Semi-final`.
  final String subtitle;
  final String timeAgo;
  final String duration;
  final String thumbnailUrl;
}

/// A row in the account settings list.
class ProfileMenuRow {
  const ProfileMenuRow({
    required this.icon,
    required this.label,
    this.badge = 0,
    this.trailingPill,
  });

  final IconData icon;
  final String label;

  /// Unread/notification count; 0 hides the badge.
  final int badge;

  /// Optional call-out pill, e.g. `Earn Rewards`.
  final String? trailingPill;
}

const UserProfile kUserProfile = UserProfile(
  name: 'Arjun Patel',
  email: 'arjun.patel@email.com',
  avatarUrl: 'https://i.pravatar.cc/200?img=12',
  memberSince: 'May 2023',
);

const List<ProfileStat> kProfileStats = [
  ProfileStat(
    icon: Icons.confirmation_number_outlined,
    color: AppColors.info,
    value: '56',
    label: 'Matches Watched',
  ),
  ProfileStat(
    icon: Icons.favorite,
    color: AppColors.live,
    value: '24',
    label: 'Favorites',
  ),
  ProfileStat(
    icon: Icons.access_time,
    color: AppColors.success,
    value: '120h',
    label: 'Watch Time',
  ),
  ProfileStat(
    icon: Icons.bookmark,
    color: AppColors.warning,
    value: '12',
    label: 'Saved',
  ),
];

/// Clubs the user follows by default (seeds the favorites store).
const List<FavoriteTeam> kFavoriteTeams = [
  FavoriteTeam(name: 'Real Madrid', country: 'Spain'),
  FavoriteTeam(name: 'Manchester City', country: 'England'),
  FavoriteTeam(name: 'Barcelona', country: 'Spain'),
  FavoriteTeam(name: 'Bayern München', country: 'Germany'),
];

/// The full club catalogue shown on the "Browse clubs" screen. Names match the
/// keys in `ClubLogo` so each row gets its crest.
const List<FavoriteTeam> kAllClubs = [
  FavoriteTeam(name: 'Arsenal', country: 'England'),
  FavoriteTeam(name: 'Chelsea', country: 'England'),
  FavoriteTeam(name: 'Liverpool', country: 'England'),
  FavoriteTeam(name: 'Manchester City', country: 'England'),
  FavoriteTeam(name: 'Manchester United', country: 'England'),
  FavoriteTeam(name: 'Real Madrid', country: 'Spain'),
  FavoriteTeam(name: 'Barcelona', country: 'Spain'),
  FavoriteTeam(name: 'Atlético Madrid', country: 'Spain'),
  FavoriteTeam(name: 'Juventus', country: 'Italy'),
  FavoriteTeam(name: 'AC Milan', country: 'Italy'),
  FavoriteTeam(name: 'Inter', country: 'Italy'),
  FavoriteTeam(name: 'Bayern München', country: 'Germany'),
  FavoriteTeam(name: 'Paris Saint-Germain', country: 'France'),
  FavoriteTeam(name: 'FC Porto', country: 'Portugal'),
];

const List<ActivityItem> kRecentActivity = [
  ActivityItem(
    title: 'Real Madrid 2 - 0 Juventus',
    subtitle: 'Champions League • Semi-final',
    timeAgo: '2 hours ago',
    duration: '06:02',
    thumbnailUrl: 'https://picsum.photos/seed/act-rma-juv/200/140',
  ),
  ActivityItem(
    title: 'Man City 4 - 1 Liverpool',
    subtitle: 'Premier League',
    timeAgo: 'Yesterday',
    duration: '04:18',
    thumbnailUrl: 'https://picsum.photos/seed/act-mci-liv/200/140',
  ),
  ActivityItem(
    title: 'Atlético 2 - 1 Sevilla',
    subtitle: 'La Liga',
    timeAgo: '2 days ago',
    duration: '03:56',
    thumbnailUrl: 'https://picsum.photos/seed/act-atm-sev/200/140',
  ),
];

const List<ProfileMenuRow> kProfileMenu = [
  ProfileMenuRow(
    icon: Icons.notifications_none,
    label: 'Notifications',
    badge: 3,
  ),
  ProfileMenuRow(icon: Icons.download_outlined, label: 'Download History'),
  ProfileMenuRow(
    icon: Icons.workspace_premium_outlined,
    label: 'My Subscriptions',
  ),
  ProfileMenuRow(icon: Icons.credit_card, label: 'Payment Methods'),
  ProfileMenuRow(icon: Icons.headset_mic_outlined, label: 'Help & Support'),
  ProfileMenuRow(
    icon: Icons.group_outlined,
    label: 'Invite Friends',
    trailingPill: 'Earn Rewards',
  ),
];
