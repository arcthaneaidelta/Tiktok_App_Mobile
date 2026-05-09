import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/video_model.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/video_preview_sheet.dart';
import '../../widgets/video_thumbnail.dart';

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
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('@${widget.creatorUsername}'),
      ),
      body: FutureBuilder<List<VideoModel>>(
        future: _videosFuture,
        builder: (context, videoSnap) {
          final videos = videoSnap.data ?? [];
          final totalLikes = videos.fold(0, (sum, v) => sum + v.likes);
          final totalViews = videos.fold(0, (sum, v) => sum + v.views);

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              setState(() {
                final provider = context.read<AppProvider>();
                _userFuture = provider.getUserById(widget.creatorId);
                _videosFuture = provider.getVideosByCreator(widget.creatorId);
              });
              await _videosFuture;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
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
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                ),
                const SizedBox(height: 12),
                if (videoSnap.connectionState == ConnectionState.waiting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (videos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: const [
                        Icon(Icons.videocam_off_rounded, color: AppColors.textFaint, size: 48),
                        SizedBox(height: 12),
                        Text('No videos yet', style: TextStyle(color: AppColors.textDim)),
                      ],
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
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.pinkPurple,
            boxShadow: AppShadows.pinkGlow,
          ),
          child: Center(
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '@$username',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
        ),
        if (user?.role == UserRole.contentCreator) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppGradients.pinkPurple,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: const Text(
              'CREATOR',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            _stat('Videos', '$videoCount', Icons.videocam_rounded),
            const SizedBox(width: 10),
            _stat('Likes', _formatCount(totalLikes), Icons.favorite_rounded),
            const SizedBox(width: 10),
            _stat('Views', _formatCount(totalViews), Icons.visibility_rounded),
          ],
        ),
      ],
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _videoTile(VideoModel video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: () => showVideoPreviewSheet(context, video),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                VideoThumbnail(thumbnailUrl: video.thumbnailUrl, size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(video.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatCount(video.views)} views  ·  ${_formatCount(video.likes)} likes',
                        style: const TextStyle(color: AppColors.textDim, fontSize: 12),
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
