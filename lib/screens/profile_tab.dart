import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../widgets/widgets.dart';
import 'auth_screens.dart';
import 'user_page.dart';

class ProfileTab extends StatelessWidget {
  final AppState state;
  const ProfileTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final u = state.user;
    if (u == null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          const Text('AnLuaX', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300)),
          const SizedBox(height: 24),
          ListTile(
            leading: const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 28)),
            title: const Text('未登录', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            subtitle: const Text('点我即可前往登录'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(state: state))),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: u.banned ? Colors.grey : null,
            child: u.banned ? const Icon(Icons.person, color: Colors.white54) : Text(u.displayName.characters.first),
          ),
          title: Row(children: [
            Text(u.banned ? '账户已被封禁' : u.displayName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            RoleBadge(role: u.role, banned: u.banned),
          ]),
          subtitle: Text(u.banned ? '该账户已被限制使用' : '${u.points} 积分 · @${u.username}'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserPage(state: state, user: u))),
        ),
        const Divider(),
        ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('软件设置'), onTap: () {}),
        ListTile(leading: const Icon(Icons.logout), title: const Text('退出登录'), onTap: () => state.logout()),
      ],
    );
  }
}
