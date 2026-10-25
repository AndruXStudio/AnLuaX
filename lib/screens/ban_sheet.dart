import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

Future<void> showBanSheet(BuildContext context, AnUser user) async {
  await showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) {
      final md = '''
**管理员审查时间**  
${user.reviewAt ?? user.banAt ?? '-'}

**封禁理由**  
${user.banReason ?? '-'}

**违规内容**  
${user.violation ?? '-'}

**处罚时间**  
${user.banAt ?? '-'}

**解封日期**  
${user.unbanAt ?? '-'}
''';
      return PopScope(
        canPop: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(ctx).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const CloudSlash(size: 64),
              const SizedBox(height: 12),
              const Text('账户已被封禁', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              MarkdownBody(data: md, styleSheet: MarkdownStyleSheet(p: const TextStyle(height: 1.5))),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('申诉已提交（演示）')));
                  }, child: const Text('申诉')),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('确认')),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
