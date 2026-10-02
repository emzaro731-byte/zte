import 'package:ban_battery_optimization/ban_battery_optimization.dart';\nimport 'dart:ui';
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


class TroubleshootingPage extends StatefulWidget {
  const TroubleshootingPage({super.key});

  @override
  State<TroubleshootingPage> createState() => _TroubleshootingPageState();
}

class _TroubleshootingPageState extends State<TroubleshootingPage>
    with WidgetsBindingObserver {
  BatteryRestrictionSnapshot? _snapshot;
  bool _loading = true;
  String _autoStartStatus = 'Checking ZTE auto-start support…';
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    try {
      final snapshot =
          await BanBatteryOptimization.getBatteryRestrictionSnapshot();
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _loading = false;
        _autoStartStatus = snapshot.canOpenAutoStartSettings
            ? 'Available — tap to check in ZTE settings'
            : 'ZTE auto-start page unavailable; use App info as fallback';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _autoStartStatus = 'Unable to query OEM settings';
      });
    }
  }

  Future<void> _openAutoStart() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final opened = await BanBatteryOptimization.openAutoStartSettings();
      if (!mounted) return;
      setState(() {
        _autoStartStatus = opened
            ? 'ZTE settings opened — verify Auto-start / App AI-control there'
            : 'ZTE page could not be opened — opening App info instead';
      });
      if (!opened) await _openAppInfoFallback();
    } catch (_) {
      await _openAppInfoFallback();
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _openAppInfoFallback() async {
    try {
      await const MethodChannel('zte_launcher/apps')
          .invokeMethod('openAppDetails');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final manufacturer = snapshot?.manufacturer ?? 'unknown';
    final autoStartAvailable = snapshot?.canOpenAutoStartSettings ?? false;
    final batteryRestricted =
        snapshot?.isBatteryOptimizationEnabled ?? true;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Troubleshooting'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        children: [
          const Text(
            'Check the status of required permissions below.\n'
            'Auto-start is OEM-controlled, so Android cannot reliably report '
            'whether ZTE has enabled it.',
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.55),
          ),
          const SizedBox(height: 26),
          const Text(
            'Core Permissions',
            style: TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _TroubleCard(
            icon: Icons.autorenew_rounded,
            title: 'Auto Start Permission',
            subtitle: _loading ? 'Checking…' : _autoStartStatus,
            ok: autoStartAvailable,
            action: _openAutoStart,
            busy: _opening,
          ),
          const SizedBox(height: 12),
          _TroubleCard(
            icon: Icons.battery_alert_rounded,
            title: 'Battery Optimization',
            subtitle: batteryRestricted
                ? 'Restricted — background execution may be limited'
                : 'Optimized (background run allowed)',
            ok: !batteryRestricted,
            action: () async {
              await BanBatteryOptimization.openBatteryOptimizationSettings();
            },
          ),
          const SizedBox(height: 12),
          _TroubleCard(
            icon: Icons.phone_android_rounded,
            title: 'Device',
            subtitle: 'Manufacturer: ${manufacturer}'
                '${snapshot?.androidSdkInt == null ? '' : ' • Android SDK ${snapshot!.androidSdkInt}'}',
            ok: manufacturer.toLowerCase().contains('zte') ||
                manufacturer.toLowerCase().contains('nubia'),
          ),
          const SizedBox(height: 20),
          const Text(
            'After changing ZTE Auto-start / App AI-control, return here. '
            'The screen refreshes automatically.',
            style: TextStyle(color: Colors.white54, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _TroubleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool ok;
  final VoidCallback? action;
  final bool busy;

  const _TroubleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ok,
    this.action,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff151515),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: ok ? Colors.greenAccent : Colors.white12,
            width: ok ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: const TextStyle(
                    color: Colors.white60, fontSize: 14, height: 1.3)),
                ],
              ),
            ),
            if (busy)
              const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (action != null)
              Icon(Icons.open_in_new_rounded,
                  color: ok ? Colors.greenAccent : Colors.white70)
            else
              Icon(ok ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: ok ? Colors.greenAccent : Colors.orangeAccent),
          ],
        ),
      ),
    );
  }
}
\nclass _DockButton extends StatelessWidget {
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
