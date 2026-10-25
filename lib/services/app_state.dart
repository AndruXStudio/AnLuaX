import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  AnUser? user;
  bool get loggedIn => user != null;
  bool get isBanned => user?.banned == true;

  List<CodePost> posts = [];
  List<LocalProject> projects = [];
  final Set<String> purchasedIds = {};

  static const _kToken = 'anluax_token';
  static const _kUser = 'anluax_user';
  static const _kPurchased = 'anluax_purchased';

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    final u = p.getString(_kUser);
    if (u != null) {
      try {
        user = AnUser.fromJson(jsonDecode(u) as Map);
      } catch (_) {}
    }
    purchasedIds.addAll(p.getStringList(_kPurchased) ?? []);
    await _loadProjects();
    _seedPosts();
    notifyListeners();
  }

  Future<String> rootDir() async {
    final d = await getApplicationDocumentsDirectory();
    final root = Directory('${d.path}/AnLuaX');
    if (!await root.exists()) await root.create(recursive: true);
    return root.path;
  }

  Future<void> _loadProjects() async {
    final root = await rootDir();
    final dir = Directory(root);
    projects = [];
    if (await dir.exists()) {
      await for (final e in dir.list()) {
        if (e is Directory) {
          final st = await e.stat();
          projects.add(LocalProject(
            name: e.path.split(Platform.pathSeparator).last,
            path: e.path,
            updatedAt: st.modified,
          ));
        }
      }
    }
    projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<LocalProject?> createProject(String name) async {
    final safe = name.trim().replaceAll(RegExp(r'[^\w\u4e00-\u9fff\-]+'), '_');
    if (safe.isEmpty) return null;
    final root = await rootDir();
    final path = '$root/$safe';
    final dir = Directory(path);
    if (!await dir.exists()) await dir.create(recursive: true);
    final main = File('$path/main.lua');
    if (!await main.exists()) {
      await main.writeAsString('-- AnLuaX project: $safe\nprint("Hello AnLuaX")\n');
    }
    await _loadProjects();
    notifyListeners();
    return projects.cast<LocalProject?>().firstWhere((e) => e?.name == safe, orElse: () => null);
  }

  Future<void> importSource(String name, String code) async {
    final proj = await createProject(name);
    if (proj == null) return;
    await File('${proj.path}/main.lua').writeAsString(code);
    await _loadProjects();
    notifyListeners();
  }

  void _seedPosts() {
    final a1 = AnUser(id: '1', username: 'pipeking', displayName: '撸管王', role: UserRole.user, points: 120);
    final a2 = AnUser(id: '2', username: 'SyntaxError', displayName: 'SyntaxError', role: UserRole.contributor, points: 14292, joinedAt: DateTime(2025, 9, 2));
    final a3 = AnUser(id: '3', username: 'yin', displayName: 'yin', role: UserRole.user);
    posts = [
      CodePost(
        id: 'p1',
        title: '极品MD3弹窗+远程验证',
        summary: '- 自己对接到自己的项目里\n- 提示用大佬开源的LuaAppX同款提示自己对接',
        content: '极品 Material3 弹窗与远程验证示例，可导入到 AnLuaX 项目。',
        code: 'require "import"\nimport "android.app.*"\n-- MD3 dialog sample\nprint("MD3 dialog")\n',
        author: a1,
        price: 30,
        comments: 4,
        views: 277,
        createdAt: DateTime(2026, 10, 22, 23, 54, 5),
        purchased: purchasedIds.contains('p1'),
      ),
      CodePost(
        id: 'p2',
        title: 'SelectableCards',
        summary: 'require "import"\nimport "android.app.*"\nimport "android.os.*"...',
        content: '可选卡片组件示例。',
        code: '''require "import"
import "android.app.*"
import "android.os.*"
import "android.view.*"
import "android.widget.*"

local function dp(v)
  return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, v, activity.getResources().getDisplayMetrics())
end

print("SelectableCards")
''',
        author: a2,
        price: 0,
        views: 252,
        createdAt: DateTime(2026, 10, 22, 22, 36, 20),
        purchased: true,
      ),
      CodePost(
        id: 'p3',
        title: 'ai（可生图）',
        summary: '- 不要发布无意义垃圾/病毒/不文明用语/违反当地法律内容\n- 搬运帖注明来源且不可设置为付费...',
        content: '社区规范示例帖。',
        code: '-- rules\nprint("community rules")\n',
        author: a3,
        price: 0,
        likes: 1,
        stars: 2,
        comments: 1,
        views: 283,
        createdAt: DateTime(2026, 10, 22, 18, 21, 21),
        purchased: true,
      ),
    ];
  }

  Future<String?> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) return '请输入用户名和密码';
    // demo: special banned account
    final banned = username.toLowerCase() == 'banned';
    user = AnUser(
      id: 'u_$username',
      username: username,
      displayName: banned ? '账户已被封禁' : username,
      role: username.toLowerCase() == 'admin' ? UserRole.admin : UserRole.user,
      points: 500,
      banned: banned,
      banReason: banned ? '发布违规内容 / 恶意刷分' : null,
      banAt: banned ? '2026-10-20 14:32:08' : null,
      unbanAt: banned ? '2026-11-20 14:32:08' : null,
      violation: banned ? '在源码区发布含恶意代码的示例' : null,
      reviewAt: banned ? '2026-10-20 14:30:01' : null,
      joinedAt: DateTime(2025, 9, 2),
    );
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, 'demo');
    await p.setString(_kUser, jsonEncode({
      'id': user!.id,
      'username': user!.username,
      'displayName': user!.displayName,
      'role': user!.role.name,
      'points': user!.points,
      'banned': user!.banned,
      'banReason': user!.banReason,
      'banAt': user!.banAt,
      'unbanAt': user!.unbanAt,
      'violation': user!.violation,
      'reviewAt': user!.reviewAt,
      'joinedAt': user!.joinedAt?.toIso8601String(),
    }));
    notifyListeners();
    return null;
  }

  Future<String?> register({required String username, required String password, required String email, required String code}) async {
    if (username.isEmpty || password.isEmpty || email.isEmpty) return '请填写完整信息';
    if (!RegExp(r'^\d{6}$').hasMatch(code)) return '请输入 6 位验证码';
    if (!email.contains('@')) return '邮箱格式不正确';
    return login(username, password);
  }

  Future<void> logout() async {
    user = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
    await p.remove(_kUser);
    notifyListeners();
  }

  Future<String?> purchase(CodePost post) async {
    if (!loggedIn) return '请先登录';
    if (isBanned) return '账户已被封禁';
    if (post.price <= 0 || purchasedIds.contains(post.id)) return null;
    if ((user?.points ?? 0) < post.price) return '积分不足';
    user = AnUser(
      id: user!.id,
      username: user!.username,
      displayName: user!.displayName,
      avatarUrl: user!.avatarUrl,
      role: user!.role,
      points: user!.points - post.price,
      banned: user!.banned,
      joinedAt: user!.joinedAt,
    );
    purchasedIds.add(post.id);
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kPurchased, purchasedIds.toList());
    await p.setString(_kUser, jsonEncode({
      'id': user!.id,
      'username': user!.username,
      'displayName': user!.displayName,
      'role': user!.role.name,
      'points': user!.points,
      'banned': user!.banned,
      'joinedAt': user!.joinedAt?.toIso8601String(),
    }));
    final i = posts.indexWhere((e) => e.id == post.id);
    if (i >= 0) {
      final o = posts[i];
      posts[i] = CodePost(
        id: o.id,
        title: o.title,
        summary: o.summary,
        content: o.content,
        code: o.code,
        author: o.author,
        price: o.price,
        likes: o.likes,
        stars: o.stars,
        comments: o.comments,
        views: o.views,
        createdAt: o.createdAt,
        purchased: true,
      );
    }
    notifyListeners();
    return null;
  }
}
