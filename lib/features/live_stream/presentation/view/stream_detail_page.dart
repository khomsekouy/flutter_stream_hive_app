import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stream_hive_app/core/di/injection.dart';
import 'package:flutter_stream_hive_app/core/notifications/notification_manager.dart';
import 'package:flutter_stream_hive_app/core/theme/theme.dart';
import 'package:flutter_stream_hive_app/features/live_stream/domain/entities/live_stream.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/content/home_content.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/cubit/stream_detail_cubit.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/saved/saved_streams_store.dart';
import 'package:flutter_stream_hive_app/features/live_stream/presentation/widgets/home_sections.dart';

/// Detail / watch screen for a single stream, reached via `/stream/:id`.
class StreamDetailPage extends StatelessWidget {
  const StreamDetailPage({
    required this.streamId,
    this.initialStream,
    super.key,
  });

  final String streamId;
  final LiveStream? initialStream;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<StreamDetailCubit>(
          param1: streamId,
          param2: initialStream,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: const StreamDetailView(),
    );
  }
}

class StreamDetailView extends StatelessWidget {
  const StreamDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreamDetailCubit, StreamDetailState>(
      builder: (context, state) {
        final stream = state.stream;
        return Scaffold(
          appBar: AppBar(
            title: Text(stream?.title ?? 'Stream'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () =>
                    NotificationManager.info(context, 'Share — coming soon'),
              ),
              _SaveButton(stream: stream),
            ],
          ),
          body: switch (state.status) {
            StreamDetailStatus.initial ||
            StreamDetailStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            StreamDetailStatus.failure => Center(
              child: Text(state.errorMessage ?? 'Could not load this stream.'),
            ),
            StreamDetailStatus.success => _StreamDetailContent(stream: stream!),
          },
        );
      },
    );
  }
}

/// Bookmark toggle in the app bar. Adds/removes the stream from the shared
/// [SavedStreamsStore] and reflects the saved state via the icon.
class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.stream});

  final LiveStream? stream;

  void _toggle(BuildContext context, LiveStream stream) {
    final nowSaved = getIt<SavedStreamsStore>().toggle(stream);
    if (nowSaved) {
      NotificationManager.success(context, 'Saved');
    } else {
      NotificationManager.info(context, 'Removed from saved');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = this.stream;
    if (stream == null) {
      return const IconButton(
        icon: Icon(Icons.bookmark_border),
        onPressed: null,
      );
    }
    final store = getIt<SavedStreamsStore>();
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final saved = store.isSaved(stream.id);
        return IconButton(
          icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
          tooltip: saved ? 'Remove from saved' : 'Save',
          onPressed: () => _toggle(context, stream),
        );
      },
    );
  }
}

class _StreamDetailContent extends StatefulWidget {
  const _StreamDetailContent({required this.stream});

  final LiveStream stream;

  @override
  State<_StreamDetailContent> createState() => _StreamDetailContentState();
}

class _StreamDetailContentState extends State<_StreamDetailContent> {
  bool _expanded = true;

  // Seeded from the sample list; new comments are prepended as the user posts.
  final List<LiveComment> _comments = List.of(kLiveComments);
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() => setState(() => _expanded = !_expanded);

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(
        0,
        LiveComment(author: 'You', text: text, timeAgo: 'now'),
      );
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.stream;
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    return Column(
      children: [
        // Portrait keeps the top fixed and scrolls only the comments. Landscape
        // is too short for a fixed layout, so the whole page scrolls instead.
        Expanded(
          child: isLandscape ? _landscapeBody(stream) : _portraitBody(stream),
        ),
        // Composer pinned to the bottom, like a chat input bar. It stays above
        // the keyboard because the Scaffold resizes around the inset.
        _CommentComposerBar(controller: _controller, onSend: _send),
      ],
    );
  }

  /// Match info + the tappable comments header, shared by both layouts.
  Widget _infoSection(BuildContext context, LiveStream stream) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stream.hasScore && stream.hasMatch)
            _ScoreHeader(stream: stream)
          else
            Text(
              stream.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          const SizedBox(height: 12),
          _StatsRow(
            viewerCount: stream.viewerCount,
            commentCount: stream.commentCount,
          ),
          const SizedBox(height: 24),
          _CommentsHeader(expanded: _expanded, onToggle: _toggle),
        ],
      ),
    );
  }

  /// Portrait: player + info fixed at the top, only the comments list scrolls.
  Widget _portraitBody(LiveStream stream) {
    return Column(
      children: [
        const _PlayerPlaceholder(),
        _infoSection(context, stream),
        if (_expanded)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              itemCount: _comments.length,
              itemBuilder: (context, i) => _CommentTile(comment: _comments[i]),
            ),
          )
        else
          const Spacer(),
      ],
    );
  }

  /// Landscape: everything scrolls together so nothing overflows.
  Widget _landscapeBody(LiveStream stream) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        const _PlayerPlaceholder(),
        _infoSection(context, stream),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                for (final comment in _comments) _CommentTile(comment: comment),
              ],
            ),
          ),
      ],
    );
  }
}

/// Big match header: each team's crest + name with the gold scoreline between.
class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.stream});

  final LiveStream stream;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _TeamBadge(team: stream.homeTeam)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '${stream.homeScore} : ${stream.awayScore}',
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(child: _TeamBadge(team: stream.awayTeam)),
      ],
    );
  }
}

