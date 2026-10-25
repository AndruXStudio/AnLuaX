import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Material 按钮：按压缩放 + 形状微动画
class AnxButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final IconData? icon;
  const AnxButton({super.key, required this.label, this.onPressed, this.filled = true, this.icon});
  @override
  State<AnxButton> createState() => _AnxButtonState();
}

class _AnxButtonState extends State<AnxButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 0.94, upperBound: 1);
  @override
  void initState() {
    super.initState();
    _c.value = 1;
  }
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final child = widget.icon == null
        ? Text(widget.label)
        : Row(mainAxisSize: MainAxisSize.min, children: [Icon(widget.icon, size: 18), const SizedBox(width: 8), Text(widget.label)]);
    return ScaleTransition(
      scale: _c,
      child: Listener(
        onPointerDown: (_) => _c.reverse(),
        onPointerUp: (_) => _c.forward(),
        onPointerCancel: (_) => _c.forward(),
        child: widget.filled
            ? FilledButton(onPressed: widget.onPressed, child: child)
            : OutlinedButton(onPressed: widget.onPressed, child: child),
      ),
    );
  }
}

class RoleBadge extends StatelessWidget {
  final UserRole role;
  final bool banned;
  const RoleBadge({super.key, required this.role, this.banned = false});
  @override
  Widget build(BuildContext context) {
    if (banned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
        child: const Text('已封禁', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w700)),
      );
    }
    final (label, color) = switch (role) {
      UserRole.creator => ('创建者', const Color(0xFFFFB300)),
      UserRole.admin => ('管理员', const Color(0xFF42A5F5)),
      UserRole.contributor => ('贡献者', const Color(0xFF66BB6A)),
      UserRole.user => ('', AnxColors.muted),
    };
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class CloudSlash extends StatelessWidget {
  final double size;
  const CloudSlash({super.key, this.size = 72});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.cloud_outlined, size: size * 0.85, color: AnxColors.muted.withOpacity(0.7)),
          Transform.rotate(
            angle: -0.6,
            child: Container(width: size * 0.9, height: 3, color: AnxColors.muted.withOpacity(0.85)),
          ),
        ],
      ),
    );
  }
}

class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int index;
  const FadeSlideIn({super.key, required this.child, this.index = 0});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + index * 40),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 16), child: c),
      ),
      child: child,
    );
  }
}
