import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/video_model.dart';
import '../../providers/app_provider.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/video_preview_sheet.dart';
import '../../widgets/video_thumbnail.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sortBy = 'date';
  final _searchController = TextEditingController();

  // Cached futures so we don't refetch on every rebuild
  Future<AnalyticsData>? _analyticsFuture;
  Future<List<UserModel>>? _usersFuture;
  Future<List<UserModel>>? _pendingFuture;
  Future<List<VideoModel>>? _videosFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshAll() {
    final p = context.read<AppProvider>();
    setState(() {
      _analyticsFuture = p.getAnalytics();
      _usersFuture = p.getAllUsers();
      _pendingFuture = p.getPendingCreators();
      _videosFuture = p.getAdminVideos(
        creator: _searchController.text.isEmpty ? null : _searchController.text,
        sortBy: _sortBy,
      );
    });
  }

  void _refreshVideos() {
    final p = context.read<AppProvider>();
    setState(() {
      _videosFuture = p.getAdminVideos(
        creator: _searchController.text.isEmpty ? null : _searchController.text,
        sortBy: _sortBy,
      );
    });
  }

  void _refreshUsers() {
    final p = context.read<AppProvider>();
    setState(() {
      _usersFuture = p.getAllUsers();
      _pendingFuture = p.getPendingCreators();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: ShaderMask(
              shaderCallback: (rect) => AppGradients.brand.createShader(rect),
              child: const Text(
                'Admin Dashboard',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.4),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _refreshAll),
              IconButton(icon: const Icon(Icons.logout_rounded), onPressed: () => provider.logout()),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: AppColors.border),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: AppGradients.pinkPurple,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textDim,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                  tabs: const [
                    Tab(text: 'Analytics', icon: Icon(Icons.analytics_rounded, size: 18)),
                    Tab(text: 'Videos', icon: Icon(Icons.video_library_rounded, size: 18)),
                    Tab(text: 'Users', icon: Icon(Icons.people_rounded, size: 18)),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAnalyticsTab(provider),
              _buildVideosTab(provider),
              _buildUsersTab(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab(AppProvider provider) {
    return FutureBuilder<AnalyticsData>(
      future: _analyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _errorView(snapshot.error.toString(), () {
            setState(() => _analyticsFuture = provider.getAnalytics());
          });
        }
        final a = snapshot.data!;
        return RefreshIndicator(
          color: Colors.pinkAccent,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            setState(() => _analyticsFuture = provider.getAnalytics());
            await _analyticsFuture;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overview',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _analyticsCard('Videos', '${a.totalVideos}', Icons.videocam_rounded, AppColors.primary),
                    const SizedBox(width: 10),
                    _analyticsCard('Views', _formatCount(a.totalViews), Icons.visibility_rounded, AppColors.tertiary),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _analyticsCard('Likes', _formatCount(a.totalLikes), Icons.favorite_rounded, AppColors.danger),
                    const SizedBox(width: 10),
                    _analyticsCard('Comments', _formatCount(a.totalComments), Icons.comment_rounded, AppColors.success),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _analyticsCard('Users', '${a.totalUsers}', Icons.people_rounded, AppColors.secondary),
                    const SizedBox(width: 10),
                    _analyticsCard('Pending', '${a.pendingCount}', Icons.pending_actions_rounded, AppColors.warning),
                  ],
                ),
                const SizedBox(height: 28),
                const Text('Top Videos',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                const SizedBox(height: 14),
                if (a.topVideos.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(child: Text('No videos yet', style: TextStyle(color: AppColors.textDim))),
                  )
                else
                  ...a.topVideos.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final video = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: rank == 1
                                  ? AppColors.warning.withOpacity(0.2)
                                  : AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(AppRadii.sm),
                            ),
                            child: Center(
                              child: Text('$rank',
                                  style: TextStyle(
                                      color: rank == 1 ? AppColors.warning : AppColors.textDim,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          VideoThumbnail(thumbnailUrl: video.thumbnailUrl, size: 44),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(video.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                Text('@${video.creatorUsername}',
                                    style: const TextStyle(color: AppColors.textDim, fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${_formatCount(video.views)} views',
                                  style: const TextStyle(color: AppColors.tertiary, fontSize: 12, fontWeight: FontWeight.w600)),
                              Text('${_formatCount(video.likes)} likes',
                                  style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideosTab(AppProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by creator...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _refreshVideos(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.pinkAccent),
                onPressed: _refreshVideos,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort, color: Colors.white54),
                color: AppColors.surfaceElevated,
                onSelected: (value) {
                  setState(() => _sortBy = value);
                  _refreshVideos();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'date', child: Text('Sort by Date', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'views', child: Text('Sort by Views', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'likes', child: Text('Sort by Likes', style: TextStyle(color: Colors.white))),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<VideoModel>>(
            future: _videosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _errorView(snapshot.error.toString(), _refreshVideos);
              }
              final videos = snapshot.data ?? [];
              if (videos.isEmpty) {
                return const Center(
                  child: Text('No videos found', style: TextStyle(color: Colors.white38)),
                );
              }
              return RefreshIndicator(
                color: Colors.pinkAccent,
                backgroundColor: AppColors.surface,
                onRefresh: () async {
                  _refreshVideos();
                  await _videosFuture;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
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
                          onTap: () => _openVideoPreview(context, video),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                VideoThumbnail(thumbnailUrl: video.thumbnailUrl, size: 64),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(video.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                      Text('@${video.creatorUsername}',
                                          style: const TextStyle(color: AppColors.textDim, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_formatCount(video.views)} views · ${_formatCount(video.likes)} likes · ${_formatCount(video.commentCount)} comments',
                                        style: const TextStyle(color: AppColors.textFaint, fontSize: 11),
                                      ),
                                      Text(
                                        DateFormat('MMM d, yyyy').format(video.createdAt),
                                        style: const TextStyle(color: AppColors.textFaint, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                                  onPressed: () => _confirmDeleteVideo(context, provider, video.id, video.title),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab(AppProvider provider) {
    return RefreshIndicator(
      color: Colors.pinkAccent,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        _refreshUsers();
        await Future.wait([_usersFuture!, _pendingFuture!]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<UserModel>>(
              future: _pendingFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return _errorView(snapshot.error.toString(), _refreshUsers);
                }
                final pending = snapshot.data ?? [];
                if (pending.isEmpty) return const SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pending Approvals',
                      style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...pending.map((user) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.amber.withOpacity(0.3),
                                child: Text(_initial(user.username), style: const TextStyle(color: Colors.amber)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    Text(user.email, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                                onPressed: () async {
                                  await provider.approveCreator(user.id);
                                  _refreshUsers();
                                  if (mounted) {
                                    setState(() => _analyticsFuture = provider.getAnalytics());
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                                onPressed: () async {
                                  await provider.rejectCreator(user.id);
                                  _refreshUsers();
                                },
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
            const Text(
              'All Users',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<UserModel>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return _errorView(snapshot.error.toString(), _refreshUsers);
                }
                final users = snapshot.data ?? [];
                return Column(
                  children: users.map((user) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: _roleColor(user.role).withOpacity(0.3),
                              child: Text(_initial(user.username), style: TextStyle(color: _roleColor(user.role))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text(user.email, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _roleColor(user.role).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(user.roleLabel, style: TextStyle(color: _roleColor(user.role), fontSize: 11)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.status.name,
                                  style: TextStyle(
                                    color: user.status == AccountStatus.active ? Colors.green : Colors.orange,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _analyticsCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _errorView(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteVideo(BuildContext context, AppProvider provider, String videoId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Delete Video', style: TextStyle(color: Colors.white)),
        content: Text('Delete "$title"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await provider.adminDeleteVideo(videoId);
                _refreshVideos();
                setState(() => _analyticsFuture = provider.getAnalytics());
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String _initial(String s) => s.isNotEmpty ? s[0].toUpperCase() : '?';

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

  void _openVideoPreview(BuildContext context, VideoModel video) {
    showVideoPreviewSheet(context, video);
  }
}
