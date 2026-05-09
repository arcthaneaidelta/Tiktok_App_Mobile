import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/video_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/video_preview_sheet.dart';

class CreatorProfileScreen extends StatefulWidget {
  final String creatorId;
  final String creatorUsername;
  const CreatorProfileScreen({
    super.key,
    required this.creatorId,
    required this.creatorUsername,
  });

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> {
  Future<UserModel?>? _userFuture;
  Future<List<VideoModel>>? _videosFuture;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _userFuture = provider.getUserById(widget.creatorId);
    _videosFuture = provider.getVideosByCreator(widget.creatorId);
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        foregroundColor: Colors.white,
        title: Text('@${widget.creatorUsername}'),
        elevation: 0,
      ),
      body: FutureBuilder<List<VideoModel>>(
        future: _videosFuture,
        builder: (context, videoSnap) {
          final videos = videoSnap.data ?? [];
          final totalLikes = videos.fold(0, (sum, v) => sum + v.likes);
          final totalViews = videos.fold(0, (sum, v) => sum + v.views);

          return RefreshIndicator(
            color: Colors.pinkAccent,
            backgroundColor: const Color(0xFF1a1a2e),
            onRefresh: () async {
              setState(() {
                final provider = context.read<AppProvider>();
                _userFuture = provider.getUserById(widget.creatorId);
                _videosFuture = provider.getVideosByCreator(widget.creatorId);
              });
              await _videosFuture;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FutureBuilder<UserModel?>(
                  future: _userFuture,
                  builder: (context, userSnap) {
                    final user = userSnap.data;
                    return _buildHeader(user, videos.length, totalLikes, totalViews);
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Videos',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (videoSnap.connectionState == ConnectionState.waiting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: Colors.pinkAccent),
                    ),
                  )
                else if (videos.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(Icons.videocam_off, color: Colors.white24, size: 48),
                          const SizedBox(height: 12),
                          Text('No videos yet', style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    ),
                  )
                else
                  ...videos.map((video) => _videoTile(video)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(UserModel? user, int videoCount, int totalLikes, int totalViews) {
    final username = user?.username ?? widget.creatorUsername;
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: Colors.pinkAccent,
          child: Text(
            username.isNotEmpty ? username[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '@$username',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (user?.role == UserRole.contentCreator) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.pinkAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Creator',
              style: TextStyle(color: Colors.pinkAccent, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            _stat('Videos', '$videoCount', Icons.videocam),
            const SizedBox(width: 12),
            _stat('Likes', _formatCount(totalLikes), Icons.favorite),
            const SizedBox(width: 12),
            _stat('Views', _formatCount(totalViews), Icons.visibility),
          ],
        ),
      ],
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.pinkAccent, size: 22),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _videoTile(VideoModel video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => showVideoPreviewSheet(context, video),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.pinkAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(video.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatCount(video.views)} views  |  ${_formatCount(video.likes)} likes',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
