import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/video_model.dart';
import '../models/comment_model.dart';
import '../services/auth_service.dart';
import '../services/video_service.dart';
import '../services/comment_service.dart';
import '../services/admin_service.dart';

class AppProvider extends ChangeNotifier {
  final _authService = AuthService();
  final _videoService = VideoService();
  final _commentService = CommentService();
  final _adminService = AdminService();

  bool _initializing = true;
  bool get initializing => _initializing;

  UserModel? get currentUser => _authService.currentUser;
  bool get isLoggedIn => currentUser != null;

  // Cached data
  List<VideoModel> _feed = [];
  List<VideoModel> get feed => _feed;
  bool _feedLoading = false;
  bool get feedLoading => _feedLoading;

  List<VideoModel> _likedVideos = [];
  List<VideoModel> get likedVideos => _likedVideos;

  List<VideoModel> _myVideos = [];
  List<VideoModel> get myVideos => _myVideos;

  // Per-video comment cache
  final Map<String, List<CommentModel>> _commentsCache = {};

  AppProvider() {
    _init();
  }

  Future<void> _init() async {
    await _authService.restoreSession();
    _initializing = false;
    notifyListeners();
    if (isLoggedIn) {
      await _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      loadFeed(),
      if (currentUser?.role == UserRole.endUser) loadLikedVideos(),
      if (currentUser?.role == UserRole.contentCreator) loadMyVideos(),
    ]);
  }

  // ---------- Auth ----------
  Future<String?> login(String email, String password) async {
    final result = await _authService.login(email, password);
    if (result.error != null) return result.error;
    notifyListeners();
    await _loadInitialData();
    return null;
  }

  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final result = await _authService.register(
      username: username,
      email: email,
      password: password,
      role: role,
    );
    if (result.pending) return 'pending';
    if (result.error != null) return result.error;
    notifyListeners();
    await _loadInitialData();
    return null;
  }

  Future<void> logout() async {
    await _authService.logout();
    _feed = [];
    _likedVideos = [];
    _myVideos = [];
    _commentsCache.clear();
    notifyListeners();
  }

  // ---------- Videos ----------
  Future<void> loadFeed() async {
    _feedLoading = true;
    notifyListeners();
    try {
      _feed = await _videoService.getFeed();
    } catch (_) {
      _feed = [];
    }
    _feedLoading = false;
    notifyListeners();
  }

  Future<void> loadLikedVideos() async {
    try {
      _likedVideos = await _videoService.getLikedVideos();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadMyVideos() async {
    if (currentUser == null) return;
    try {
      _myVideos = await _videoService.getVideosByCreator(currentUser!.id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> incrementView(String videoId) async {
    await _videoService.incrementView(videoId);
    final idx = _feed.indexWhere((v) => v.id == videoId);
    if (idx != -1) {
      _feed[idx] = _feed[idx].copyWith(views: _feed[idx].views + 1);
      notifyListeners();
    }
  }

  bool isVideoLiked(String videoId) {
    return currentUser?.likedVideoIds.contains(videoId) ?? false;
  }

  Future<void> toggleLike(String videoId) async {
    if (currentUser == null) return;
    final wasLiked = isVideoLiked(videoId);

    final idx = _feed.indexWhere((v) => v.id == videoId);
    VideoModel? videoSnapshot;
    if (idx != -1) {
      _feed[idx] = _feed[idx].copyWith(
        likes: _feed[idx].likes + (wasLiked ? -1 : 1),
      );
      videoSnapshot = _feed[idx];
    } else {
      for (final v in [..._likedVideos, ..._myVideos]) {
        if (v.id == videoId) {
          videoSnapshot = v;
          break;
        }
      }
    }

    if (wasLiked) {
      _likedVideos.removeWhere((v) => v.id == videoId);
    } else if (videoSnapshot != null && !_likedVideos.any((v) => v.id == videoId)) {
      _likedVideos.insert(0, videoSnapshot);
    }
    notifyListeners();

    try {
      await _videoService.toggleLike(videoId);
      await _authService.refreshCurrentUser();
      notifyListeners();
    } catch (_) {
      if (idx != -1) {
        _feed[idx] = _feed[idx].copyWith(
          likes: _feed[idx].likes + (wasLiked ? 1 : -1),
        );
      }
      if (wasLiked && videoSnapshot != null) {
        _likedVideos.insert(0, videoSnapshot);
      } else if (!wasLiked) {
        _likedVideos.removeWhere((v) => v.id == videoId);
      }
      notifyListeners();
    }
  }

  Future<void> shareVideo(String videoId) async {
    await _videoService.incrementShare(videoId);
    final idx = _feed.indexWhere((v) => v.id == videoId);
    if (idx != -1) {
      _feed[idx] = _feed[idx].copyWith(shares: _feed[idx].shares + 1);
      notifyListeners();
    }
  }

  Future<VideoModel> uploadVideo({
    required File videoFile,
    required String title,
    String? musicName,
  }) async {
    final video = await _videoService.uploadVideo(
      videoFile: videoFile,
      title: title,
      musicName: musicName,
    );
    _feed.insert(0, video);
    _myVideos.insert(0, video);
    notifyListeners();
    return video;
  }

  Future<void> deleteVideo(String videoId) async {
    await _videoService.deleteVideo(videoId);
    _feed.removeWhere((v) => v.id == videoId);
    _myVideos.removeWhere((v) => v.id == videoId);
    notifyListeners();
  }

  Future<UserModel?> getUserById(String id) => _authService.getUserById(id);

  Future<List<VideoModel>> getVideosByCreator(String id) =>
      _videoService.getVideosByCreator(id);

  // ---------- Comments ----------
  List<CommentModel> getCachedComments(String videoId) =>
      _commentsCache[videoId] ?? [];

  Future<List<CommentModel>> loadComments(String videoId) async {
    try {
      final comments = await _commentService.getComments(videoId);
      _commentsCache[videoId] = comments;
      notifyListeners();
      return comments;
    } catch (_) {
      return [];
    }
  }

  Future<void> addComment(String videoId, String text) async {
    final comment = await _commentService.addComment(videoId, text);
    _commentsCache.putIfAbsent(videoId, () => []);
    _commentsCache[videoId]!.insert(0, comment);
    final idx = _feed.indexWhere((v) => v.id == videoId);
    if (idx != -1) {
      _feed[idx] = _feed[idx].copyWith(commentCount: _feed[idx].commentCount + 1);
    }
    notifyListeners();
  }

  // ---------- Admin ----------
  Future<AnalyticsData> getAnalytics() => _adminService.getAnalytics();
  Future<List<UserModel>> getAllUsers() => _adminService.getAllUsers();
  Future<List<UserModel>> getPendingCreators() => _adminService.getPendingCreators();
  Future<List<VideoModel>> getAdminVideos({String? creator, String? sortBy}) =>
      _adminService.getAllVideos(creator: creator, sortBy: sortBy);

  Future<void> approveCreator(String userId) async {
    await _adminService.approveCreator(userId);
    notifyListeners();
  }

  Future<void> rejectCreator(String userId) async {
    await _adminService.rejectCreator(userId);
    notifyListeners();
  }

  Future<void> adminDeleteVideo(String videoId) async {
    await _videoService.deleteVideo(videoId);
    _feed.removeWhere((v) => v.id == videoId);
    notifyListeners();
  }
}
