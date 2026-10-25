import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/project_tab.dart';
import 'screens/code_screens.dart';
import 'screens/profile_tab.dart';
import 'screens/ban_sheet.dart';
import 'widgets/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  final state = AppState();
  await state.init();
  runApp(AnLuaApp(state: state));
}

class AnLuaApp extends StatelessWidget {
  final AppState state;
  const AnLuaApp({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (_, __) => MaterialApp(
        title: 'AnLuaX',
        debugShowCheckedModeBanner: false,
        theme: buildAnLuaTheme(dark: false),
        darkTheme: buildAnLuaTheme(dark: true),
        themeMode: ThemeMode.system,
        home: HomeShell(state: state),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  final AppState state;
  const HomeShell({super.key, required this.state});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with TickerProviderStateMixin {
  int index = 0;
  late final AnimationController _fab = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
  bool _banShown = false;

  @override
  void initState() {
    super.initState();
    _fab.value = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBan());
    widget.state.addListener(_checkBan);
  }

  @override
  void dispose() {
    widget.state.removeListener(_checkBan);
    _fab.dispose();
    super.dispose();
  }

  void _checkBan() {
    if (!mounted) return;
    if (widget.state.isBanned && !_banShown) {
      _banShown = true;
      showBanSheet(context, widget.state.user!);
    }
    if (!widget.state.isBanned) _banShown = false;
  }

  void _menu() async {
    final r = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.file_open_outlined), title: const Text('导入源码'), onTap: () => Navigator.pop(ctx, 'import')),
            ListTile(leading: const Icon(Icons.sort), title: const Text('项目排序'), onTap: () => Navigator.pop(ctx, 'sort')),
            ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('软件设置'), onTap: () => Navigator.pop(ctx, 'settings')),
          ],
        ),
      ),
    );
    if (r == 'import' && mounted) {
      await widget.state.importSource('imported_${DateTime.now().millisecondsSinceEpoch}', '-- imported\nprint("hi")\n');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已导入到 AnLuaX/')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['项目', '代码', '我的'];
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, inner) => [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('AnLuaX', style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: _menu),
            ],
          ),
        ],
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey(index),
            child: switch (index) {
              0 => ProjectTab(state: widget.state),
              1 => CodeTab(state: widget.state),
              _ => ProfileTab(state: widget.state),
            },
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() => index = i);
          _fab.forward(from: 0.8);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: '项目'),
          NavigationDestination(icon: Icon(Icons.code_outlined), selectedIcon: Icon(Icons.code), label: '代码'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
