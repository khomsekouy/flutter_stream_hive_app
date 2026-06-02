import 'package:flutter_stream_hive_app/gen/assets.gen.dart';

/// Resolves a team name to its bundled crest, if we ship one..
abstract final class ClubLogo {
  const ClubLogo._();

  static final Map<String, AssetGenImage> _byName = {
    'arsenal': Assets.images.arsenalFc,
    'chelsea': Assets.images.chelsea,
    'liverpool': Assets.images.liverpool,
    'manchester city': Assets.images.manchesterCity,
    'man city': Assets.images.manchesterCity,
    'manchester united': Assets.images.mancherster,
    'man united': Assets.images.mancherster,
    'man utd': Assets.images.mancherster,
    'real madrid': Assets.images.realMadridLogo,
    'barcelona': Assets.images.fcBarcelona,
    'fc barcelona': Assets.images.fcBarcelona,
    'atletico madrid': Assets.images.atleticoMadrid,
    'atlético madrid': Assets.images.atleticoMadrid,
    'juventus': Assets.images.juventus,
    'ac milan': Assets.images.acMilan,
    'milan': Assets.images.acMilan,
    'inter': Assets.images.internazionaleMilano,
    'inter milan': Assets.images.internazionaleMilano,
    'internazionale': Assets.images.internazionaleMilano,
    'bayern munich': Assets.images.bayernMunchen,
    'bayern münchen': Assets.images.bayernMunchen,
    'bayern': Assets.images.bayernMunchen,
    'paris saint-germain': Assets.images.paris,
    'paris': Assets.images.paris,
    'psg': Assets.images.paris,
    'porto': Assets.images.fcPorto,
    'fc porto': Assets.images.fcPorto,
  };

  /// The crest for [teamName], or null when none is bundled.
  static AssetGenImage? forTeam(String? teamName) {
    if (teamName == null) return null;
    return _byName[teamName.trim().toLowerCase()];
  }
}
