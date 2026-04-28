class VideoModel {
  final String id;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String creatorId;
  final String creatorUsername;
  final String? musicName;
  final int views;
  final int likes;
  final int shares;
  final int commentCount;
  final DateTime createdAt;
  final double durationSeconds;

  VideoModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    this.thumbnailUrl = '',
    required this.creatorId,
    required this.creatorUsername,
    this.musicName,
    this.views = 0,
    this.likes = 0,
    this.shares = 0,
    this.commentCount = 0,
    DateTime? createdAt,
    this.durationSeconds = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  VideoModel copyWith({
    String? title,
    String? musicName,
    int? views,
    int? likes,
    int? shares,
    int? commentCount,
  }) {
    return VideoModel(
      id: id,
      title: title ?? this.title,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      creatorId: creatorId,
      creatorUsername: creatorUsername,
      musicName: musicName ?? this.musicName,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt,
      durationSeconds: durationSeconds,
    );
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final creator = json['creator'];
    final creatorId = creator is Map
        ? (creator['_id']?.toString() ?? '')
        : (creator?.toString() ?? '');
    return VideoModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      creatorId: creatorId,
      creatorUsername: json['creatorUsername'] ?? '',
      musicName: json['musicName'],
      views: (json['views'] ?? 0) as int,
      likes: (json['likes'] ?? 0) as int,
      shares: (json['shares'] ?? 0) as int,
      commentCount: (json['commentCount'] ?? 0) as int,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      durationSeconds: (json['durationSeconds'] ?? 0).toDouble(),
    );
  }
}
