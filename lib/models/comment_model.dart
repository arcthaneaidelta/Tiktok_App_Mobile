class CommentModel {
  final String id;
  final String videoId;
  final String userId;
  final String username;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.username,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userId = user is Map
        ? (user['_id']?.toString() ?? '')
        : (user?.toString() ?? '');
    return CommentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      videoId: (json['video'] ?? '').toString(),
      userId: userId,
      username: json['username'] ?? '',
      text: json['text'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
