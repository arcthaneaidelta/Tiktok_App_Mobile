import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
// ignore: deprecated_member_use
import 'package:share_plus/share_plus.dart';
import '../../models/video_model.dart';
import '../../providers/app_provider.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../comments/comments_sheet.dart';
import '../profile/creator_profile_screen.dart';

class VideoFeedScreen extends StatefulWidget {
  final bool isScreenActive;
  const VideoFeedScreen({super.key, this.isScreenActive = true});

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final videos = provider.feed;

        if (provider.feedLoading && videos.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.pinkAccent),
          );
        }

        if (videos.isEmpty) {
          return RefreshIndicator(
            onRefresh: provider.loadFeed,
            color: Colors.pinkAccent,
            backgroundColor: AppColors.surface,
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_library_outlined, color: Colors.white24, size: 64),
                        SizedBox(height: 12),
                        Text('No videos yet', style: TextStyle(color: Colors.white54, fontSize: 18)),
                        SizedBox(height: 4),
                        Text('Pull down to refresh', style: TextStyle(color: Colors.white24, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadFeed,
          color: Colors.pinkAccent,
          backgroundColor: AppColors.surface,
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              provider.incrementView(videos[index].id);
            },
            itemBuilder: (context, index) {
              return VideoCard(
                key: ValueKey(videos[index].id),
                video: videos[index],
                isActive: index == _currentPage && widget.isScreenActive,
              );
            },
          ),
        );
      },
    );
  }
}

class VideoCard extends StatefulWidget {
  final VideoModel video;
  final bool isActive;

  const VideoCard({super.key, required this.video, required this.isActive});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showPlayPause = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    final token = ApiClient().token;
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
      httpHeaders: token != null ? {'Authorization': 'Bearer $token'} : const {},
    )
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          if (widget.isActive) _controller.play();
        }
      });
  }

  @override
  void didUpdateWidget(VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.value.isPlaying) {
      _controller.play();
    } else if (!widget.isActive && _controller.value.isPlaying) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _showPlayPause = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showPlayPause = false);
    });
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isLiked = provider.isVideoLiked(widget.video.id);

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video
          Container(color: Colors.black),
          if (_initialized)
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.pinkAccent)),

          // Play/Pause indicator
          if (_showPlayPause)
            Center(
              child: AnimatedOpacity(
                opacity: _showPlayPause ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller.value.isPlaying ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),

          // Bottom info
          Positioned(
            bottom: 80,
            left: 16,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _openCreatorProfile,
                  child: Text(
                    '@${widget.video.creatorUsername}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.video.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.video.musicName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.music_note, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.video.musicName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Right side buttons
          Positioned(
            right: 12,
            bottom: 100,
            child: Column(
              children: [
                // Profile avatar
                GestureDetector(
                  onTap: _openCreatorProfile,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.pinkAccent,
                    child: Text(
                      widget.video.creatorUsername.isNotEmpty
                          ? widget.video.creatorUsername[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Like
                _sideButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: _formatCount(widget.video.likes),
                  color: isLiked ? Colors.pinkAccent : Colors.white,
                  onTap: () => provider.toggleLike(widget.video.id),
                ),
                const SizedBox(height: 20),

                // Comment
                _sideButton(
                  icon: Icons.comment,
                  label: _formatCount(widget.video.commentCount),
                  onTap: () => _showComments(context),
                ),
                const SizedBox(height: 20),

                // Share
                _sideButton(
                  icon: Icons.share,
                  label: _formatCount(widget.video.shares),
                  onTap: () {
                    provider.shareVideo(widget.video.id);
                    Share.share('Check out "${widget.video.title}" on Loopz!');
                  },
                ),
                const SizedBox(height: 20),

                // Views
                _sideButton(
                  icon: Icons.visibility,
                  label: _formatCount(widget.video.views),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Progress bar
          if (_initialized)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.pinkAccent,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sideButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32, shadows: const [Shadow(blurRadius: 4, color: Colors.black)]),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(videoId: widget.video.id),
    );
  }

  void _openCreatorProfile() {
    if (widget.video.creatorId.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreatorProfileScreen(
          creatorId: widget.video.creatorId,
          creatorUsername: widget.video.creatorUsername,
        ),
      ),
    );
  }
}
