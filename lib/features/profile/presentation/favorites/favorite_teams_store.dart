import 'package:flutter/foundation.dart';
import 'package:flutter_stream_hive_app/features/profile/presentation/content/profile_content.dart';

/// In-memory store of the clubs the user has marked as favourites.
///
/// Registered as a singleton so the "Browse clubs" screen and the profile
/// favourites row/count share the same data. Not persisted yet — swap the
/// backing list for a repository once a favourites API/local store exists.
class FavoriteTeamsStore extends ChangeNotifier {
  FavoriteTeamsStore({List<FavoriteTeam> initial = const []})
    : _items = [...initial];

  final List<FavoriteTeam> _items;

  /// Favourite clubs, most recently added first.
  List<FavoriteTeam> get items => List.unmodifiable(_items);

  bool isFavorite(String name) => _items.any((t) => t.name == name);

  /// Adds the club if it isn't a favourite, removes it if it is. Returns the
  /// new favourite state.
  bool toggle(FavoriteTeam team) {
    final index = _items.indexWhere((t) => t.name == team.name);
    final nowFavorite = index < 0;
    if (nowFavorite) {
      _items.insert(0, team);
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
    return nowFavorite;
  }
}
