import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ZteLauncherApp());
}

class ZteLauncherApp extends StatelessWidget {
  const ZteLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZTE Liquid Glass',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'sans',
      ),
      home: const LauncherHome(),
    );
  }
}

class LauncherHome extends StatefulWidget {
  const LauncherHome({super.key});

  @override
  State<LauncherHome> createState() => _LauncherHomeState();
}

class _LauncherHomeState extends State<LauncherHome> {
  static const channel = MethodChannel('zte_launcher/apps');
  final search = TextEditingController();
  List<Map<String, dynamic>> apps = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    try {
      final result = await channel.invokeMethod<List<dynamic>>('listApps');
      apps = (result ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      apps = [
        {'label': 'Phone', 'package': 'phone'},
        {'label': 'Messages', 'package': 'messages'},
        {'label': 'Camera', 'package': 'camera'},
        {'label': 'Settings', 'package': 'settings'},
        {'label': 'Gallery', 'package': 'gallery'},
        {'label': 'Browser', 'package': 'browser'},
        {'label': 'Files', 'package': 'files'},
        {'label': 'Music', 'package': 'music'},
      ];
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _openApp(String package) async {
    try {
      await channel.invokeMethod('launchApp', {'package': package});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final query = search.text.trim().toLowerCase();
    final filtered = apps.where((a) {
      return (a['label'] ?? '').toString().toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _Background(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _Glass(
                  radius: 28,
                  child: TextField(
                    controller: search,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search apps',
                      prefixIcon: Icon(Icons.search_rounded),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 150),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 22,
                            crossAxisSpacing: 12,
                            childAspectRatio: .78,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _AppTile(
                            app: filtered[i],
                            onTap: () => _openApp(filtered[i]['package'].toString()),
                          ),
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 20,
            child: SafeArea(
              child: _Glass(
                radius: 34,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _DockButton(icon: Icons.phone_rounded, onTap: () => _openApp('com.android.dialer')),
                      _DockButton(icon: Icons.message_rounded, onTap: () => _openApp('com.android.mms')),
                      _DockButton(icon: Icons.camera_alt_rounded, onTap: () => _openApp('com.android.camera2')),
                      _DockButton(icon: Icons.settings_rounded, onTap: () => _openApp('com.android.settings')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff17243d),
            Color(0xff33204f),
            Color(0xff07141d),
          ],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(color: Colors.black.withValues(alpha: .08)),
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  const _Glass({required this.child, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: .20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .22),
                blurRadius: 28,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  final Map<String, dynamic> app;
  final VoidCallback onTap;
  const _AppTile({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = app['icon'];
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: .16)),
            ),
            child: icon is Uint8List
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Image.memory(icon, fit: BoxFit.cover),
                  )
                : const Icon(Icons.apps_rounded, size: 30),
          ),
          const SizedBox(height: 7),
          Text(
            (app['label'] ?? 'App').toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _DockButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Icon(icon, size: 27),
      ),
    );
  }
}
