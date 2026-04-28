import 'dart:io';
import '../models/video_model.dart';
import 'api_client.dart';
import 'api_config.dart';

class VideoService {
  static final VideoService _instance = VideoService._();
  factory VideoService() => _instance;
  VideoService._();

  final _api = ApiClient();

  Future<List<VideoModel>> getFeed() async {
    final res = await _api.get(ApiConfig.videosFeed);
    final list = (res['videos'] as List?) ?? [];
    return list
        .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VideoModel>> getVideosByCreator(String creatorId) async {
    final res = await _api.get(ApiConfig.videosByCreator(creatorId));
    final list = (res['videos'] as List?) ?? [];
    return list
        .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VideoModel>> getLikedVideos() async {
    final res = await _api.get(ApiConfig.videosLiked);
    final list = (res['videos'] as List?) ?? [];
    return list
        .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<VideoModel> uploadVideo({
    required File videoFile,
    required String title,
    String? musicName,
  }) async {
    final res = await _api.uploadVideo(
      ApiConfig.videosUpload,
      videoFile,
      fields: {
        'title': title,
        if (musicName != null && musicName.isNotEmpty) 'musicName': musicName,
      },
    );
    return VideoModel.fromJson(res['video'] as Map<String, dynamic>);
  }

  Future<void> incrementView(String videoId) async {
    try {
      await _api.put(ApiConfig.videoView(videoId));
    } catch (_) {}
  }

  /// Returns the new liked state
  Future<bool> toggleLike(String videoId) async {
    final res = await _api.put(ApiConfig.videoLike(videoId));
    return res['liked'] == true;
  }

  Future<void> incrementShare(String videoId) async {
    try {
      await _api.put(ApiConfig.videoShare(videoId));
    } catch (_) {}
  }

  Future<void> deleteVideo(String videoId) async {
    await _api.delete(ApiConfig.videoDelete(videoId));
  }
}
