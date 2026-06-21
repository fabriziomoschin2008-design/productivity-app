# CLAUDE.md — Productivity App

App personale di produttività con 4 moduli: Finance, Note, Calendario, To-do.
Target: Windows desktop (build da Windows), poi Android in futuro.
Stack: Flutter 3.44+ / Dart 3.12+, Riverpod, Drift (SQLite), GoRouter.

## Comandi essenziali

```bash
# Generare il codice Drift dopo ogni modifica a database.dart
dart run build_runner build --delete-conflicting-outputs

# Analisi statica (deve restituire "No issues found")
flutter analyze

# Eseguire i test
flutter test

# Build Windows (da eseguire su macchina Windows)
flutter build windows --release
```

## Architettura

```
lib/
  core/
    constants/      # categorie finance, costanti globali
    theme/          # AppColors, AppTextStyles, AppTheme
    utils/          # currency_formatter, date_formatter
  data/
    local/
      database.dart   # schema Drift — modificare qui, poi build_runner
      database.g.dart # GENERATO — non toccare
  features/
    finance/
      providers/    # Riverpod providers
      screens/      # screen-level widget
      state/        # StateNotifier + FinanceState
      widgets/      # widget componibili
    notes/          # Fase 3
    calendar/       # Fase 4
    todo/           # Fase 2
  shared/
    navigation/     # router.dart (GoRouter + ShellRoute)
    widgets/        # NavSidebar e widget condivisi
  main.dart
```

## Convenzioni di codice

**State management:** Riverpod base (no codegen). Usare `StateNotifier` + `StateNotifierProvider`. Non usare `@riverpod` annotation.

**Database:** Drift con stream per dati reattivi. Le query che ritornano dati live usano `watch*`, quelle one-shot usano `get*`. Dopo ogni modifica allo schema, rigenerare con `build_runner`.

**Navigazione:** GoRouter con `ShellRoute`. La sidebar è in `_AppShell`, i contenuti nelle route figlie. Aggiungere nuove route solo in `router.dart`.

**Stili:** usare sempre `AppTextStyles.*` e `AppColors.*`. Non usare colori o stili hardcoded nei widget.

**Valuta:** sempre `formatCurrency()` da `core/utils/currency_formatter.dart`. Locale `it_IT`.

**ID:** UUID v4 generati client-side (`uuid` package). Drift `clientDefault`.

**Commenti:** solo se il "perché" non è ovvio. Niente docstring multi-riga.

## Dipendenze

| Package | Versione | Uso |
|---------|----------|-----|
| flutter_riverpod | ^2.6.1 | state management |
| drift | ^2.23.0 | ORM SQLite |
| drift_flutter | ^0.2.4 | driver SQLite desktop/mobile |
| go_router | ^14.6.2 | navigazione dichiarativa |
| fl_chart | ^0.70.2 | grafici (Pie, Bar, Line) |
| intl | ^0.20.1 | locale it_IT, date/currency |
| uuid | ^4.5.1 | generazione ID client-side |
| google_fonts | ^6.2.1 | font Inter |
| flutter_quill | ^11.5.1 | editor rich text (Note) |
| table_calendar | ^3.1.2 | calendario eventi (Calendario) |
| local_notifier | ^0.1.6 | notifiche Windows/macOS/Linux (no Android) |
| build_runner | ^2.4.13 | codegen (dev) |
| drift_dev | ^2.23.0 | codegen Drift (dev) |

## Workflow per fasi

1. Implementare una fase alla volta
2. `flutter analyze` deve essere pulito prima del commit
3. Commit con messaggio descrittivo
4. L'utente testa e approva prima di passare alla fase successiva

## Fasi

- [x] Fase 1 — Finance (conti, transazioni, grafici, obiettivi, modifica conto, categoria personalizzata)
- [x] Fase 2 — To-do (task, liste, scadenze, ora specifica)
- [x] Fase 3 — Note (cartelle, editor rich text appflowy_editor, ricerca, pin)
- [x] Fase 4 — Calendario (habit tracker: viste giornaliera/settimanale/mensile + calendario eventi)
- [x] Fase 5 — Notifiche (abitudini 20:00, obiettivi scadenza 3gg/1gg, eventi calendario 30min prima, task mattino 8:00)

## Note importanti

- Il sync con Supabase è rimandato — architettura offline-first con SQLite come fonte di verità
- `Value` di Drift: importare con `import 'package:drift/drift.dart' show Value;` nei file che usano i Companion
- Il `DropdownButtonFormField` usa `value:` (non `initialValue:`) per mantenere la reattività — suppress con `// ignore: deprecated_member_use`
- Locale `it_IT` inizializzato in `main()` con `initializeDateFormatting` prima di `runApp`
- **Schema attuale: versione 6** — v6: habits + habit_logs + calendar_events — v5: note_folders + notes — v1: base, v2: goals, v3: todo_lists+todo_items, v4: hasDueTime su todo_items
- **`hasDueTime` (TodoItems):** quando false, la scadenza è salvata come 23:59:59 del giorno (scade a mezzanotte); quando true, l'utente ha scelto un'ora specifica e il confronto "scaduto" usa `DateTime.now()` esatto
- **Architettura moduli:** To-do = task lavorative/scolastiche; Calendario (Fase 4) = habit tracker giornaliero (sessioni, abitudini, routine)
- **Notifiche (`local_notifier`):** `NotificationService.init()` in `main()`. Scheduling via `Timer` in memoria (non sopravvivono al riavvio → i listener Drift le ripianificano automaticamente all'avvio). `NotificationScheduler` è hookato nei listener stream di `GoalsNotifier`, `TodoNotifier`, `CalendarNotifier`. Android non supportato da `local_notifier` — richiederà `flutter_local_notifications` in futuro.
- Note editor: flutter_quill ^11.5.1 — content salvato come Quill Delta JSON (`toDelta().toJson()`). `QuillSimpleToolbar` fissa sopra all'editor. Auto-save 800ms dopo ultima modifica (solo `ChangeSource.local`). Per prevenire crash di caret paint (`RenderEmbedProxy.getOffsetForCaret`), viene invocato l'unfocus globale (`FocusManager.instance.primaryFocus?.unfocus()`) prima di eliminare o modificare embed custom (grafici, tabelle).
- Offset robusto nei custom embed: Il widget calcola l'offset assoluto (`_withOffset`) via albero dei nodi se `embedNode.parent != null`; in caso di rebuild asincroni, ripiega su un robusto Delta-walk che intercetta i nodi sia a livello root che all'interno della chiave `custom` (formati Mappa, Stringa JSON o `CustomBlockEmbed`).
- Logger: `AppLogger.instance` — init in `main()`, scrive su `%LOCALAPPDATA%\ProductivityApp\logs\YYYY-MM-DD.log` e sul terminale VS Code
- I parametri wildcard multipli nei callback usano `_` (non `__`) per evitare il lint `unnecessary_underscores`
