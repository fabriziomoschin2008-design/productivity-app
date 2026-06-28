import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifications/notification_ids.dart';
import '../notifications/notification_service.dart';
import '../theme/app_text_styles.dart';
import '../../features/tracker/providers/tracker_providers.dart';
import 'debug_provider.dart';

class DebugPanel extends ConsumerStatefulWidget {
  const DebugPanel({super.key});

  @override
  ConsumerState<DebugPanel> createState() => _DebugPanelState();
}

class _DebugPanelState extends ConsumerState<DebugPanel> {
  Offset _position = const Offset(16, 80);
  bool _dragging = false;
  Offset _dragStart = Offset.zero;
  Offset _posStart = Offset.zero;
  DateTime _selectedDebugDate = DateTime.now();

  // Countdown refresh
  Timer? _ticker;
  String _midnightIn = '';
  String _todoIn = '';
  String _habitIn = '';

  @override
  void initState() {
    super.initState();
    _updateCountdowns();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _updateCountdowns());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _updateCountdowns() {
    final now = DateTime.now();
    _midnightIn = _countdownTo(DateTime(now.year, now.month, now.day + 1));
    _habitIn = _countdownTo(_nextDailyAt(now, 20, 0));
    _todoIn = _countdownTo(_nextDailyAt(now, 8, 0));
  }

  DateTime _nextDailyAt(DateTime now, int hour, int minute) {
    var t = DateTime(now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now)) t = t.add(const Duration(days: 1));
    return t;
  }

  String _countdownTo(DateTime target) {
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return '—';
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateLabel =
        '${_selectedDebugDate.day.toString().padLeft(2, '0')}/'
        '${_selectedDebugDate.month.toString().padLeft(2, '0')}/'
        '${_selectedDebugDate.year}';

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (d) {
          setState(() {
            _dragging = true;
            _dragStart = d.globalPosition;
            _posStart = _position;
          });
        },
        onPanUpdate: (d) {
          setState(() {
            _position = _posStart + (d.globalPosition - _dragStart);
          });
        },
        onPanEnd: (_) => setState(() => _dragging = false),
        child: Material(
          elevation: _dragging ? 16 : 8,
          borderRadius: BorderRadius.circular(14),
          color: Colors.transparent,
          child: Container(
            width: 240,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1B18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF3A3530), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(dragging: _dragging),
                const Divider(height: 1, color: Color(0xFF3A3530)),
                _Section(
                  label: 'TRACKER',
                  rows: [
                    _Row(
                      icon: Icons.update_rounded,
                      label: 'Simula mezzanotte',
                      countdown: _midnightIn,
                      onTap: () => ref
                          .read(trackerProvider.notifier)
                          .triggerAutoIncrement(),
                    ),
                    _Row(
                      icon: Icons.event_rounded,
                      label: selectedDateLabel,
                      countdown: 'giorno',
                      onTap: _pickDebugDate,
                    ),
                    _Row(
                      icon: Icons.fast_forward_rounded,
                      label: 'Simula fino al giorno',
                      countdown: '',
                      onTap: () => ref
                          .read(trackerProvider.notifier)
                          .triggerAutoIncrementUntil(_selectedDebugDate),
                    ),
                  ],
                ),
                const Divider(height: 1, color: Color(0xFF3A3530)),
                _Section(
                  label: 'NOTIFICHE',
                  rows: [
                    _Row(
                      icon: Icons.self_improvement_rounded,
                      label: 'Reminder abitudini',
                      countdown: _habitIn,
                      onTap: () => NotificationService.instance.show(
                        id: kHabitReminderId,
                        title: '[DEBUG] Abitudini di oggi',
                        body: 'Hai abitudini da registrare. Apri Cubby.',
                      ),
                    ),
                    _Row(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Reminder task',
                      countdown: _todoIn,
                      onTap: () => NotificationService.instance.show(
                        id: kTodoMorningId,
                        title: '[DEBUG] Task di oggi',
                        body: 'Hai task in scadenza entro domani.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDebugDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDebugDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('it'),
    );
    if (picked == null) return;
    setState(() => _selectedDebugDate = picked);
  }
}

// ──────────────────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  final bool dragging;
  const _Header({required this.dragging});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.bug_report_rounded,
            size: 14,
            color: Color(0xFF7CFC00),
          ),
          const SizedBox(width: 6),
          Text(
            'DEBUG MODE',
            style: AppTextStyles.label.copyWith(
              color: const Color(0xFF7CFC00),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => ref.read(debugModeProvider.notifier).state = false,
            child: const Icon(
              Icons.close_rounded,
              size: 15,
              color: Color(0xFF8C7B6E),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final List<_Row> rows;
  const _Section({required this.label, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: const Color(0xFF5A5550),
              fontSize: 9,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          ...rows,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String countdown;
  final VoidCallback onTap;

  const _Row({
    required this.icon,
    required this.label,
    required this.countdown,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF8C7B6E)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFFD4C9C0),
                fontSize: 11,
              ),
            ),
          ),
          Text(
            countdown,
            style: AppTextStyles.amountSmall.copyWith(
              color: const Color(0xFF5A5550),
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2A26),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF4A4540)),
              ),
              child: const Text(
                '▶',
                style: TextStyle(fontSize: 9, color: Color(0xFF7CFC00)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
