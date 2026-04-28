class ApiConfig {
  // Production API base URL
  static const String baseUrl = 'https://tiktokappbackend-production.up.railway.app';

  static const String apiPath = '/api';

  // Endpoints
  static String get authRegister => '$baseUrl$apiPath/auth/register';
  static String get authLogin => '$baseUrl$apiPath/auth/login';
  static String get authMe => '$baseUrl$apiPath/auth/me';

  static String get videosFeed => '$baseUrl$apiPath/videos/feed';
  static String get videosLiked => '$baseUrl$apiPath/videos/liked';
  static String get videosUpload => '$baseUrl$apiPath/videos/upload';
  static String videosByCreator(String id) => '$baseUrl$apiPath/videos/creator/$id';
  static String videoView(String id) => '$baseUrl$apiPath/videos/$id/view';
  static String videoLike(String id) => '$baseUrl$apiPath/videos/$id/like';
  static String videoShare(String id) => '$baseUrl$apiPath/videos/$id/share';
  static String videoDelete(String id) => '$baseUrl$apiPath/videos/$id';

  static String comments(String videoId) => '$baseUrl$apiPath/comments/$videoId';

  static String get adminAnalytics => '$baseUrl$apiPath/admin/analytics';
  static String get adminUsers => '$baseUrl$apiPath/admin/users';
  static String get adminPending => '$baseUrl$apiPath/admin/pending';
  static String adminVideos({String? creator, String? sortBy}) {
    final params = <String, String>{};
    if (creator != null && creator.isNotEmpty) params['creator'] = creator;
    if (sortBy != null && sortBy.isNotEmpty) params['sortBy'] = sortBy;
    final qs = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
    return '$baseUrl$apiPath/admin/videos$qs';
  }
  static String adminApprove(String id) => '$baseUrl$apiPath/admin/approve/$id';
  static String adminReject(String id) => '$baseUrl$apiPath/admin/reject/$id';
}
