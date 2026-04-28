import '../models/user_model.dart';
import '../models/video_model.dart';
import 'api_client.dart';
import 'api_config.dart';

class AnalyticsData {
  final int totalVideos;
  final int totalUsers;
  final int totalComments;
  final int pendingCount;
  final int totalViews;
  final int totalLikes;
  final int totalShares;
  final List<VideoModel> topVideos;

  AnalyticsData({
    required this.totalVideos,
    required this.totalUsers,
    required this.totalComments,
    required this.pendingCount,
    required this.totalViews,
    required this.totalLikes,
    required this.totalShares,
    required this.topVideos,
  });
}

class AdminService {
  static final AdminService _instance = AdminService._();
  factory AdminService() => _instance;
  AdminService._();

  final _api = ApiClient();

  Future<AnalyticsData> getAnalytics() async {
    final res = await _api.get(ApiConfig.adminAnalytics);
    final a = res['analytics'] as Map<String, dynamic>;
    final topList = (res['topVideos'] as List?) ?? [];
    return AnalyticsData(
      totalVideos: (a['totalVideos'] ?? 0) as int,
      totalUsers: (a['totalUsers'] ?? 0) as int,
      totalComments: (a['totalComments'] ?? 0) as int,
      pendingCount: (a['pendingCount'] ?? 0) as int,
      totalViews: (a['totalViews'] ?? 0) as int,
      totalLikes: (a['totalLikes'] ?? 0) as int,
      totalShares: (a['totalShares'] ?? 0) as int,
      topVideos: topList
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<List<UserModel>> getAllUsers() async {
    final res = await _api.get(ApiConfig.adminUsers);
    final list = (res['users'] as List?) ?? [];
    return list
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserModel>> getPendingCreators() async {
    final res = await _api.get(ApiConfig.adminPending);
    final list = (res['users'] as List?) ?? [];
    return list
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VideoModel>> getAllVideos({String? creator, String? sortBy}) async {
    final res = await _api.get(ApiConfig.adminVideos(creator: creator, sortBy: sortBy));
    final list = (res['videos'] as List?) ?? [];
    return list
        .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> approveCreator(String userId) async {
    await _api.put(ApiConfig.adminApprove(userId));
  }

  Future<void> rejectCreator(String userId) async {
    await _api.put(ApiConfig.adminReject(userId));
  }
}
