import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../models/account_with_balance.dart';

const _uuid = Uuid();

class ExcelService {
  // ── Directory helpers ──────────────────────────────────────────────────────

  static Future<String> _getExportBase() async {
    final appDataDir = Platform.environment['LOCALAPPDATA'] ?? '';
    final dir = Directory('$appDataDir\\ProductivityApp\\exports');
    await dir.create(recursive: true);
    return dir.path;
  }

  static Future<String> _getTemplateDir() async {
    final appDataDir = Platform.environment['LOCALAPPDATA'] ?? '';
    final dir = Directory('$appDataDir\\ProductivityApp\\templates');
    await dir.create(recursive: true);
    return dir.path;
  }

  // ── Style helpers ──────────────────────────────────────────────────────────

  static CellStyle _header() => CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#1E3A5F'),
        fontColorHex: ExcelColor.white,
        horizontalAlign: HorizontalAlign.Left,
      );

  static CellStyle _subHeader() => CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#2D5F8A'),
        fontColorHex: ExcelColor.white,
      );

  static CellStyle _altRow() =>
      CellStyle(backgroundColorHex: ExcelColor.fromHexString('#F0F4F8'));

  static CellStyle _income() =>
      CellStyle(fontColorHex: ExcelColor.fromHexString('#1A7A45'));

  static CellStyle _expense() =>
      CellStyle(fontColorHex: ExcelColor.fromHexString('#C0392B'));

  static CellStyle _incomeAlt() => CellStyle(
        fontColorHex: ExcelColor.fromHexString('#1A7A45'),
        backgroundColorHex: ExcelColor.fromHexString('#F0F4F8'),
      );

  static CellStyle _expenseAlt() => CellStyle(
        fontColorHex: ExcelColor.fromHexString('#C0392B'),
        backgroundColorHex: ExcelColor.fromHexString('#F0F4F8'),
      );

  static void _set(Sheet sheet, int col, int row, String value,
      {CellStyle? style}) {
    final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(value);
    if (style != null) cell.cellStyle = style;
  }

  static String _cellStr(List<Data?> row, int col) =>
      col < row.length ? (row[col]?.value?.toString().trim() ?? '') : '';

  // ── Export ─────────────────────────────────────────────────────────────────

  /// Genera la cartella export e restituisce il suo percorso.
  static Future<String> exportAccounts(
    List<AccountWithBalance> accounts,
    List<TransactionEntry> transactions, {
    List<Uint8List>? chartImages,
    List<String>? chartTitles,
  }) async {
    final timestamp =
        DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    final base = await _getExportBase();
    final exportDir = Directory('$base\\Export_$timestamp');
    await exportDir.create(recursive: true);

    // ── xlsx ──
    final excel = Excel.createExcel();
    _buildContiSheet(excel['Conti'], accounts);
    _buildTransazioniSheet(excel['Transazioni'], accounts, transactions);
    _buildSommarioSheet(excel['Sommario'], accounts, transactions);
    if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');

    final bytes = excel.save();
    if (bytes != null) {
      await File('${exportDir.path}\\Conti_$timestamp.xlsx')
          .writeAsBytes(bytes);
    }

    // ── Chart PNG files ──
    if (chartImages != null) {
      for (int i = 0; i < chartImages.length; i++) {
        final title = (chartTitles != null && i < chartTitles.length)
            ? chartTitles[i]
            : 'Grafico_$i';
        await File('${exportDir.path}\\$title.png')
            .writeAsBytes(chartImages[i]);
      }
    }

    return exportDir.path;
  }

  static void _buildContiSheet(
      Sheet sheet, List<AccountWithBalance> accounts) {
    sheet.setColumnWidth(0, 38);
    sheet.setColumnWidth(1, 26);
    sheet.setColumnWidth(2, 18);
    sheet.setColumnWidth(3, 18);

    const headers = ['ID', 'Nome', 'Saldo Apertura (€)', 'Saldo Attuale (€)'];
    for (int c = 0; c < headers.length; c++) {
      _set(sheet, c, 0, headers[c], style: _header());
    }

    final nf = NumberFormat('#,##0.00', 'it_IT');
    for (int i = 0; i < accounts.length; i++) {
      final acc = accounts[i];
      final row = i + 1;
      final alt = i.isOdd ? _altRow() : null;
      _set(sheet, 0, row, acc.account.id, style: alt);
      _set(sheet, 1, row, acc.account.name, style: alt);
      _set(sheet, 2, row, nf.format(acc.account.openingBalance), style: alt);
      _set(sheet, 3, row, nf.format(acc.balance), style: alt);
    }
  }

  static void _buildTransazioniSheet(
    Sheet sheet,
    List<AccountWithBalance> accounts,
    List<TransactionEntry> transactions,
  ) {
    sheet.setColumnWidth(0, 24);
    sheet.setColumnWidth(1, 13);
    sheet.setColumnWidth(2, 10);
    sheet.setColumnWidth(3, 14);
    sheet.setColumnWidth(4, 18);
    sheet.setColumnWidth(5, 32);

    const headers = [
      'Conto', 'Data', 'Tipo', 'Importo (€)', 'Categoria', 'Note'
    ];
    for (int c = 0; c < headers.length; c++) {
      _set(sheet, c, 0, headers[c], style: _header());
    }

    final nameById = {for (final a in accounts) a.account.id: a.account.name};
    final df = DateFormat('dd/MM/yyyy');
    final nf = NumberFormat('#,##0.00', 'it_IT');
    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));

    for (int i = 0; i < sorted.length; i++) {
      final tx = sorted[i];
      final row = i + 1;
      final isIncome = tx.type == 'income';
      final alt = i.isOdd;

      _set(sheet, 0, row, nameById[tx.accountId] ?? tx.accountId,
          style: alt ? _altRow() : null);
      _set(sheet, 1, row, df.format(tx.date), style: alt ? _altRow() : null);
      _set(sheet, 2, row, isIncome ? 'Entrata' : 'Spesa',
          style: alt ? _altRow() : null);
      _set(sheet, 3, row, nf.format(tx.amount),
          style: alt
              ? (isIncome ? _incomeAlt() : _expenseAlt())
              : (isIncome ? _income() : _expense()));
      _set(sheet, 4, row, tx.category, style: alt ? _altRow() : null);
      _set(sheet, 5, row, tx.note ?? '', style: alt ? _altRow() : null);
    }
  }

  static void _buildSommarioSheet(
    Sheet sheet,
    List<AccountWithBalance> accounts,
    List<TransactionEntry> transactions,
  ) {
    sheet.setColumnWidth(0, 28);
    sheet.setColumnWidth(1, 16);
    sheet.setColumnWidth(2, 16);

    final nf = NumberFormat('#,##0.00', 'it_IT');
    int row = 0;

    // ── Saldo totale ──
    _set(sheet, 0, row, 'SALDO TOTALE', style: _header());
    _set(sheet, 1, row, '', style: _header());
    row++;
    final totalBalance = accounts.fold(0.0, (s, a) => s + a.balance);
    _set(sheet, 0, row, 'Tutti i conti');
    _set(sheet, 1, row, nf.format(totalBalance));
    row += 2;

    // ── Spese per categoria ──
    _set(sheet, 0, row, 'SPESE PER CATEGORIA', style: _subHeader());
    _set(sheet, 1, row, 'Importo (€)', style: _subHeader());
    row++;

    final byCategory = <String, double>{};
    for (final tx in transactions) {
      if (tx.type == 'expense') {
        byCategory[tx.category] = (byCategory[tx.category] ?? 0) + tx.amount;
      }
    }
    final sortedCats = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (int i = 0; i < sortedCats.length; i++) {
      final alt = i.isOdd ? _altRow() : null;
      _set(sheet, 0, row, sortedCats[i].key, style: alt);
      _set(sheet, 1, row, nf.format(sortedCats[i].value), style: alt);
      row++;
    }
    row++;

    // ── Totali mensili ──
    _set(sheet, 0, row, 'TOTALI MENSILI', style: _subHeader());
    _set(sheet, 1, row, 'Entrate (€)', style: _subHeader());
    _set(sheet, 2, row, 'Spese (€)', style: _subHeader());
    row++;

    final monthly =
        <({int year, int month}), ({double income, double expense})>{};
    for (final tx in transactions) {
      final key = (year: tx.date.year, month: tx.date.month);
      final cur = monthly[key] ?? (income: 0.0, expense: 0.0);
      monthly[key] = tx.type == 'income'
          ? (income: cur.income + tx.amount, expense: cur.expense)
          : (income: cur.income, expense: cur.expense + tx.amount);
    }
    final sortedMonths = monthly.entries.toList()
      ..sort((a, b) {
        final c = b.key.year.compareTo(a.key.year);
        return c != 0 ? c : b.key.month.compareTo(a.key.month);
      });

    for (int i = 0; i < sortedMonths.length; i++) {
      final e = sortedMonths[i];
      final label =
          '${e.key.year}-${e.key.month.toString().padLeft(2, '0')}';
      final alt = i.isOdd ? _altRow() : null;
      _set(sheet, 0, row, label, style: alt);
      _set(sheet, 1, row, nf.format(e.value.income), style: alt);
      _set(sheet, 2, row, nf.format(e.value.expense), style: alt);
      row++;
    }
  }

  // ── Template ───────────────────────────────────────────────────────────────

  static Future<File> generateTemplate() async {
    const fileName = 'Template_Conti.xlsx';
    final dir = await _getTemplateDir();
    final filePath = '$dir\\$fileName';

    final excel = Excel.createExcel();
    _buildIstruzioniSheet(excel['Istruzioni']);
    _buildContiTemplateSheet(excel['Conti']);
    _buildTransazioniTemplateSheet(excel['Transazioni']);
    if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');

    final bytes = excel.save();
    if (bytes == null) throw Exception('Impossibile generare il template');

    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file;
  }

  static void _buildIstruzioniSheet(Sheet sheet) {
    sheet.setColumnWidth(0, 70);

    final lines = [
      'GUIDA ALLA COMPILAZIONE DEL TEMPLATE',
      '',
      'Foglio CONTI:',
      '  - ID: lasciare VUOTO per creare un nuovo conto',
      '  - ID: inserire l\'ID esistente per aggiornare un conto già presente',
      '  - Nome: nome del conto (es. "Carta Credito", "Conto Corrente")',
      '  - Saldo Apertura: numero decimale positivo (es. 1000.50)',
      '',
      'Foglio TRANSAZIONI:',
      '  - Account ID: lasciare vuoto se si specifica il Nome Conto',
      '  - Nome Conto: nome esatto dal foglio Conti (se Account ID è vuoto)',
      '  - Data: formato YYYY-MM-DD (es. 2026-06-23)',
      '  - Tipo: "income" per entrate, "expense" per spese',
      '  - Importo: numero positivo (es. 100.50)',
      '  - Categoria: testo libero (es. "Alimentari", "Stipendio")',
      '  - Note: campo opzionale',
      '',
      'Una volta compilato, importa il file tramite il pulsante "Importa".',
    ];

    for (int i = 0; i < lines.length; i++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
      cell.value = TextCellValue(lines[i]);
      if (i == 0) cell.cellStyle = _header();
    }
  }

  static void _buildContiTemplateSheet(Sheet sheet) {
    sheet.setColumnWidth(0, 38);
    sheet.setColumnWidth(1, 26);
    sheet.setColumnWidth(2, 18);

    const headers = ['ID (vuoto = nuovo conto)', 'Nome', 'Saldo Apertura'];
    for (int c = 0; c < headers.length; c++) {
      _set(sheet, c, 0, headers[c], style: _header());
    }
    _set(sheet, 0, 1, '');
    _set(sheet, 1, 1, 'Conto Corrente');
    _set(sheet, 2, 1, '0');
    _set(sheet, 0, 2, '');
    _set(sheet, 1, 2, 'Carta di Credito');
    _set(sheet, 2, 2, '1500.00');
  }

  static void _buildTransazioniTemplateSheet(Sheet sheet) {
    sheet.setColumnWidth(0, 38);
    sheet.setColumnWidth(1, 24);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 10);
    sheet.setColumnWidth(4, 13);
    sheet.setColumnWidth(5, 18);
    sheet.setColumnWidth(6, 30);

    const headers = [
      'Account ID (opz.)', 'Nome Conto', 'Data (YYYY-MM-DD)',
      'Tipo', 'Importo', 'Categoria', 'Note'
    ];
    for (int c = 0; c < headers.length; c++) {
      _set(sheet, c, 0, headers[c], style: _header());
    }

    final r1 = ['', 'Conto Corrente', '2026-06-23', 'income', '2000', 'Stipendio', 'Stipendio giugno'];
    final r2 = ['', 'Carta di Credito', '2026-06-24', 'expense', '50.50', 'Alimentari', 'Spesa supermercato'];
    for (int c = 0; c < r1.length; c++) { _set(sheet, c, 1, r1[c]); }
    for (int c = 0; c < r2.length; c++) { _set(sheet, c, 2, r2[c]); }
  }

  // ── Import ─────────────────────────────────────────────────────────────────

  static Future<({
    List<Account> newAccounts,
    List<TransactionEntry> transactions,
    List<String> updatedAccountIds,
    String? error,
  })> importAccounts(
    File file,
    List<Account> existingAccounts,
  ) async {
    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      final contiSheet = excel.tables['Conti'];
      final txSheet = excel.tables['Transazioni'];

      if (contiSheet == null || txSheet == null) {
        return (
          newAccounts: <Account>[],
          transactions: <TransactionEntry>[],
          updatedAccountIds: <String>[],
          error: 'File non valido: fogli "Conti" e "Transazioni" non trovati',
        );
      }

      final (accountResult, accError) =
          _parseContiSheet(contiSheet, existingAccounts);
      if (accError != null) {
        return (
          newAccounts: <Account>[],
          transactions: <TransactionEntry>[],
          updatedAccountIds: <String>[],
          error: accError,
        );
      }

      final (txResult, txError) =
          _parseTransazioniSheet(txSheet, accountResult.accountMap);
      if (txError != null) {
        return (
          newAccounts: <Account>[],
          transactions: <TransactionEntry>[],
          updatedAccountIds: <String>[],
          error: txError,
        );
      }

      return (
        newAccounts: accountResult.newAccounts,
        transactions: txResult,
        updatedAccountIds: accountResult.updatedIds,
        error: null,
      );
    } catch (e) {
      return (
        newAccounts: <Account>[],
        transactions: <TransactionEntry>[],
        updatedAccountIds: <String>[],
        error: 'Errore lettura file: $e',
      );
    }
  }

  static (
    ({
      Map<String, String> accountMap,
      List<Account> newAccounts,
      List<String> updatedIds
    }),
    String?,
  ) _parseContiSheet(Sheet sheet, List<Account> existingAccounts) {
    final newAccounts = <Account>[];
    final updatedIds = <String>[];
    final accountMap = <String, String>{};
    final rows = sheet.rows;

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      final idCell = _cellStr(row, 0);
      final nameCell = _cellStr(row, 1);
      final balanceCell = _cellStr(row, 2);

      if (nameCell.isEmpty) continue;

      double balance;
      try {
        balance = double.parse(balanceCell.replaceAll(',', '.'));
      } catch (_) {
        return (
          (accountMap: <String, String>{}, newAccounts: <Account>[], updatedIds: <String>[]),
          'Riga ${i + 1} (Conti): Saldo Apertura non valido',
        );
      }

      final existingAcc = idCell.isNotEmpty
          ? existingAccounts.firstWhere(
              (a) => a.id == idCell,
              orElse: () => Account(
                  id: '', name: '', colorValue: 0, openingBalance: 0, createdAt: DateTime.now()),
            )
          : null;

      if (existingAcc != null && existingAcc.name.isNotEmpty) {
        updatedIds.add(existingAcc.id);
        accountMap[nameCell] = existingAcc.id;
      } else {
        final newId = _uuid.v4();
        newAccounts.add(Account(
          id: newId,
          name: nameCell,
          colorValue: 4294967295,
          openingBalance: balance,
          createdAt: DateTime.now(),
        ));
        accountMap[nameCell] = newId;
      }
    }

    return (
      (accountMap: accountMap, newAccounts: newAccounts, updatedIds: updatedIds),
      null,
    );
  }

  static (List<TransactionEntry>, String?) _parseTransazioniSheet(
    Sheet sheet,
    Map<String, String> accountMap,
  ) {
    final transactions = <TransactionEntry>[];
    final df = DateFormat('yyyy-MM-dd');
    final rows = sheet.rows;

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      final accountIdCell = _cellStr(row, 0);
      final accountNameCell = _cellStr(row, 1);
      final dateCell = _cellStr(row, 2);
      final typeCell = _cellStr(row, 3).toLowerCase();
      final amountCell = _cellStr(row, 4);
      final categoryCell = _cellStr(row, 5);
      final noteCell = _cellStr(row, 6);

      if (accountIdCell.isEmpty && accountNameCell.isEmpty) continue;
      if (dateCell.isEmpty) {
        return ([], 'Riga ${i + 1} (Transazioni): Data mancante');
      }
      if (!['income', 'expense'].contains(typeCell)) {
        return ([], 'Riga ${i + 1} (Transazioni): Tipo deve essere "income" o "expense"');
      }
      if (categoryCell.isEmpty) {
        return ([], 'Riga ${i + 1} (Transazioni): Categoria mancante');
      }

      DateTime date;
      try {
        date = df.parse(dateCell);
      } catch (_) {
        return ([], 'Riga ${i + 1} (Transazioni): Data non valida (YYYY-MM-DD)');
      }

      double amount;
      try {
        amount = double.parse(amountCell.replaceAll(',', '.'));
        if (amount <= 0) {
          return ([], 'Riga ${i + 1} (Transazioni): Importo deve essere positivo');
        }
      } catch (_) {
        return ([], 'Riga ${i + 1} (Transazioni): Importo non valido');
      }

      final accountId = accountIdCell.isNotEmpty
          ? accountIdCell
          : (accountMap[accountNameCell] ?? accountNameCell);

      transactions.add(TransactionEntry(
        id: _uuid.v4(),
        accountId: accountId,
        amount: amount,
        type: typeCell,
        category: categoryCell,
        date: date,
        note: noteCell.isEmpty ? null : noteCell,
        createdAt: DateTime.now(),
      ));
    }

    return (transactions, null);
  }
}
