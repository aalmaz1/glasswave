import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_providers.dart';
import '../models/app_user.dart';
import '../theme/app_theme_data.dart';
import '../theme/design_tokens.dart';
import '../widgets/glass_container.dart';
import '../widgets/background_orbs.dart';

/// Settings screen restyled 1:1 after the React Native `SettingsScreen`:
/// max-width 666 sections, glass back button, theme grid with previews +
/// check badge, dropdown language selector, account card with shield badge,
/// red-tinted danger zone and a glass delete-account dialog.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(themeProvider);
    final theme = allThemes.firstWhere((t) => t.id == prefs.themeId);
    final user = ref.watch(authProvider);
    final width = MediaQuery.of(context).size.width;
    final headerPad = width < 768 ? 16.0 : (width < 1280 ? 28.0 : 44.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackgroundOrbs(theme: theme),
          // React scrolls the whole settings page, header included.
          ListView(
            padding: const EdgeInsets.only(bottom: 64),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  headerPad,
                  28 + MediaQuery.of(context).padding.top,
                  headerPad,
                  28,
                ),
                child: Row(
                  children: [
                    _BackButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        tr('settings_title'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.8,
                          color: G.textPrimary,
                          // React: `letterSpacing: "-0.02em"` on 1.3rem.
                          letterSpacing: -0.42,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _Section(
                label: tr('settings_account'),
                icon: LucideIcons.user,
                child: user == null ? const _AuthPanel() : _AccountCard(user: user),
              ),
              _Section(
                label: tr('settings_theme'),
                icon: LucideIcons.palette,
                child: _ThemeGrid(current: prefs.themeId),
              ),
              _Section(
                label: tr('settings_lang'),
                icon: LucideIcons.languages,
                child: _LanguageSelector(current: prefs.language),
              ),
              if (user != null)
                _Section(
                  label: tr('danger_zone'),
                  icon: LucideIcons.trash2,
                  child: _DangerZone(email: user.email),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Helpers
// ════════════════════════════════════════════════════════════════════

String _themeName(ThemeId id, String lang) {
  const names = {
    'en': {
      ThemeId.sunset: 'Warm Sunset',
      ThemeId.ice: 'Icy Fresh',
      ThemeId.mono: 'Monochrome',
      ThemeId.cyber: 'Cyber Sunset',
      ThemeId.aurora: 'Northern Lights',
      ThemeId.rose: 'Midnight Rose',
      ThemeId.cosmos: 'Deep Space',
      ThemeId.forest: 'Dark Forest',
      ThemeId.obsidian: 'Obsidian',
      ThemeId.graphite: 'Graphite',
      ThemeId.midnight: 'Midnight',
      ThemeId.espresso: 'Espresso',
    },
    'ru': {
      ThemeId.sunset: 'Тёплый закат',
      ThemeId.ice: 'Ледяная свежесть',
      ThemeId.mono: 'Монохром',
      ThemeId.cyber: 'Кибер-закат',
      ThemeId.aurora: 'Северное сияние',
      ThemeId.rose: 'Полночная роза',
      ThemeId.cosmos: 'Глубокий космос',
      ThemeId.forest: 'Тёмный лес',
      ThemeId.obsidian: 'Обсидиан',
      ThemeId.graphite: 'Графит',
      ThemeId.midnight: 'Полночь',
      ThemeId.espresso: 'Эспрессо',
    },
    'ko': {
      ThemeId.sunset: '따뜻한 석양',
      ThemeId.ice: '시원한 얼음',
      ThemeId.mono: '모노크롬',
      ThemeId.cyber: '사이버 석양',
      ThemeId.aurora: '오로라',
      ThemeId.rose: '미드나잇 로즈',
      ThemeId.cosmos: '딥 스페이스',
      ThemeId.forest: '어두운 숲',
      ThemeId.obsidian: '옵시디언',
      ThemeId.graphite: '그래파이트',
      ThemeId.midnight: '미드나잇',
      ThemeId.espresso: '에스프레소',
    },
  };
  return names[lang]?[id] ?? names['en']![id]!;
}

class _Section extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;

  const _Section({required this.label, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final padH = isMobile ? 16.0 : (width < 1280 ? 28.0 : 44.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(padH, 0, padH, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 666),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 13, color: G.textMuted),
                  const SizedBox(width: 8),
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.9,
                      fontWeight: FontWeight.w600,
                      color: G.textMuted,
                      letterSpacing: 0.9,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        blur: 16,
        borderRadius: 12,
        child: const SizedBox(
          width: 38,
          height: 38,
          child: Icon(LucideIcons.chevronLeft, size: 18, color: G.textSecondary),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Account
// ════════════════════════════════════════════════════════════════════

class _AccountCard extends ConsumerWidget {
  final AppUser user;
  const _AccountCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // React: `{user.name || user.email}`
                  user.name.isNotEmpty ? user.name : user.email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.7,
                    color: G.textPrimary,
                  ),
                ),
                // React: `margin: "2px 0 0"`.
                const SizedBox(height: 2),
                Text(
                  user.email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.8, color: G.textMuted),
                ),
              ],
            ),
          ),
          // React: a single `gap: 16` between all three children.
          const SizedBox(width: 16),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0x1A00C850), // rgba(0,200,80,0.10)
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x3300C850)), // 0.20
            ),
            child: const Icon(LucideIcons.shield, size: 15, color: Color(0xCC00DC64)),
          ),
          const SizedBox(width: 16),
          _LogoutButton(
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                final svc = ref.read(persistenceServiceProvider);
                final guestLang = svc.getGuestLanguage();
                await EasyLocalization.of(context)!.setLocale(Locale(guestLang));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        blur: 12,
        borderRadius: 10,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(LucideIcons.logOut, size: 15, color: G.textSecondary),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Auth panel (React. AuthPanel inside Settings)
// ════════════════════════════════════════════════════════════════════

class _AuthPanel extends ConsumerStatefulWidget {
  const _AuthPanel();

  @override
  ConsumerState<_AuthPanel> createState() => _AuthPanelState();
}

class _AuthPanelState extends ConsumerState<_AuthPanel> {
  bool _isLogin = true;
  bool _showPw = false;
  bool _isLoading = false;
  String _error = '';
  bool _success = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pwController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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
    if (!mounted) return;
    setState(() {
      _error = res ?? '';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      child: Column(
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
          Column(
            children: [
              if (!_isLogin) ...[
                _AuthField(controller: _nameController, hint: tr('auth_name')),
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
            ],
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _error,
              style: TextStyle(
                fontSize: 12.5,
                color: _success ? const Color(0xE652DC78) : const Color(0xE6FF6464),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _SubmitButton(
            label: _isLogin ? tr('auth_submit_login') : tr('auth_submit_register'),
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

// ════════════════════════════════════════════════════════════════════
// Theme grid
// ════════════════════════════════════════════════════════════════════

class _ThemeGrid extends ConsumerWidget {
  final ThemeId current;
  const _ThemeGrid({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQuery.of(context).size.width;
        // React CSS: `@media (max-width:768px)` → 4 columns (gap 8),
        // `@media (min-width:992px)` → 6 columns (gap 10). Between those two
        // breakpoints React falls back to `flex-wrap`, and the section is
        // capped at 666px, so ~92px-wide tiles wrap at 6 per row there too.
        final cols = width < 768 ? 4 : 6;
        final gap = width < 768 ? 8.0 : 10.0;
        final itemW = (constraints.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final t in allThemes)
              SizedBox(
                width: itemW,
                child: _ThemeTile(
                  theme: t,
                  active: t.id == current,
                  onChange: () => ref.read(themeProvider.notifier).setTheme(t.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final AppThemeData theme;
  final bool active;
  final VoidCallback onChange;

  const _ThemeTile({required this.theme, required this.active, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    return GestureDetector(
      onTap: onChange,
      child: GlassContainer(
        blur: 20,
        borderRadius: 18,
        border: Border.all(
          color: active ? const Color(0x80FFFFFF) : G.border, // white 0.50 / 0.20
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 48,
                  offset: const Offset(0, 16),
                ),
              ]
            : G.glassShadow(),
        // Active tiles use `inset 0 1px 0 rgba(255,255,255,0.28)` and drop the
        // bottom inset; inactive ones keep the standard `glassBase()` edges.
        innerTop: active ? G.innerTopStrong : G.innerTop,
        innerBottom: active ? Colors.transparent : G.innerBottom,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, previewConstraints) {
                  final tileW = previewConstraints.maxWidth;
                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: theme.bgGradient(Size(tileW, 56)),
                          ),
                        ),
                      ),
                      ...theme.orbs.take(2).toList().asMap().entries.map((entry) {
                        final i = entry.key;
                        final orb = entry.value;
                        // React: size * 0.3, top -30% / 20%, left -10% / 52%
                        final orbW = orb.size * 0.30;
                        return Positioned(
                          top: i == 0 ? -16.8 : 11.2,
                          left: i == 0 ? -tileW * 0.10 : tileW * 0.52,
                          child: Container(
                            width: orbW,
                            height: orbW,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [orb.color, orb.color.withValues(alpha: 0)],
                                stops: const [0.0, 0.70],
                              ),
                            ),
                          ),
                        );
                      }),
                      if (active)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xE6FFFFFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.check,
                                size: 12, color: Color(0xFF111111)),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(theme.emoji, style: const TextStyle(fontSize: 19.2, height: 1)),
                  const SizedBox(height: 4),
                  Text(
                    _themeName(theme.id, lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.9,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: active ? G.textPrimary : G.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ════════════════════════════════════════════════════════════════════
// Language
// ════════════════════════════════════════════════════════════════════

class _LanguageSelector extends ConsumerWidget {
  final String current;
  const _LanguageSelector({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: G.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Colors.white30),
          dropdownColor: const Color(0xFF17171D),
          style: const TextStyle(
            color: G.textPrimary,
            fontSize: 13.8,
          ),
          items: [
            DropdownMenuItem(value: 'ru', child: Text('Русский')),
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'ko', child: Text('한국어')),
          ],
          onChanged: (value) async {
            if (value == null) return;
            final locale = Locale(value);
            await EasyLocalization.of(context)!.setLocale(locale);
            ref.read(themeProvider.notifier).setLanguage(value);
            final email = ref.read(authProvider)?.email;
            if (email != null) {
              await ref.read(persistenceServiceProvider).saveLanguage(email, value);
            } else {
              await ref.read(persistenceServiceProvider).saveLanguage('guest', value);
            }
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Danger zone + delete dialog
// ════════════════════════════════════════════════════════════════════

class _DangerZone extends ConsumerWidget {
  final String email;
  const _DangerZone({required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      borderRadius: 18,
      border: Border.all(color: const Color(0x47FF6464)), // rgba(255,100,100,0.28)
      color: const Color(0x21911423), // rgba(145,20,35,0.13)
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // React: `flexWrap: wrap` with a `flex: 1 1 180px` text block, so the
          // button drops below the copy once the row gets too narrow.
          final wide = constraints.maxWidth >= 300;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('delete_account'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.7,
                  color: Color(0xFAFFBEBE),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                tr('delete_account_desc'),
                style: const TextStyle(
                  fontSize: 12.2,
                  height: 1.55,
                  color: Color(0x9EFFDCDC),
                ),
              ),
            ],
          );
          final button = GestureDetector(
            onTap: () => _confirmDelete(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0x33E63741), // rgba(230,55,65,0.20)
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x8CFF6969)), // 0.55
              ),
              child: Text(
                tr('delete_account'),
                style: const TextStyle(
                  fontSize: 12.2,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFAFFD2D2),
                ),
              ),
            ),
          );
          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [text, const SizedBox(height: 16), button],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: text), const SizedBox(width: 16), button],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'delete-account',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (context, animation, secondaryAnimation, child) => child,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _DeleteAccountDialog(
          email: email,
          onDismiss: () => Navigator.pop(dialogContext),
        );
      },
    );
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  final String email;
  final VoidCallback onDismiss;

  const _DeleteAccountDialog({required this.email, required this.onDismiss});

  @override
  ConsumerState<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _pwController = TextEditingController();
  bool _showPw = false;
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _pwController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_pwController.text.isEmpty) {
      setState(() => _error = tr('auth_error_pw'));
      return;
    }
    setState(() {
      _error = '';
      _loading = true;
    });
    final error = await ref.read(authProvider.notifier).deleteAccount(_pwController.text);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _error = tr(error);
        _loading = false;
      });
      return;
    }
    // Close the dialog, then the settings screen (React: back to dashboard).
    final navigator = Navigator.of(context);
    navigator.pop();
    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _loading ? null : widget.onDismiss,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withValues(alpha: 0.68)),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 220),
              curve: const Cubic(0.34, 1.46, 0.64, 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.96 + 0.04 * value,
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: GlassContainer(
                  blur: 28,
                  borderRadius: 22,
                  border: Border.all(color: const Color(0x61FF7373)), // 0.38
                  boxShadow: G.confirmShadow,
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0x2EEB373F), // 0.18
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  LucideIcons.trash2,
                                  size: 17,
                                  color: Color(0xF2FF9191),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                tr('delete_account_title'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFAFFD7D7),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: _loading ? null : widget.onDismiss,
                            icon: const Icon(LucideIcons.x, size: 18, color: G.textSecondary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text.rich(
                        TextSpan(
                          text: tr('delete_account_warning'),
                          style: const TextStyle(
                            fontSize: 13.1,
                            height: 1.6,
                            color: G.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: ' ${widget.email}',
                              style:
                                  const TextStyle(color: G.textPrimary, fontWeight: FontWeight.w700),
                            ),
                            // React: `{t.deleteWarning} <strong>{email}</strong>{suffix}`
                            TextSpan(text: tr('delete_account_suffix')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        tr('password_confirm'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xC7FFDCDC),
                        ),
                      ),
                      const SizedBox(height: 7),
                      TextField(
                        controller: _pwController,
                        obscureText: !_showPw,
                        autofocus: true,
                        enabled: !_loading,
                        onChanged: (_) => setState(() => _error = ''),
                        onSubmitted: (_) => _submit(),
                        style: const TextStyle(fontSize: 13.8, color: G.textPrimary),
                        decoration: InputDecoration(
                          hintText: tr('password_placeholder'),
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(13, 11, 42, 11),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0x4DFFA0A0)), // 0.30
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.40)),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _showPw = !_showPw),
                            icon: Icon(
                              _showPw ? LucideIcons.eyeOff : LucideIcons.eye,
                              size: 16,
                              color: G.textMuted,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                      if (_error.isNotEmpty) ...[
                        const SizedBox(height: 9),
                        Text(
                          _error,
                          style: const TextStyle(fontSize: 12, color: Color(0xF5FF9191)),
                        ),
                      ],
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: _loading ? null : widget.onDismiss,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(color: G.border),
                              ),
                              child: Text(
                                tr('cancel'),
                                style: const TextStyle(
                                  fontSize: 12.8,
                                  fontWeight: FontWeight.w600,
                                  color: G.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _loading || _pwController.text.isEmpty ? null : _submit,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0x6BE13741), // rgba(225,55,65,0.42)
                                borderRadius: BorderRadius.circular(11),
                                border:
                                    Border.all(color: const Color(0x8CFF6969)),
                              ),
                              child: Text(
                                _loading ? tr('deleting') : tr('delete_forever'),
                                style: const TextStyle(
                                  fontSize: 12.8,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
