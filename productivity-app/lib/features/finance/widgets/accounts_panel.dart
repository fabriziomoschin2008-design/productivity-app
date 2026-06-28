import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/local/database.dart';
import '../models/account_with_balance.dart';
import '../providers/finance_providers.dart';
import '../services/excel_service.dart';
import '../services/template_download_service.dart';
import '../state/finance_state.dart';
import 'add_account_dialog.dart';
import 'charts_panel.dart';
import 'edit_account_dialog.dart';
import 'export_dialog.dart';
import 'import_dialog.dart';

class AccountsPanel extends ConsumerWidget {
  const AccountsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeProvider);

    return Container(
      width: 272,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            onAdd: () => showDialog(
              context: context,
              builder: (_) => const AddAccountDialog(),
            ),
            onExport: () => _export(context, ref, state),
            onImport: () => _import(context, ref),
            onDownloadTemplate: () => _downloadTemplate(context),
          ),
          const Divider(),
          Expanded(
            child: state.accounts.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.accounts.length,
                    itemBuilder: (_, i) {
                      final awb = state.accounts[i];
                      return _AccountTile(
                        awb: awb,
                        selected: awb.account.id == state.selectedAccountId,
                        onTap: () => ref
                            .read(financeProvider.notifier)
                            .selectAccount(awb.account.id),
                        onEdit: () => showDialog(
                          context: context,
                          builder: (_) =>
                              EditAccountDialog(account: awb.account),
                        ),
                        onDelete: () => _confirmDelete(context, ref, awb),
                      );
                    },
                  ),
          ),
          const Divider(),
          _TotalRow(total: state.totalBalance),
        ],
      ),
    );
  }

  // ── Export ──────────────────────────────────────────────────────────────────

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    FinanceState state,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ExportProgressDialog(),
    );

    try {
      final images = await _captureCharts(context, state.transactions);

      final dir = await ExcelService.exportAccounts(
        state.accounts,
        state.transactions,
        chartImages: images.isEmpty ? null : images,
        chartTitles: const [
          'Grafico_Spese_per_Categoria',
          'Grafico_Entrate_vs_Spese',
          'Grafico_Andamento_Saldo',
        ],
      );

      if (!context.mounted) return;
      Navigator.pop(context); // close loading dialog

      showDialog(
        context: context,
        builder: (_) => ExportDialog(exportedDir: dir),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore export: $e')));
    }
  }

  /// Renders each chart off-screen (Opacity 0.01 = nearly invisible but painted)
  /// and captures it as a PNG via RepaintBoundary.toImage().
  Future<List<Uint8List>> _captureCharts(
    BuildContext context,
    List<TransactionEntry> transactions,
  ) async {
    final images = <Uint8List>[];
    final overlay = Overlay.of(context, rootOverlay: true);

    for (int chartIndex = 0; chartIndex < 3; chartIndex++) {
      final key = GlobalKey();
      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (_) => Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.01,
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 900,
                  height: 450,
                  child: Material(
                    color: Colors.white,
                    child: RepaintBoundary(
                      key: key,
                      child: ExportChartWidget(
                        chartIndex: chartIndex,
                        transactions: transactions,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      overlay.insert(entry);

      // Wait for Flutter to lay out and paint the widget.
      await Future.delayed(const Duration(milliseconds: 350));

      try {
        final boundary =
            key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 2.0);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          if (data != null) images.add(data.buffer.asUint8List());
        }
      } catch (_) {
        // Non-fatal: skip this chart if capture fails.
      } finally {
        entry.remove();
      }
    }

    return images;
  }

  // ── Import ──────────────────────────────────────────────────────────────────

  void _import(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => ImportDialog(
        onImport: (file) async {
          try {
            final result = await ref
                .read(financeProvider.notifier)
                .importAccountsFromExcel(file);

            if (!context.mounted) return;

            if (result.success) {
              final total =
                  (result.created?.length ?? 0) + (result.updated?.length ?? 0);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Importati $total conti con le relative transazioni',
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Errore: ${result.error}')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Errore import: $e')));
            }
          }
        },
      ),
    );
  }

  // ── Template ────────────────────────────────────────────────────────────────

  Future<void> _downloadTemplate(BuildContext context) async {
    try {
      final bytes = ExcelService.generateTemplateBytes();
      final result = await saveTemplateBytes(
        bytes: bytes,
        fileName: 'Template_Conti.xlsx',
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      if (result.cancelled || !context.mounted) return;

      if (result.savedPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Template inviato al download del browser. Per scegliere sempre la cartella, abilita la richiesta di salvataggio nel browser.',
            ),
          ),
        );
        return;
      }

      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (_) => ExportDialog(exportedDir: result.savedPath!),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore download template: $e')));
    }
  }

  // ── Delete confirm ──────────────────────────────────────────────────────────

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AccountWithBalance awb,
  ) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Elimina conto'),
        content: Text(
          'Eliminare "${awb.account.name}" e tutti i suoi movimenti?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              ref.read(financeProvider.notifier).deleteAccount(awb.account.id);
            },
            child: Text('Elimina', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }
}

// ── Panel header ─────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onDownloadTemplate;

  const _PanelHeader({
    required this.onAdd,
    required this.onExport,
    required this.onImport,
    required this.onDownloadTemplate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('CONTI', style: AppTextStyles.headingSection),
              const Spacer(),
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                color: AppColors.primary,
                tooltip: 'Nuovo conto',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderButton(
                icon: Icons.download,
                label: 'Template',
                onPressed: onDownloadTemplate,
              ),
              _HeaderButton(
                icon: Icons.save_alt,
                label: 'Esporta',
                onPressed: onExport,
              ),
              _HeaderButton(
                icon: Icons.upload_file,
                label: 'Importa',
                onPressed: onImport,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider, width: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Account tile ─────────────────────────────────────────────────────────────

class _AccountTile extends StatelessWidget {
  final AccountWithBalance awb;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AccountTile({
    required this.awb,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(awb.account.colorValue);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.transparent,
            border: selected
                ? const Border(
                    left: BorderSide(color: AppColors.accent, width: 3),
                  )
                : const Border(
                    left: BorderSide(color: Colors.transparent, width: 3),
                  ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      awb.account.name,
                      style: AppTextStyles.headingCard.copyWith(
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatCurrency(awb.balance),
                      style: AppTextStyles.amountSmall.copyWith(
                        color: awb.balance < 0
                            ? AppColors.expense
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Modifica')),
                  PopupMenuItem(value: 'delete', child: Text('Elimina')),
                ],
                icon: const Icon(
                  Icons.more_vert,
                  size: 16,
                  color: AppColors.textDisabled,
                ),
                padding: EdgeInsets.zero,
                splashRadius: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Total row ─────────────────────────────────────────────────────────────────

class _TotalRow extends StatelessWidget {
  final double total;
  const _TotalRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTALE', style: AppTextStyles.headingSection),
          const SizedBox(height: 6),
          Text(
            formatCurrency(total),
            style: AppTextStyles.displayAmount.copyWith(fontSize: 22),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 36,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 12),
            Text('Nessun conto', style: AppTextStyles.bodySmall),
            const SizedBox(height: 4),
            Text('Usa + per aggiungerne uno', style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}

// ── Loading dialog ─────────────────────────────────────────────────────────────

class _ExportProgressDialog extends StatelessWidget {
  const _ExportProgressDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(
              'Generazione export in corso…',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
