import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../widgets/widgets.dart';
import 'auth_screens.dart';
import 'user_page.dart';

class CodeTab extends StatelessWidget {
  final AppState state;
  const CodeTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (!state.loggedIn) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CloudSlash(size: 88),
            const SizedBox(height: 16),
            Text('登录后体验完整功能', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            AnxButton(
              label: '去登录',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(state: state))),
            ),
          ],
        ),
      );
    }
    if (state.isBanned) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CloudSlash(size: 88),
            const SizedBox(height: 16),
            Text('账户似乎出现了问题', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      itemCount: state.posts.length,
      itemBuilder: (ctx, i) {
        final p = state.posts[i];
        return FadeSlideIn(
          index: i,
          child: _PostCard(
            post: p,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CodeDetailScreen(state: state, post: p))),
          ),
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  final CodePost post;
  final VoidCallback onTap;
  const _PostCard({required this.post, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd HH:mm:ss');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 18, backgroundImage: post.author.avatarUrl != null ? NetworkImage(post.author.avatarUrl!) : null, child: post.author.avatarUrl == null ? Text(post.author.displayName.characters.first) : null),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(post.author.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            RoleBadge(role: post.author.role, banned: post.author.banned),
                            if (post.purchased || post.price == 0)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                                child: Text(post.price == 0 ? '免费' : '已购买', style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w700)),
                              )
                            else
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                                child: Text('${post.price} 积分', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                              ),
                          ]),
                          Text(df.format(post.createdAt), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(post.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 6),
                Text(post.summary, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.35)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _m(Icons.thumb_up_alt_outlined, post.likes),
                    _m(Icons.star_border, post.stars),
                    _m(Icons.chat_bubble_outline, post.comments),
                    _m(Icons.visibility_outlined, post.views),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _m(IconData i, int n) => Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Row(children: [Icon(i, size: 16, color: AnxMuted), const SizedBox(width: 4), Text('$n', style: const TextStyle(fontSize: 12, color: AnxMuted))]),
      );
}

const AnxMuted = Color(0xFF9E9E9E);

class CodeDetailScreen extends StatefulWidget {
  final AppState state;
  final CodePost post;
  const CodeDetailScreen({super.key, required this.state, required this.post});
  @override
  State<CodeDetailScreen> createState() => _CodeDetailScreenState();
}

class _CodeDetailScreenState extends State<CodeDetailScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  late CodePost post;

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _buy() async {
    final err = await widget.state.purchase(post);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    setState(() {
      post = widget.state.posts.firstWhere((e) => e.id == post.id, orElse: () => post);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('购买成功，积分已转入作者账户（演示）')));
  }

  @override
  Widget build(BuildContext context) {
    final canView = post.price == 0 || post.purchased || widget.state.purchasedIds.contains(post.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        actions: [
          IconButton(icon: const Icon(Icons.thumb_up_alt_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.star_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.play_arrow), onPressed: canView ? () {} : null),
        ],
        bottom: TabBar(controller: _tab, tabs: const [Tab(text: '代码'), Tab(text: '评论')]),
      ),
      body: Column(
        children: [
          ListTile(
            leading: CircleAvatar(child: Text(post.author.displayName.characters.first)),
            title: Row(children: [
              Text(post.author.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
              RoleBadge(role: post.author.role, banned: post.author.banned),
            ]),
            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(post.createdAt)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserPage(state: widget.state, user: post.author))),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                canView
                    ? InteractiveViewer(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: SelectableText(post.code, style: const TextStyle(fontFamily: 'monospace', height: 1.45)),
                        ),
                      )
                    : Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.lock_outline, size: 48),
                          const SizedBox(height: 12),
                          Text('需要 ${post.price} 积分购买源码'),
                          const SizedBox(height: 12),
                          AnxButton(label: '购买并导入', icon: Icons.shopping_cart_outlined, onPressed: _buy),
                        ]),
                      ),
                const Center(child: Text('暂无评论')),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: canView
          ? FloatingActionButton.extended(
              onPressed: () async {
                await widget.state.importSource(post.title, post.code);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已导入到 AnLuaX 项目目录')));
              },
              icon: const Icon(Icons.download),
              label: const Text('导入项目'),
            )
          : null,
    );
  }
}
