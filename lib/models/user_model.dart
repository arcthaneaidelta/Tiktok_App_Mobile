enum UserRole { endUser, contentCreator, superAdmin }

enum AccountStatus { active, pending, rejected }

class UserModel {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final AccountStatus status;
  final String? avatarUrl;
  final DateTime createdAt;
  final List<String> likedVideoIds;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.role = UserRole.endUser,
    this.status = AccountStatus.active,
    this.avatarUrl,
    DateTime? createdAt,
    List<String>? likedVideoIds,
  })  : createdAt = createdAt ?? DateTime.now(),
        likedVideoIds = likedVideoIds ?? [];

  UserModel copyWith({
    String? username,
    String? email,
    UserRole? role,
    AccountStatus? status,
    String? avatarUrl,
    List<String>? likedVideoIds,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      likedVideoIds: likedVideoIds ?? this.likedVideoIds,
    );
  }

  String get roleLabel {
    switch (role) {
      case UserRole.endUser:
        return 'End User';
      case UserRole.contentCreator:
        return 'Content Creator';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: _parseRole(json['role']),
      status: _parseStatus(json['status']),
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      likedVideoIds: (json['likedVideoIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  static UserRole _parseRole(dynamic value) {
    switch (value) {
      case 'contentCreator':
        return UserRole.contentCreator;
      case 'superAdmin':
        return UserRole.superAdmin;
      default:
        return UserRole.endUser;
    }
  }

  static AccountStatus _parseStatus(dynamic value) {
    switch (value) {
      case 'pending':
        return AccountStatus.pending;
      case 'rejected':
        return AccountStatus.rejected;
      default:
        return AccountStatus.active;
    }
  }

  static String roleToApi(UserRole role) {
    switch (role) {
      case UserRole.endUser:
        return 'endUser';
      case UserRole.contentCreator:
        return 'contentCreator';
      case UserRole.superAdmin:
        return 'superAdmin';
    }
  }
}
