import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../widgets/widgets.dart';

class ProjectTab extends StatefulWidget {
  final AppState state;
  const ProjectTab({super.key, required this.state});
  @override
  State<ProjectTab> createState() => _ProjectTabState();
}

class _ProjectTabState extends State<ProjectTab> {
  Future<void> _create() async {
    final c = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建项目'),
        content: TextField(controller: c, decoration: const InputDecoration(hintText: '项目名称')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('创建')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await widget.state.createProject(name);
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.state.projects;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        child: const Icon(Icons.add),
      ),
      body: list.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.folder_open, size: 64, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 12),
                const Text('还没有项目'),
                const SizedBox(height: 8),
                Text('路径：AnLuaX/', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                AnxButton(label: '创建项目', icon: Icons.create_new_folder_outlined, onPressed: _create),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final p = list[i];
                return FadeSlideIn(
                  index: i,
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.folder, color: Color(0xFF1565C0)),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${p.path}\n${DateFormat('yyyy-MM-dd HH:mm').format(p.updatedAt)}'),
                      isThreeLine: true,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('打开项目 ${p.name}')));
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
