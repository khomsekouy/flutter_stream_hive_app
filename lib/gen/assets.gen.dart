// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/Internazionale_milano.png
  AssetGenImage get internazionaleMilano =>
      const AssetGenImage('assets/images/Internazionale_milano.png');

  /// File path: assets/images/ac_milan.png
  AssetGenImage get acMilan =>
      const AssetGenImage('assets/images/ac_milan.png');

  /// File path: assets/images/arsenal_fc.png
  AssetGenImage get arsenalFc =>
      const AssetGenImage('assets/images/arsenal_fc.png');

  /// File path: assets/images/atletico_madrid.png
  AssetGenImage get atleticoMadrid =>
      const AssetGenImage('assets/images/atletico_madrid.png');

  /// Directory path: assets/images/banners
  $AssetsImagesBannersGen get banners => const $AssetsImagesBannersGen();

  /// File path: assets/images/bayern_munchen.png
  AssetGenImage get bayernMunchen =>
      const AssetGenImage('assets/images/bayern_munchen.png');

  /// File path: assets/images/chelsea.png
  AssetGenImage get chelsea => const AssetGenImage('assets/images/chelsea.png');

  /// File path: assets/images/fc_barcelona.png
  AssetGenImage get fcBarcelona =>
      const AssetGenImage('assets/images/fc_barcelona.png');

  /// File path: assets/images/fc_porto.png
  AssetGenImage get fcPorto =>
      const AssetGenImage('assets/images/fc_porto.png');

  /// File path: assets/images/juventus.png
  AssetGenImage get juventus =>
      const AssetGenImage('assets/images/juventus.png');

  /// File path: assets/images/launch_image.png
  AssetGenImage get launchImage =>
      const AssetGenImage('assets/images/launch_image.png');

  /// Directory path: assets/images/leagues
  $AssetsImagesLeaguesGen get leagues => const $AssetsImagesLeaguesGen();

  /// File path: assets/images/liverpool.png
  AssetGenImage get liverpool =>
      const AssetGenImage('assets/images/liverpool.png');

  /// File path: assets/images/mancherster.png
  AssetGenImage get mancherster =>
      const AssetGenImage('assets/images/mancherster.png');

  /// File path: assets/images/manchester_city.png
  AssetGenImage get manchesterCity =>
      const AssetGenImage('assets/images/manchester_city.png');

  /// File path: assets/images/paris.png
  AssetGenImage get paris => const AssetGenImage('assets/images/paris.png');

  /// File path: assets/images/real_madrid_logo.png
  AssetGenImage get realMadridLogo =>
      const AssetGenImage('assets/images/real_madrid_logo.png');

  /// File path: assets/images/stream_placeholder.png
  AssetGenImage get streamPlaceholder =>
      const AssetGenImage('assets/images/stream_placeholder.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    internazionaleMilano,
    acMilan,
    arsenalFc,
    atleticoMadrid,
    bayernMunchen,
    chelsea,
    fcBarcelona,
    fcPorto,
    juventus,
    launchImage,
    liverpool,
    mancherster,
    manchesterCity,
    paris,
    realMadridLogo,
    streamPlaceholder,
  ];
}

class $AssetsImagesBannersGen {
  const $AssetsImagesBannersGen();

  /// File path: assets/images/banners/banner_001.png
  AssetGenImage get banner001 =>
      const AssetGenImage('assets/images/banners/banner_001.png');

  /// File path: assets/images/banners/banner_002.png
  AssetGenImage get banner002 =>
      const AssetGenImage('assets/images/banners/banner_002.png');

  /// List of all assets
  List<AssetGenImage> get values => [banner001, banner002];
}

class $AssetsImagesLeaguesGen {
  const $AssetsImagesLeaguesGen();

  /// File path: assets/images/leagues/bundesliga.png
  AssetGenImage get bundesliga =>
      const AssetGenImage('assets/images/leagues/bundesliga.png');

  /// File path: assets/images/leagues/italian_serie.png
  AssetGenImage get italianSerie =>
      const AssetGenImage('assets/images/leagues/italian_serie.png');

  /// File path: assets/images/leagues/ligue_1.png
  AssetGenImage get ligue1 =>
      const AssetGenImage('assets/images/leagues/ligue_1.png');

  /// File path: assets/images/leagues/premier_league.png
  AssetGenImage get premierLeague =>
      const AssetGenImage('assets/images/leagues/premier_league.png');

  /// File path: assets/images/leagues/spanish_liga.png
  AssetGenImage get spanishLiga =>
      const AssetGenImage('assets/images/leagues/spanish_liga.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    bundesliga,
    italianSerie,
    ligue1,
    premierLeague,
    spanishLiga,
  ];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
