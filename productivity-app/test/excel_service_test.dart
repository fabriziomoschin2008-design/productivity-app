import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/data/local/database.dart';
import 'package:productivity_app/features/finance/services/excel_service.dart';

void main() {
  group('ExcelService.importAccountsBytes', () {
    test('updates an existing account matched by normalized name', () async {
      final now = DateTime(2026, 6, 29, 12);
      final existingAccount = Account(
        id: 'acc-1',
        userId: 'user-1',
        name: 'Conto Corrente',
        colorValue: 0xFFFFFFFF,
        openingBalance: 100,
        createdAt: now,
        updatedAt: now,
      );

      final bytes = _buildImportFile(
        contiRows: const [
          ['', '  conto corrente  ', '250.50'],
        ],
        transazioniRows: const [
          ['', 'conto corrente', '2026-06-29', 'expense', '25', 'Spesa', ''],
        ],
      );

      final result = await ExcelService.importAccountsBytes(
        bytes,
        [existingAccount],
      );

      expect(result.error, isNull);
      expect(result.newAccounts, isEmpty);
      expect(result.updatedAccountIds, ['acc-1']);
      expect(result.updatedAccounts, hasLength(1));
      expect(result.updatedAccounts.single.id, 'acc-1');
      expect(result.updatedAccounts.single.name, 'conto corrente');
      expect(result.updatedAccounts.single.openingBalance, 250.50);
      expect(result.transactions, hasLength(1));
      expect(result.transactions.single.accountId, 'acc-1');
    });

    test('returns an error when the import file contains duplicate accounts', () async {
      final bytes = _buildImportFile(
        contiRows: const [
          ['', 'Carta', '100'],
          ['', ' carta ', '200'],
        ],
        transazioniRows: const [],
      );

      final result = await ExcelService.importAccountsBytes(bytes, const []);

      expect(result.error, contains('conto duplicato'));
      expect(result.newAccounts, isEmpty);
      expect(result.updatedAccounts, isEmpty);
      expect(result.transactions, isEmpty);
    });
  });
}

Uint8List _buildImportFile({
  required List<List<String>> contiRows,
  required List<List<String>> transazioniRows,
}) {
  final excel = Excel.createExcel();
  final conti = excel['Conti'];
  final transazioni = excel['Transazioni'];

  _appendRow(
    conti,
    0,
    const ['ID (vuoto = nuovo conto)', 'Nome', 'Saldo Apertura'],
  );
  for (var i = 0; i < contiRows.length; i++) {
    _appendRow(conti, i + 1, contiRows[i]);
  }

  _appendRow(
    transazioni,
    0,
    const [
      'Account ID (opz.)',
      'Nome Conto',
      'Data (YYYY-MM-DD)',
      'Tipo',
      'Importo',
      'Categoria',
      'Note',
    ],
  );
  for (var i = 0; i < transazioniRows.length; i++) {
    _appendRow(transazioni, i + 1, transazioniRows[i]);
  }

  if (excel.sheets.containsKey('Sheet1')) {
    excel.delete('Sheet1');
  }

  final bytes = excel.save();
  if (bytes == null) {
    throw StateError('Impossibile generare il file di test');
  }
  return Uint8List.fromList(bytes);
}

void _appendRow(Sheet sheet, int rowIndex, List<String> values) {
  for (var columnIndex = 0; columnIndex < values.length; columnIndex++) {
    sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: columnIndex,
            rowIndex: rowIndex,
          ),
        )
        .value = TextCellValue(values[columnIndex]);
  }
}
