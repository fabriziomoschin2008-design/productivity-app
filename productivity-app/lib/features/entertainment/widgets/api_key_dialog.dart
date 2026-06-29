import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/layout/adaptive_layout.dart';
import '../../../core/services/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ApiKeyDialog extends StatefulWidget {
  const ApiKeyDialog({super.key});

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final _ctrl = TextEditingController(text: AppSettings.tmdbApiKey ?? '');
  bool _saving = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_scheduleAutoSave);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.removeListener(_scheduleAutoSave);
    _ctrl.dispose();
    super.dispose();
  }

  void _scheduleAutoSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await AppSettings.setTmdbApiKey(_ctrl.text);
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await AppSettings.setTmdbApiKey(_ctrl.text.trim());
    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = AdaptiveLayout.dialogWidth(context, 440);
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: dialogWidth,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Impostazioni TMDb',
                style: AppTextStyles.headingCard.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Inserisci la tua API key gratuita di The Movie Database (TMDb) per abilitare la ricerca automatica di metadati.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {},
                child: Text(
                  'Come ottenere la chiave gratuita:\n1. Vai su themoviedb.org e crea un account\n2. Profilo → Impostazioni → API\n3. Richiedi chiave API (v3 auth)\n4. Incollala qui sotto',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _ctrl,
                obscureText: false,
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  labelText: 'API Key (v3)',
                  hintText: 'a1b2c3d4e5f6...',
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'La chiave viene salvata automaticamente mentre scrivi.',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annulla'),
                  ),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Salva'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
