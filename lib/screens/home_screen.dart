import 'package:flutter/material.dart';
import 'package:athlene/components/glass_card.dart';
import 'package:athlene/theme/app_theme.dart';
import 'package:athlene/services/step_tracker_service.dart';
import 'package:athlene/services/auth_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final StepTrackerService _service = StepTrackerService();
  int _steps = 0;
  List<int> _history = [0, 0, 0, 0, 0, 0, 0];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    _service.initPlatformState();
    _service.stepsStream.listen((steps) {
      if (mounted) {
        setState(() {
          _steps = steps;
          _history[6] = steps;
        });
      }
    });

    final history = await _service.getWeeklyHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _steps = history.last;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = Provider.of<AuthService>(context).userName;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
        body: const Center(child: CircularProgressIndicator())
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _animateWidget(_buildHeader(isDark, userName), delay: 0),
              const SizedBox(height: 30),
              _animateWidget(_buildHorizontalCards(isDark), delay: 200),
              const SizedBox(height: 30),
              _animateWidget(_buildMainStats(isDark), delay: 400),
              const SizedBox(height: 20),
              _animateWidget(_buildBarChart(isDark), delay: 600),
              const SizedBox(height: 40),
              _animateWidget(_buildActionButton(isDark), delay: 800),
              const SizedBox(height: 40),
            ],
          ),
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
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppTheme.darkCard, letterSpacing: -1)),
            Text("HEALTH STATUS", style: TextStyle(color: isDark ? AppTheme.neonCyan : Colors.black38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white : Colors.black12,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: isDark ? Colors.black : Colors.white,
            child: Icon(LucideIcons.user, color: isDark ? Colors.white : Colors.black, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalCards(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildInfoCard(isDark, AppTheme.pastelPurple, LucideIcons.footprints, "Walk", "$_steps", "steps"),
          const SizedBox(width: 16),
          _buildInfoCard(isDark, AppTheme.pastelGreen, LucideIcons.trees, "Eco", (_steps / 1200).toStringAsFixed(1), "kg CO2"),
          const SizedBox(width: 16),
          _buildInfoCard(isDark, AppTheme.pastelPeach, LucideIcons.flame, "Energy", (_steps * 0.04).toStringAsFixed(0), "kcal"),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, Color accent, IconData icon, String title, String value, String unit) {
    return GlassCard(
      width: 150,
      height: 180,
      opacity: isDark ? 0.07 : 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isDark ? AppTheme.neonCyan : accent, size: 28),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: isDark ? Colors.white : AppTheme.darkCard)),
          Text(unit, style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildMainStats(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text("$_steps", style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppTheme.darkCard, letterSpacing: -2)),
            const SizedBox(width: 12),
            Text("STEPS TODAY", style: TextStyle(color: isDark ? AppTheme.neonCyan : AppTheme.accentBlue, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
        Icon(LucideIcons.activity, color: isDark ? AppTheme.neonCyan : Colors.black26),
      ],
    );
  }

  Widget _buildBarChart(bool isDark) {
    int maxSteps = _history.reduce((a, b) => a > b ? a : b);
    if (maxSteps < 1000) maxSteps = 1000;
    
    final List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return GlassCard(
      height: 220,
      opacity: isDark ? 0.05 : 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          double heightFactor = _history[index] / maxSteps;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 1000 + (index * 100)),
                curve: Curves.easeOutBack,
                width: 18,
                height: 120 * heightFactor.clamp(0.1, 1.0),
                decoration: BoxDecoration(
                  color: index == 6 ? (isDark ? AppTheme.neonCyan : AppTheme.accentBlue) : (isDark ? Colors.white10 : Colors.black12),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Text(days[index], style: TextStyle(fontSize: 10, color: isDark ? Colors.white24 : Colors.black26, fontWeight: FontWeight.bold)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActionButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? Colors.white : AppTheme.darkCard,
        boxShadow: [
          if (isDark) BoxShadow(color: AppTheme.neonCyan.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 0)),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("SYNC DATA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.black : Colors.white, letterSpacing: 2)),
            const SizedBox(width: 12),
            Icon(LucideIcons.refreshCcw, size: 20, color: isDark ? Colors.black : Colors.white),
          ],
        ),
      ),
    );
  }
}
