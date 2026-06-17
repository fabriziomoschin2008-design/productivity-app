import 'package:flutter/material.dart';
import '../widgets/accounts_panel.dart';
import '../widgets/transactions_panel.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AccountsPanel(),
        const VerticalDivider(width: 1),
        const Expanded(child: TransactionsPanel()),
      ],
    );
  }
}
