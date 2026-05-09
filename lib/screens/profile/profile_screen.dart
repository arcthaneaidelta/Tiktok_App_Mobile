import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/video_model.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/video_preview_sheet.dart';
import '../../widgets/video_thumbnail.dart';

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
          backgroundColor: AppColors.background,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => provider.logout(),
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: AppGradients.backgroundGlow),
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 120),
                child: Column(
                  children: [
                    _avatarHeader(user),
                    const SizedBox(height: 28),
                    if (user.role == UserRole.endUser)
                      _buildEndUserContent(context, provider),
                    if (user.role == UserRole.contentCreator)
                      _buildCreatorContent(context, provider, user),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _avatarHeader(UserModel user) {
    return Column(
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.pinkPurple,
            boxShadow: AppShadows.pinkGlow,
          ),
          child: Center(
            child: Text(
              user.username[0].toUpperCase(),
              style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '@${user.username}',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(user.email, style: const TextStyle(color: AppColors.textDim, fontSize: 13)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _roleColor(user.role).withOpacity(0.25),
                _roleColor(user.role).withOpacity(0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: _roleColor(user.role).withOpacity(0.6)),
          ),
          child: Text(
            user.roleLabel.toUpperCase(),
            style: TextStyle(
              color: _roleColor(user.role),
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _emptyBlock(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: AppColors.textFaint, size: 48),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: AppColors.textDim)),
          ],
        ),
      ),
    );
  }

  Widget _buildEndUserContent(BuildContext context, AppProvider provider) {
    final likedVideos = provider.likedVideos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Liked Videos'),
        if (likedVideos.isEmpty)
          _emptyBlock(Icons.favorite_border_rounded, 'No liked videos yet')
        else
          ...likedVideos.map((video) => _likedVideoTile(video)),
      ],
    );
  }

  Widget _likedVideoTile(VideoModel video) {
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
                VideoThumbnail(thumbnailUrl: video.thumbnailUrl, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(video.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('@${video.creatorUsername}',
                          style: const TextStyle(color: AppColors.textDim, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(height: 2),
                    Text('${video.likes}',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
        Row(
          children: [
            _statCard('Videos', '${videos.length}', Icons.videocam_rounded),
            const SizedBox(width: 10),
            _statCard('Views', _formatCount(totalViews), Icons.visibility_rounded),
            const SizedBox(width: 10),
            _statCard('Likes', _formatCount(totalLikes), Icons.favorite_rounded),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _statCard('Comments', _formatCount(totalComments), Icons.comment_rounded),
            const Spacer(flex: 2),
          ],
        ),
        const SizedBox(height: 26),
        _sectionTitle('My Videos'),
        if (videos.isEmpty)
          _emptyBlock(Icons.videocam_off_rounded, 'No videos uploaded yet')
        else
          ...videos.map((video) => _myVideoTile(video)),
      ],
    );
  }

  Widget _myVideoTile(VideoModel video) {
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
                VideoThumbnail(thumbnailUrl: video.thumbnailUrl, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(video.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatCount(video.views)} · ${_formatCount(video.likes)} ❤ · ${_formatCount(video.commentCount)} 💬',
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

  Widget _statCard(String label, String value, IconData icon) {
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
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
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
        return AppColors.tertiary;
      case UserRole.contentCreator:
        return AppColors.primary;
      case UserRole.superAdmin:
        return AppColors.warning;
    }
  }
}