/// A large circular crest with the team name centered beneath it.
class _TeamBadge extends StatelessWidget {
  const _TeamBadge({required this.team});

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

/// Tappable "Live comments" header that collapses/expands the list.
class _CommentsHeader extends StatelessWidget {
  const _CommentsHeader({required this.expanded, required this.onToggle});

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Row(
        children: [
          const Icon(
            Icons.mode_comment_outlined,
            size: 20,
            color: AppColors.primaryLight,
          ),
          const SizedBox(width: 8),
          Text('Live comments', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

/// A single comment row: initials avatar, author + time, then the message.
class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final LiveComment comment;

  /// Up to two uppercase initials derived from the author's name.
  String get _initials {
    final parts = comment.author.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final letters = parts.take(2).map((p) => p[0]).join();
    return letters.toUpperCase();
  }

  static const List<Color> _avatarColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.info,
    AppColors.warning,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        _avatarColors[comment.author.hashCode.abs() % _avatarColors.length];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.25),
            child: Text(
              _initials,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.text, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Editable comment input pinned to the bottom of the screen as a chat-style
/// bar. Submitting (send button or keyboard) posts the comment via [onSend].
class _CommentComposerBar extends StatelessWidget {
  const _CommentComposerBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Write a comment...',
              filled: true,
              fillColor: AppColors.surfaceHigh,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: AppColors.primaryLight),
                onPressed: onSend,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerPlaceholder extends StatefulWidget {
  const _PlayerPlaceholder();

  @override
  State<_PlayerPlaceholder> createState() => _PlayerPlaceholderState();
}

class _PlayerPlaceholderState extends State<_PlayerPlaceholder> {
  void _openFullscreen() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => const _FullscreenPlayer(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _PlayerControls(
        background: const ColoredBox(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: Colors.white70,
                ),
                SizedBox(height: 8),
                Text(
                  'Player goes here (HLS via media_kit / video_player)',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        overlay: Positioned(
          right: 4,
          bottom: 4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _VolumeControl(),
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                tooltip: 'Fullscreen',
                onPressed: _openFullscreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps a player [background] with tap-to-reveal controls. Tapping the video
/// toggles the [overlay] (which must be a [Positioned]); the controls also fade
/// out on their own after a few seconds of inactivity, so the stream isn't
/// cluttered while watching. Interacting with a control resets that timer.
class _PlayerControls extends StatefulWidget {
  const _PlayerControls({required this.background, required this.overlay});

  final Widget background;
  final Widget overlay;

  @override
  State<_PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<_PlayerControls> {
  static const _autoHideAfter = Duration(seconds: 3);

  bool _visible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_autoHideAfter, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  void _toggle() {
    setState(() => _visible = !_visible);
    if (_visible) {
      _scheduleHide();
    } else {
      _hideTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _toggle,
            child: widget.background,
          ),
        ),
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_visible,
              // Touching a control keeps the bar alive; taps on empty space
              // fall through to the GestureDetector above and toggle it.
              child: Listener(
                onPointerDown: (_) => _scheduleHide(),
                child: Stack(children: [widget.overlay]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Volume control for the player overlays: a mute toggle plus an inline slider
/// for fine 0–100% adjustment. UI-only for now — it holds the level in state;
/// wire [_VolumeControlState._effectiveVolume] to a real player's
/// `setVolume(0.0–1.0)` once one is integrated.
class _VolumeControl extends StatefulWidget {
  const _VolumeControl();

  @override
  State<_VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<_VolumeControl> {
  // Last non-zero level the user chose, so unmuting restores it.
  double _volume = 0.8;
  bool _muted = false;

  /// What a real player would receive: 0 while muted, otherwise [_volume].
  double get _effectiveVolume => _muted ? 0 : _volume;

  IconData get _icon {
    if (_effectiveVolume == 0) return Icons.volume_off;
    if (_effectiveVolume < 0.5) return Icons.volume_down;
    return Icons.volume_up;
  }

  void _onSliderChanged(double value) => setState(() {
    _volume = value;
    _muted = value == 0;
  });

  void _toggleMute() => setState(() => _muted = !_muted);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(_icon, color: Colors.white),
          tooltip: _muted ? 'Unmute' : 'Mute',
          onPressed: _toggleMute,
        ),
        SizedBox(
          width: 110,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: _effectiveVolume,
              onChanged: _onSliderChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Landscape, immersive fullscreen player. Locks orientation while open and
/// restores it on exit.
class _FullscreenPlayer extends StatefulWidget {
  const _FullscreenPlayer();

  @override
  State<_FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends State<_FullscreenPlayer> {
  @override
  void initState() {
    super.initState();
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]),
    );
  }

  @override
  void dispose() {
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    unawaited(SystemChrome.setPreferredOrientations(DeviceOrientation.values));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _PlayerControls(
        background: const Center(
          child: Icon(
            Icons.play_circle_outline,
            size: 80,
            color: Colors.white70,
          ),
        ),
        overlay: Positioned(
          top: 8,
          right: 8,
          child: SafeArea(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _VolumeControl(),
                IconButton(
                  icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                  tooltip: 'Exit fullscreen',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Viewers + comments summary, e.g. "12.4K viewers · 328 comments".
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.viewerCount, required this.commentCount});

  final int viewerCount;
  final int commentCount;

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
    return Row(
      children: [
        _StatItem(
          icon: Icons.visibility_outlined,
          text: '${_formatCount(viewerCount)} viewers',
        ),
        const SizedBox(width: 20),
        _StatItem(
          icon: Icons.mode_comment_outlined,
          text: '${_formatCount(commentCount)} comments',
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
