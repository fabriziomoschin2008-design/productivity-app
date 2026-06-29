import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_actions.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/layout/adaptive_layout.dart';
import '../../../core/services/app_settings.dart';
import '../../../core/services/error_handler.dart';
import '../../../core/services/sync_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_text_styles.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _apiKeyController;
  Timer? _apiKeyDebounce;
  bool _apiKeySaving = false;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(
      text: AppSettings.tmdbApiKey ?? '',
    );
    _apiKeyController.addListener(_scheduleApiKeySave);
  }

  @override
  void dispose() {
    _apiKeyDebounce?.cancel();
    _apiKeyController.removeListener(_scheduleApiKeySave);
    _apiKeyController.dispose();
    super.dispose();
  }

  void _scheduleApiKeySave() {
    if (mounted) {
      setState(() {});
    }
    _apiKeyDebounce?.cancel();
    _apiKeyDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      setState(() => _apiKeySaving = true);
      try {
        await AppSettings.setTmdbApiKey(_apiKeyController.text.trim());
      } catch (e, s) {
        AppErrorHandler.handle(e, s);
      } finally {
        if (mounted) {
          setState(() => _apiKeySaving = false);
        }
      }
    });
  }

  Future<void> _refreshCloud() async {
    setState(() => _syncing = true);
    try {
      await ref.read(syncWorkerProvider).refreshNow(fullResync: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sincronizzazione completata'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
      }
    }
  }

  Future<void> _clearApiKey() async {
    _apiKeyDebounce?.cancel();
    _apiKeyController.clear();
    setState(() => _apiKeySaving = true);
    try {
      await AppSettings.setTmdbApiKey('');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chiave API rimossa'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    } finally {
      if (mounted) {
        setState(() => _apiKeySaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider).valueOrNull;
    final padding = AdaptiveLayout.pagePadding(context);
    final compact = AdaptiveLayout.isCompact(context);

    return ColoredBox(
      color: AppColors.background,
      child: ListView(
        padding: padding.copyWith(bottom: padding.bottom + (compact ? 88 : 24)),
        children: [
          Text(
            'Impostazioni',
            style: AppTextStyles.headingCard.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 8),
          Text(
            'Account, sincronizzazione cloud, aspetto e integrazioni.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Account',
            icon: Icons.person_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.email ?? 'Nessun account collegato',
                  style: AppTextStyles.bodyRegular.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user == null
                      ? 'Accedi per attivare il sync tra desktop, mobile e web.'
                      : 'Sessione attiva. I dati supportati vengono sincronizzati automaticamente.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (user != null) ...[
                  const SizedBox(height: 8),
                  SelectableText(
                    'UID: ${user.id}',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => handleAuthTap(context, user),
                      icon: Icon(
                        user == null
                            ? Icons.login_rounded
                            : Icons.logout_rounded,
                      ),
                      label: Text(user == null ? 'Accedi' : 'Esci'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Cloud e Sync',
            icon: Icons.cloud_sync_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user == null
                      ? 'Il sync e fermo finche non effettui l\'accesso.'
                      : 'Puoi forzare un refresh completo del cloud in qualsiasi momento.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: user == null || _syncing
                          ? null
                          : _refreshCloud,
                      icon: _syncing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync_rounded),
                      label: Text(
                        _syncing ? 'Sincronizzo...' : 'Sincronizza adesso',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Aspetto',
            icon: Icons.palette_outlined,
            child: SwitchListTile.adaptive(
              value: false,
              onChanged: null,
              contentPadding: EdgeInsets.zero,
              title: const Text('Tema scuro'),
              subtitle: Text(
                'Lo prepariamo nella prossima passata grafica: per ora la beta resta sul tema chiaro.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'TMDb API',
            icon: Icons.key_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inserisci qui la chiave API di The Movie Database per ricerca e metadata automatici.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'API Key (v3)',
                    hintText: 'a1b2c3d4e5f6...',
                    suffixIcon: _apiKeySaving
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : (_apiKeyController.text.trim().isEmpty
                              ? null
                              : IconButton(
                                  onPressed: _clearApiKey,
                                  icon: const Icon(Icons.close_rounded),
                                  tooltip: 'Rimuovi chiave',
                                )),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user == null
                      ? 'La chiave si salva in locale. Dopo il login verra sincronizzata anche sul cloud.'
                      : 'La chiave si salva automaticamente e viene sincronizzata sul tuo account.',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.headingSection.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
