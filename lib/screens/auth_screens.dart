import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_state.dart';
import '../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  final AppState state;
  const LoginScreen({super.key, required this.state});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final user = TextEditingController();
  final pass = TextEditingController();
  bool hide = true;
  bool loading = false;
  late final AnimationController _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))..forward();

  @override
  void dispose() {
    _enter.dispose();
    user.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => loading = true);
    final err = await widget.state.login(user.text.trim(), pass.text);
    if (!mounted) return;
    setState(() => loading = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), actions: [IconButton(icon: const Icon(Icons.work_outline), onPressed: () {})]),
      body: FadeTransition(
        opacity: _enter,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 16),
            const Text('登录账号', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('登录后即可解锁更多功能', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 28),
            TextField(controller: user, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline), hintText: '用户名')),
            const SizedBox(height: 12),
            TextField(
              controller: pass,
              obscureText: hide,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                hintText: '密码',
                suffixIcon: IconButton(icon: Icon(hide ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => hide = !hide)),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: loading ? const CircularProgressIndicator() : AnxButton(label: '登录', onPressed: _login),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () {}, child: const Text('找回密码')),
                const Text(' | '),
                TextButton(
                  onPressed: () async {
                    final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => RegisterScreen(state: widget.state)));
                    if (ok == true && mounted) Navigator.pop(context, true);
                  },
                  child: const Text('注册账号'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  final AppState state;
  const RegisterScreen({super.key, required this.state});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final user = TextEditingController();
  final pass = TextEditingController();
  final email = TextEditingController();
  bool hide = true;

  Future<void> _register() async {
    final codeCtrl = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('邮箱验证'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请输入发送到邮箱的 6 位验证码'),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(hintText: '请输入 6 位验证码', counterText: ''),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, codeCtrl.text.trim()), child: const Text('确认')),
        ],
      ),
    );
    if (code == null) return;
    final err = await widget.state.register(username: user.text.trim(), password: pass.text, email: email.text.trim(), code: code);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(radius: 40, child: Icon(Icons.person_add_alt_1, size: 40)),
          const SizedBox(height: 16),
          const Text('注册账号', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('注册后登录即可解锁更多功能', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 28),
          TextField(controller: user, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline), hintText: '用户名')),
          const SizedBox(height: 12),
          TextField(
            controller: pass,
            obscureText: hide,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: '密码',
              suffixIcon: IconButton(icon: Icon(hide ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => hide = !hide)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined), hintText: '邮箱')),
          const SizedBox(height: 20),
          Align(alignment: Alignment.centerRight, child: AnxButton(label: '注册', onPressed: _register)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () {}, child: const Text('找回密码')),
              const Text(' | '),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('登录账号')),
            ],
          ),
        ],
      ),
    );
  }
}
