import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/layout/adaptive_layout.dart';
import '../../core/services/error_handler.dart';
import '../../core/services/logger_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    try {
      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        AppLogger.instance.info('Login Supabase riuscito: $email');
      } else {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        AppLogger.instance.info('Registrazione Supabase avviata: $email');
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLogin
                ? 'Accesso effettuato. Il sync puo partire.'
                : 'Account creato. Se richiesto, conferma la mail e poi accedi.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = AdaptiveLayout.dialogWidth(context, 360);

    return AlertDialog(
      scrollable: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      title: Text(
        _isLogin ? 'Accedi a Supabase' : 'Crea account Supabase',
        style: AppTextStyles.headingCard,
      ),
      content: SizedBox(
        width: dialogWidth,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Il login serve per attivare il sync tra desktop, mobile e web.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty || !email.contains('@')) {
                    return 'Inserisci una email valida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if ((value ?? '').length < 6) {
                    return 'Minimo 6 caratteri';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: _submitting
                    ? null
                    : () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? 'Non hai un account? Registrati'
                      : 'Hai gia un account? Accedi',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Chiudi'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(
            _submitting
                ? 'Attendi...'
                : _isLogin
                ? 'Accedi'
                : 'Registrati',
          ),
        ),
      ],
    );
  }
}
