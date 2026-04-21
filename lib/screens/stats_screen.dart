import 'package:flutter/material.dart';
import 'package:athlene/theme/app_theme.dart';
import 'package:athlene/components/glass_card.dart';
import 'package:athlene/services/step_tracker_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:math';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final StepTrackerService _service = StepTrackerService();
  int _todaySteps = 0;
  int _goal = 10000;
  double _avgSteps = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }

  void _loadRealData() async {
    final history = await _service.getWeeklyHistory();
    final goal = await _service.getGoal();
    final avg = await _service.getAverageSteps();
    
    if (mounted) {
      setState(() {
        _todaySteps = history.last;
        _goal = goal;
        _avgSteps = avg;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    double progress = (_todaySteps / _goal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _animateWidget(_buildAppBar(isDark), delay: 0),
              const SizedBox(height: 40),
              _animateWidget(_buildDonutChart(context, isDark, progress), delay: 200),
              const SizedBox(height: 40),
              _animateWidget(_buildChartLegend(isDark, progress), delay: 400),
              const SizedBox(height: 40),
              _animateWidget(_buildPointsCard(isDark), delay: 600),
              const SizedBox(height: 24),
              _animateWidget(_buildAveragesCard(isDark), delay: 800),
              const SizedBox(height: 20),
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
          child: Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(LucideIcons.barChart2, color: isDark ? AppTheme.neonCyan : Colors.black, size: 28),
        Text("ANALYTICS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppTheme.darkCard, letterSpacing: 4)),
        Icon(LucideIcons.calendar, color: isDark ? AppTheme.neonCyan : Colors.black, size: 28),
      ],
    );
  }

  Widget _buildDonutChart(BuildContext context, bool isDark, double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 260,
          height: 260,
          child: CustomPaint(
            painter: DonutPainter(
              activeColor: isDark ? AppTheme.neonCyan : AppTheme.accentBlue,
              remainingColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              percentage: progress,
              isDark: isDark,
            ),
          ),
        ),
        Column(
          children: [
            Text("${(progress * 100).toInt()}%", style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppTheme.darkCard, letterSpacing: -2)),
            Text("GOAL PROGRESS", style: TextStyle(fontSize: 10, color: isDark ? AppTheme.neonCyan : Colors.black38, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
      ],
    );
  }

  Widget _buildChartLegend(bool isDark, double progress) {
    int remaining = _goal - _todaySteps;
    if (remaining < 0) remaining = 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(isDark ? AppTheme.neonCyan : AppTheme.accentBlue, "COMPLETED", isDark),
        const SizedBox(width: 40),
        _buildLegendItem(isDark ? Colors.white12 : Colors.black12, "REMAINING", isDark),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? Colors.white70 : Colors.black45, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildPointsCard(bool isDark) {
    return GlassCard(
      color: isDark ? Colors.white : Colors.white,
      opacity: isDark ? 0.05 : 0.8,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("EARNED POINTS", style: TextStyle(color: isDark ? AppTheme.neonCyan : AppTheme.darkCard, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text((_todaySteps * 0.12).toStringAsFixed(1), style: TextStyle(color: isDark ? Colors.white : AppTheme.darkCard, fontWeight: FontWeight.w900, fontSize: 32)),
                ],
              ),
              Icon(LucideIcons.trophy, color: isDark ? AppTheme.neonCyan : Colors.amber, size: 32),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoDetail("SAVED CO2", "${(_todaySteps * 0.05).toStringAsFixed(1)} lb", isDark),
              _buildInfoDetail("TOTAL STEPS", "$_todaySteps", isDark),
              _buildInfoDetail("DURATION", "${(_todaySteps / 100).floor()}m", isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAveragesCard(bool isDark) {
    return GlassCard(
      opacity: 0.05,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoDetail("WEEKLY AVG", _avgSteps.toInt().toString(), isDark),
          _buildInfoDetail("DAILY GOAL", _goal.toString(), isDark),
          _buildInfoDetail("STREAK", "4 DAYS", isDark),
        ],
      ),
    );
  }

  Widget _buildInfoDetail(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : AppTheme.darkCard)),
      ],
    );
  }
}

class DonutPainter extends CustomPainter {
  final Color activeColor;
  final Color remainingColor;
  final double percentage;
  final bool isDark;

  DonutPainter({required this.activeColor, required this.remainingColor, required this.percentage, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 25;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - strokeWidth / 2;

    Paint bgPaint = Paint()..color = remainingColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    Paint activePaint = Paint()..color = activeColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round;

    double activeAngle = 2 * pi * percentage;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, activeAngle, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
