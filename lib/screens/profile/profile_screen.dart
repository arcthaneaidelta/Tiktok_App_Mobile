import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/video_preview_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AppProvider>();
      if (p.currentUser?.role == UserRole.endUser) p.loadLikedVideos();
      if (p.currentUser?.role == UserRole.contentCreator) p.loadMyVideos();
    });
  }

  Future<void> _refresh() async {
    final p = context.read<AppProvider>();
    if (p.currentUser?.role == UserRole.endUser) await p.loadLikedVideos();
    if (p.currentUser?.role == UserRole.contentCreator) await p.loadMyVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final user = provider.currentUser;
        if (user == null) return const SizedBox();

        return Scaffold(
          backgroundColor: const Color(0xFF1a1a2e),
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => provider.logout(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            color: Colors.pinkAccent,
            backgroundColor: const Color(0xFF1a1a2e),
            child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.pinkAccent,
                  child: Text(
                    user.username[0].toUpperCase(),
                    style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '@${user.username}',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(user.email, style: const TextStyle(color: Colors.white54)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: _roleColor(user.role).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _roleColor(user.role).withOpacity(0.5)),
                  ),
                  child: Text(
                    user.roleLabel,
                    style: TextStyle(color: _roleColor(user.role), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 32),

                // Content based on role
                if (user.role == UserRole.endUser) _buildEndUserContent(context, provider),
                if (user.role == UserRole.contentCreator) _buildCreatorContent(context, provider, user),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildEndUserContent(BuildContext context, AppProvider provider) {
    final likedVideos = provider.likedVideos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Liked Videos',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (likedVideos.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.favorite_border, color: Colors.white30, size: 48),
                  SizedBox(height: 8),
                  Text('No liked videos yet', style: TextStyle(color: Colors.white38)),
                ],
              ),
            ),
          )
        else
          ...likedVideos.map((video) => Container(
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
                            width: 60,
                            height: 60,
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
                                Text('@${video.creatorUsername}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text('${video.likes}', style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                              const Icon(Icons.favorite, color: Colors.pinkAccent, size: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildCreatorContent(BuildContext context, AppProvider provider, UserModel user) {
    final videos = provider.myVideos;
    final totalViews = videos.fold(0, (sum, v) => sum + v.views);
    final totalLikes = videos.fold(0, (sum, v) => sum + v.likes);
    final totalComments = videos.fold(0, (sum, v) => sum + v.commentCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats row
        Row(
          children: [
            _statCard('Videos', '${videos.length}', Icons.videocam),
            const SizedBox(width: 12),
            _statCard('Views', _formatCount(totalViews), Icons.visibility),
            const SizedBox(width: 12),
            _statCard('Likes', _formatCount(totalLikes), Icons.favorite),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard('Comments', _formatCount(totalComments), Icons.comment),
            const Spacer(flex: 2),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'My Videos',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (videos.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.videocam_off, color: Colors.white30, size: 48),
                  SizedBox(height: 8),
                  Text('No videos uploaded yet', style: TextStyle(color: Colors.white38)),
                ],
              ),
            ),
          )
        else
          ...videos.map((video) => Container(
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
                            width: 60,
                            height: 60,
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
                                  '${_formatCount(video.views)} views  |  ${_formatCount(video.likes)} likes  |  ${_formatCount(video.commentCount)} comments',
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
              )),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.pinkAccent, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.endUser:
        return Colors.blueAccent;
      case UserRole.contentCreator:
        return Colors.pinkAccent;
      case UserRole.superAdmin:
        return Colors.amber;
    }
  }
}
