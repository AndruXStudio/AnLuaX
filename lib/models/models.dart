enum UserRole { user, contributor, admin, creator }

class AnUser {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final UserRole role;
  final int points;
  final bool banned;
  final String? banReason;
  final String? banAt;
  final String? unbanAt;
  final String? violation;
  final String? reviewAt;
  final DateTime? joinedAt;

  const AnUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.role = UserRole.user,
    this.points = 0,
    this.banned = false,
    this.banReason,
    this.banAt,
    this.unbanAt,
    this.violation,
    this.reviewAt,
    this.joinedAt,
  });

  factory AnUser.fromJson(Map m) => AnUser(
        id: '${m['id'] ?? ''}',
        username: '${m['username'] ?? ''}',
        displayName: '${m['displayName'] ?? m['username'] ?? ''}',
        avatarUrl: m['avatarUrl']?.toString(),
        role: switch ('${m['role']}') {
          'creator' => UserRole.creator,
          'admin' => UserRole.admin,
          'contributor' => UserRole.contributor,
          _ => UserRole.user,
        },
        points: (m['points'] as num?)?.toInt() ?? 0,
        banned: m['banned'] == true,
        banReason: m['banReason']?.toString(),
        banAt: m['banAt']?.toString(),
        unbanAt: m['unbanAt']?.toString(),
        violation: m['violation']?.toString(),
        reviewAt: m['reviewAt']?.toString(),
        joinedAt: m['joinedAt'] != null ? DateTime.tryParse('${m['joinedAt']}') : null,
      );
}

class CodePost {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String code;
  final AnUser author;
  final int price; // 积分，0=免费
  final int likes;
  final int stars;
  final int comments;
  final int views;
  final DateTime createdAt;
  final bool purchased;
  final bool deleted;

  const CodePost({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.code,
    required this.author,
    this.price = 0,
    this.likes = 0,
    this.stars = 0,
    this.comments = 0,
    this.views = 0,
    required this.createdAt,
    this.purchased = false,
    this.deleted = false,
  });
}

class LocalProject {
  final String name;
  final String path;
  final DateTime updatedAt;
  LocalProject({required this.name, required this.path, required this.updatedAt});
}
