import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../widgets/widgets.dart';
import 'code_screens.dart';

class UserPage extends StatelessWidget {
  final AppState state;
  final AnUser user;
  const UserPage({super.key, required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    final banned = user.banned;
    final name = banned ? '账户已被封禁' : user.displayName;
    final posts = banned ? <CodePost>[] : state.posts.where((p) => p.author.id == user.id || p.author.username == user.username).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('用户主页')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: banned ? Colors.grey : null,
                child: banned ? const Icon(Icons.person, color: Colors.white54) : Text(name.characters.first),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: banned ? Colors.grey : null)),
                      RoleBadge(role: user.role, banned: banned),
                    ]),
                    const SizedBox(height: 6),
                    Wrap(spacing: 8, children: [
                      if (!banned) Chip(label: Text('${user.points} X币'), visualDensity: VisualDensity.compact),
                      if (user.joinedAt != null) Chip(avatar: const Icon(Icons.schedule, size: 16), label: Text(DateFormat('yyyy-MM-dd').format(user.joinedAt!)), visualDensity: VisualDensity.compact),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (posts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(child: Text(banned ? '该用户发布的代码已删除' : '暂无发布', style: const TextStyle(color: Colors.grey))),
            )
          else
            ...posts.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
                    title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(p.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CodeDetailScreen(state: state, post: p))),
                  ),
                )),
        ],
      ),
    );
  }
}
