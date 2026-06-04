import 'package:flutter/foundation.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';

/// In-memory store of the streams the user has saved.
///
/// Registered as a singleton so the save buttons (stream detail) and the Saved
/// list read and write the same data. It is not persisted yet — swap the
/// backing list for a repository once a saved-streams API/local store exists.
class SavedStreamsStore extends ChangeNotifier {
  final List<LiveStream> _items = [];

  /// Saved streams, most recently saved first.
  List<LiveStream> get items => List.unmodifiable(_items);

  bool isSaved(String id) => _items.any((s) => s.id == id);

  /// Adds the stream if it isn't saved, removes it if it is. Returns the new
  /// saved state.
  bool toggle(LiveStream stream) {
    final index = _items.indexWhere((s) => s.id == stream.id);
    final nowSaved = index < 0;
    if (nowSaved) {
      _items.insert(0, stream);
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
    return nowSaved;
  }
}
