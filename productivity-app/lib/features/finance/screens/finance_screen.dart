import 'package:flutter/material.dart';
import '../../../core/layout/adaptive_layout.dart';
import '../widgets/accounts_panel.dart';
import '../widgets/transactions_panel.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (AdaptiveLayout.isCompact(context)) {
      return DefaultTabController(
        length: 2,
        child: Column(
          children: const [
            TabBar(
              tabs: [
                Tab(text: 'Conti'),
                Tab(text: 'Movimenti'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [AccountsPanel(), TransactionsPanel()],
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        const AccountsPanel(),
        const VerticalDivider(width: 1),
        const Expanded(child: TransactionsPanel()),
      ],
    );
  }
}
