import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_providers.dart';
import '../widgets/glass_container.dart';
import '../widgets/background_orbs.dart';
import '../theme/app_theme_data.dart';
import '../theme/design_tokens.dart';

/// Auth screen restyled 1:1 like the React Native `AuthPanel`: glass card
/// (blur 20, radius 20, 22x24 padding), segmented login/register tabs,
/// flat glass inputs, glowing submit button and muted footer hint.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  bool _showPw = false;
  bool _isLoading = false;
  String _error = '';
  bool _success = false;

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _pwController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = '';
      _success = false;
      _isLoading = true;
    });

    final email = _emailController.text.trim().toLowerCase();
    final name = _nameController.text.trim();
    final pw = _pwController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _error = tr('auth_error_email');
        _isLoading = false;
      });
      return;
    }
    if (pw.length < 6) {
      setState(() {
        _error = tr('auth_error_pw');
        _isLoading = false;
      });
      return;
    }
    if (!_isLogin && name.length < 2) {
      setState(() {
        _error = tr('auth_error_name');
        _isLoading = false;
      });
      return;
    }

    String? res;
    if (_isLogin) {
      res = await ref.read(authProvider.notifier).login(email, pw);
    } else {
      res = await ref.read(authProvider.notifier).register(email, name, pw);
      if (res == null) {
        setState(() {
          _success = true;
          _error = tr('auth_success_reg');
          _isLoading = false;
        });
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted && Navigator.of(context).canPop()) Navigator.pop(context);
        return;
      }
    }

    if (res == null && mounted) {
      final savedLang = ref.read(persistenceServiceProvider).getLanguageRaw(email);
      if (savedLang != null) {
        await EasyLocalization.of(context)!.setLocale(Locale(savedLang));
      }
      if (Navigator.of(context).canPop()) Navigator.pop(context);
    }

    if (!mounted) return;
    setState(() {
      _error = res == null ? '' : tr(res);
      _isLoading = false;
    });
  }

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
                  borderRadius: 20,
                  blur: 20,
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _TabBtn(
                              label: tr('auth_login'),
                              active: _isLogin,
                              onTap: () => setState(() {
                                _isLogin = true;
                                _error = '';
                              }),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _TabBtn(
                              label: tr('auth_register'),
                              active: !_isLogin,
                              onTap: () => setState(() {
                                _isLogin = false;
                                _error = '';
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      if (!_isLogin) ...[
                        _AuthField(
                          controller: _nameController,
                          hint: tr('auth_name'),
                          onSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _AuthField(
                        controller: _emailController,
                        hint: tr('auth_email'),
                        keyboardType: TextInputType.emailAddress,
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 12),
                      _AuthField(
                        controller: _pwController,
                        hint: tr('auth_password'),
                        obscure: !_showPw,
                        onSubmitted: (_) => _submit(),
                        suffix: IconButton(
                          onPressed: () => setState(() => _showPw = !_showPw),
                          icon: Icon(
                            _showPw ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.30),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      if (_error.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _success
                                ? const Color(0xE652DC78)
                                : const Color(0xE6FF6464),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _SubmitButton(
                        label: _isLogin
                            ? tr('auth_submit_login')
                            : tr('auth_submit_register'),
                        loading: _isLoading,
                        onTap: _submit,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          tr('auth_footer'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.6,
                            color: G.textMuted,
                          ),
                        ),
                      ),
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

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? G.bgHov : G.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? G.border : Colors.white.withValues(alpha: 0.12),
          ),
          boxShadow: active ? G.glassShadow() : const [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.1,
            fontWeight: FontWeight.w600,
            color: active ? G.textPrimary : G.textMuted,
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  const _AuthField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.onSubmitted,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 14.1, color: G.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: G.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.40)),
        ),
        suffixIcon: suffix,
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _SubmitButton({required this.label, required this.loading, required this.onTap});

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.loading ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.loading ? null : widget.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withValues(alpha: 0.20)
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? G.borderHov : G.border,
            ),
          ),
          child: widget.loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 14.1,
                    fontWeight: FontWeight.w700,
                    color: G.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
