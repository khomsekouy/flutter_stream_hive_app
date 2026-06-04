import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/di/injection.dart';
import 'package:flutter_stream_hive_app/core/router/app_router.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/home_sections.dart';
import 'package:flutter_stream_hive_app/features/profile/presentation/content/profile_content.dart';
import 'package:flutter_stream_hive_app/features/profile/presentation/favorites/favorite_teams_store.dart';
import 'package:go_router/go_router.dart';

/// Browse the full club catalogue and toggle each as a favourite.
class ClubsPage extends StatelessWidget {
  const ClubsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = getIt<FavoriteTeamsStore>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Browse Clubs',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: kAllClubs.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              indent: 72,
              color: AppColors.outline,
            ),
            itemBuilder: (context, i) {
              final club = kAllClubs[i];
              final isFav = store.isFavorite(club.name);
              return _ClubRow(
                club: club,
                isFavorite: isFav,
                onToggle: () => store.toggle(club),
                onOpen: () => context.pushNamed(
                  AppRoute.clubDetail,
                  pathParameters: {'name': club.name},
                  extra: club.country,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ClubRow extends StatelessWidget {
  const _ClubRow({
    required this.club,
    required this.isFavorite,
    required this.onToggle,
    required this.onOpen,
  });

  final FavoriteTeam club;
  final bool isFavorite;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: TeamCrest(team: club.name, size: 40),
      title: Text(
        club.name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        club.country,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? AppColors.live : AppColors.textSecondary,
        ),
        tooltip: isFavorite ? 'Remove from favourites' : 'Add to favourites',
        onPressed: onToggle,
      ),
      onTap: onOpen,
    );
  }
}
