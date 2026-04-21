import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const FitnessApp(),
    ),
  );
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final authService = Provider.of<AuthService>(context);
    
    return MaterialApp(
      title: 'Athlene',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      home: authService.isLoggedIn ? const MainNavigation() : const LoginScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TrackingScreen(),
    const StatsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05))),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: isDark ? AppTheme.neonCyan : AppTheme.darkCard,
          unselectedItemColor: isDark ? Colors.white24 : Colors.black26,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(LucideIcons.map), label: "Track"),
            BottomNavigationBarItem(icon: Icon(LucideIcons.barChart2), label: "Stats"),
            BottomNavigationBarItem(icon: Icon(LucideIcons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}
