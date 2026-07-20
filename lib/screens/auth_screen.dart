import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_providers.dart';
import '../widgets/glass_container.dart';
import '../widgets/background_orbs.dart';
import '../theme/app_theme_data.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _pwController = TextEditingController();
  bool _showPw = false;
  String _error = "";
  bool _success = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(themeProvider);
    final theme = allThemes.firstWhere((t) => t.id == prefs.themeId);

    return Scaffold(
      body: Stack(
        children: [
          BackgroundOrbs(theme: theme),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: GlassContainer(
                  borderRadius: 24,
                  blur: 32,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTabs(),
                        const SizedBox(height: 24),
                        if (!_isLogin) ...[
                          _buildField(_nameController, tr('auth_name'), LucideIcons.user, onSubmitted: (_) => _submit()),
                          const SizedBox(height: 12),
                        ],
                        _buildField(_emailController, tr('auth_email'), LucideIcons.mail, type: TextInputType.emailAddress, onSubmitted: (_) => _submit()),
                        const SizedBox(height: 12),
                        _buildField(_pwController, tr('auth_password'), LucideIcons.lock, isPassword: true, onSubmitted: (_) => _submit()),
                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error,
                            style: TextStyle(
                              color: _success ? Colors.greenAccent : Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                        const SizedBox(height: 16),
                        Text(
                          tr('auth_footer'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white30, fontSize: 10, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _tabItem(tr('auth_login'), _isLogin, () => setState(() { _isLogin = true; _error = ""; })),
        const SizedBox(width: 8),
        _tabItem(tr('auth_register'), !_isLogin, () => setState(() { _isLogin = false; _error = ""; })),
      ],
    );
  }

  Widget _tabItem(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: active ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? Colors.white24 : Colors.transparent),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: active ? Colors.white : Colors.white38, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, TextInputType? type, ValueChanged<String>? onSubmitted}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_showPw,
        keyboardType: type,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          border: InputBorder.none,
          suffixIcon: isPassword ? IconButton(
            icon: Icon(_showPw ? LucideIcons.eyeOff : LucideIcons.eye, size: 16, color: Colors.white24),
            onPressed: () => setState(() => _showPw = !_showPw),
          ) : null,
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: _isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(_isLogin ? tr('auth_submit_login') : tr('auth_submit_register'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _error = "";
      _success = false;
      _isLoading = true;
    });

    final email = _emailController.text.trim().toLowerCase();
    final name = _nameController.text.trim();
    final pw = _pwController.text;

    if (email.isEmpty || !email.contains("@")) {
      setState(() { _error = tr('auth_error_email'); _isLoading = false; });
      return;
    }
    if (pw.length < 6) {
      setState(() { _error = tr('auth_error_pw'); _isLoading = false; });
      return;
    }
    if (!_isLogin && name.length < 2) {
      setState(() { _error = tr('auth_error_name'); _isLoading = false; });
      return;
    }

    String? res;
    if (_isLogin) {
      res = await ref.read(authProvider.notifier).login(email, pw);
    } else {
      res = await ref.read(authProvider.notifier).register(email, name, pw);
      if (res == null) {
        setState(() { _success = true; _error = tr('auth_success_reg'); _isLoading = false; });
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context);
        return;
      }
    }

    if (res == null) {
      final email = _emailController.text.trim().toLowerCase();
      final savedLang = ref.read(persistenceServiceProvider).getLanguage(email);
      if (mounted) {
        await EasyLocalization.of(context)!.setLocale(Locale(savedLang));
      }
    }

    setState(() {
      _error = res ?? "";
      _isLoading = false;
    });
  }
}
