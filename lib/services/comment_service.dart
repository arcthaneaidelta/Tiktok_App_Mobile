import '../models/comment_model.dart';
import 'api_client.dart';
import 'api_config.dart';

class CommentService {
  static final CommentService _instance = CommentService._();
  factory CommentService() => _instance;
  CommentService._();

  final _api = ApiClient();

  Future<List<CommentModel>> getComments(String videoId) async {
    final res = await _api.get(ApiConfig.comments(videoId));
    final list = (res['comments'] as List?) ?? [];
    return list
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CommentModel> addComment(String videoId, String text) async {
    final res = await _api.post(ApiConfig.comments(videoId), {'text': text});
    return CommentModel.fromJson(res['comment'] as Map<String, dynamic>);
  }
}
