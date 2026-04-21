import 'package:flutter/material.dart';
import 'package:athlene/components/glass_card.dart';
import 'package:athlene/theme/app_theme.dart';
import 'package:athlene/services/theme_service.dart';
import 'package:athlene/services/auth_service.dart';
import 'package:athlene/services/step_tracker_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StepTrackerService _service = StepTrackerService();
  int _goal = 10000;

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  void _loadGoal() async {
    final goal = await _service.getGoal();
    if (mounted) setState(() => _goal = goal);
  }

  void _updateGoal() async {
    int? newGoal = await showDialog<int>(
      context: context,
      builder: (context) {
        int tempGoal = _goal;
        return AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          title: const Text("Set Step Goal", style: TextStyle(color: Colors.white)),
          content: TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: "Enter steps", hintStyle: TextStyle(color: Colors.white24)),
            onChanged: (v) => tempGoal = int.tryParse(v) ?? tempGoal,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
            TextButton(onPressed: () => Navigator.pop(context, tempGoal), child: const Text("SAVE")),
          ],
        );
      },
    );

    if (newGoal != null) {
      await _service.setGoal(newGoal);
      setState(() => _goal = newGoal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    bool isDark = themeService.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 20),
            _animateWidget(Text("SETTINGS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppTheme.darkCard, letterSpacing: 4)), delay: 0),
            const SizedBox(height: 40),
            _animateWidget(_buildProfileSection(isDark), delay: 200),
            const SizedBox(height: 48),
            _animateWidget(Text("APPEARANCE", style: TextStyle(color: isDark ? AppTheme.neonCyan : Colors.black26, letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.w900)), delay: 400),
            const SizedBox(height: 16),
            _animateWidget(_buildThemeToggle(isDark, themeService), delay: 600),
            const SizedBox(height: 40),
            _animateWidget(Text("OBJECTIVES", style: TextStyle(color: isDark ? AppTheme.neonCyan : Colors.black26, letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.w900)), delay: 700),
            const SizedBox(height: 16),
            _animateWidget(_buildSettingTile(isDark, LucideIcons.target, "Step Goal", "$_goal", onTap: _updateGoal), delay: 800),
            _animateWidget(_buildSettingTile(isDark, LucideIcons.flame, "Energy", "500 kcal"), delay: 900),
            const SizedBox(height: 48),
            _animateWidget(
              Center(
                child: TextButton(
                  onPressed: () => context.read<AuthService>().logout(),
                  child: Text("SIGN OUT", style: TextStyle(color: isDark ? Colors.white30 : Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ),
              ),
              delay: 1000,
            ),
          ],
        ),
      ),
    );
  }

  Widget _animateWidget(Widget child, {int delay = 0}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutExpo,
      tween: Tween(begin: 0.0, end: 1.0),
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(40 * (1 - value), 0),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(bool isDark) {
    final userName = Provider.of<AuthService>(context).userName;
    return GlassCard(
      height: 120,
      opacity: isDark ? 0.05 : 0.6,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: isDark ? Colors.white : Colors.black12, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: isDark ? Colors.black : Colors.white,
              child: Icon(LucideIcons.user, color: isDark ? Colors.white : AppTheme.darkCard, size: 32),
            ),
          ),
          const SizedBox(width: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppTheme.darkCard, letterSpacing: 1)),
              Text("Member since 2026", style: TextStyle(color: isDark ? AppTheme.neonCyan : Colors.black38, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark, ThemeService themeService) {
    return GlassCard(
      height: 80,
      opacity: isDark ? 0.05 : 0.6,
      child: Row(
        children: [
          Icon(isDark ? LucideIcons.moon : LucideIcons.sun, color: isDark ? AppTheme.neonCyan : Colors.black45, size: 24),
          const SizedBox(width: 20),
          Expanded(child: Text("PITCH BLACK MODE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: isDark ? Colors.white : AppTheme.darkCard, letterSpacing: 1))),
          Switch.adaptive(
            value: isDark,
            activeThumbColor: AppTheme.neonCyan,
            activeTrackColor: AppTheme.neonCyan.withValues(alpha: 0.5),
            onChanged: (val) => themeService.toggleTheme(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(bool isDark, IconData icon, String title, String value, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: GlassCard(
          height: 75,
          opacity: isDark ? 0.05 : 0.6,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(icon, color: isDark ? AppTheme.neonCyan.withValues(alpha: 0.5) : Colors.black26, size: 24),
              const SizedBox(width: 20),
              Expanded(child: Text(title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppTheme.darkCard, fontSize: 12, letterSpacing: 1))),
              Text(value, style: TextStyle(color: isDark ? Colors.white54 : Colors.black38, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Icon(LucideIcons.chevronRight, color: isDark ? Colors.white12 : Colors.black12, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
