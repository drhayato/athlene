import 'package:flutter/material.dart';
import 'package:athlene/components/glass_card.dart';
import 'package:athlene/theme/app_theme.dart';
import 'package:athlene/services/auth_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _handleLogin() async {
    if (_nameController.text.isEmpty) {
      setState(() => _error = "Please enter your name");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
    );

    if (!success && mounted) {
      setState(() {
        _isLoading = false;
        _error = "Invalid email or password (min. 6 chars)";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("FITNESS PRO", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? AppTheme.neonCyan : AppTheme.darkCard, letterSpacing: 8)),
              const SizedBox(height: 16),
              Text("Create\nProfile", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppTheme.darkCard, height: 1.1)),
              const SizedBox(height: 48),
              _buildInput("Display Name", _nameController, LucideIcons.user, isDark),
              const SizedBox(height: 16),
              _buildInput("Email Address", _emailController, LucideIcons.mail, isDark),
              const SizedBox(height: 16),
              _buildInput("Password", _passwordController, LucideIcons.lock, isDark, obscure: true),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
              const SizedBox(height: 48),
              _buildLoginButton(isDark),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text("FORGOT PASSWORD?", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, bool isDark, {bool obscure = false}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      opacity: isDark ? 0.05 : 0.4,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: isDark ? AppTheme.neonCyan : Colors.black26, size: 20),
          hintText: label,
          hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isDark) {
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
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading 
          ? CircularProgressIndicator(color: isDark ? Colors.black : Colors.white)
          : Text("START JOURNEY", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.black : Colors.white, letterSpacing: 2)),
      ),
    );
  }
}
