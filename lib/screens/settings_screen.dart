import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../themes/app_themes.dart';
import '../utils/glass_style.dart';

/// Экран настроек
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoginTab = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final themeId = ref.watch(themeIdProvider);
    final theme = AppTheme.all.firstWhere((t) => t.id == themeId, orElse: () => AppTheme.sunset);
    final fontSize = ref.watch(fontSizeProvider);
    
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(gradient: theme.gradient),
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  const Text(
                    'Настройки',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Account section
                  _SectionTitle(title: 'Аккаунт'),
                  const SizedBox(height: 16),
                  _buildAccountCard(),
                  
                  const SizedBox(height: 32),
                  
                  // Theme selection
                  _SectionTitle(title: 'Тема'),
                  const SizedBox(height: 16),
                  _buildThemeGrid(),
                  
                  const SizedBox(height: 32),
                  
                  // Font size
                  _SectionTitle(title: 'Размер шрифта'),
                  const SizedBox(height: 16),
                  _buildFontSizeSelector(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAccountCard() {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      // Auth panel
      return GlassContainer(
        child: Column(
          children: [
            // Tabs
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isLoginTab = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isLoginTab 
                            ? Colors.white.withValues(alpha: 0.1) 
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Войти',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isLoginTab = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isLoginTab 
                            ? Colors.white.withValues(alpha: 0.1) 
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Создать аккаунт',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  if (!_isLoginTab) ...[
                    _TextField(
                      controller: _nameController,
                      label: 'Имя',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _TextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 12),
                  _TextField(
                    controller: _passwordController,
                    label: 'Пароль',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_isLoginTab ? 'Войти' : 'Создать аккаунт'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    } else {
      // Logged in card
      return GlassContainer(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          '✓ Синхронизировано',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: _handleLogout,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
  
  Widget _buildThemeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: AppTheme.all.length,
      itemBuilder: (context, index) {
        final t = AppTheme.all[index];
        final isSelected = t.id == ref.watch(themeIdProvider);
        
        return GestureDetector(
          onTap: () => ref.read(themeIdProvider.notifier).state = t.id,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: t.gradient,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? Colors.white 
                        : Colors.white.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 14, color: Colors.black87),
                  ),
                ),
              Positioned(
                left: 8,
                bottom: 8,
                child: Text(
                  t.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFontSizeSelector() {
    return GlassContainer(
      child: Row(
        children: [
          Expanded(
            child: _FontSizeButton(
              label: 'Маленький',
              scale: 0.9,
              isSelected: fontSize < 1.0,
              onTap: () => ref.read(fontSizeProvider.notifier).state = 0.9,
            ),
          ),
          Expanded(
            child: _FontSizeButton(
              label: 'Средний',
              scale: 1.0,
              isSelected: fontSize == 1.0,
              onTap: () => ref.read(fontSizeProvider.notifier).state = 1.0,
            ),
          ),
          Expanded(
            child: _FontSizeButton(
              label: 'Большой',
              scale: 1.1,
              isSelected: fontSize > 1.0,
              onTap: () => ref.read(fontSizeProvider.notifier).state = 1.1,
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleAuth() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Некорректный email')),
      );
      return;
    }
    
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль должен быть не менее 6 символов')),
      );
      return;
    }
    
    // Simple auth logic (local only)
    // In real app, would use Hive to store/retrieve users
    ref.read(currentUserProvider.notifier).state = null; // Reset for demo
  }
  
  void _handleLogout() {
    ref.read(currentUserProvider.notifier).state = null;
    ref.read(notesProvider.notifier).reset();
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  
  const _SectionTitle({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
        letterSpacing: 0.05.em,
      ),
    );
  }
}

class _TextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  
  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
  });
  
  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  bool _obscureText = true;
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(widget.icon, color: Colors.white38),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white38,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.amber),
        ),
      ),
    );
  }
}

class _FontSizeButton extends StatelessWidget {
  final String label;
  final double scale;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _FontSizeButton({
    required this.label,
    required this.scale,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.amber.withValues(alpha: 0.2) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Colors.amber 
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14 * scale,
            color: isSelected ? Colors.amber : Colors.white70,
          ),
        ),
      ),
    );
  }
}
