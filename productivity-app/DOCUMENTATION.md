# Documentazione — Productivity App

## Indice
1. [Panoramica](#panoramica)
2. [Stack tecnologico](#stack-tecnologico)
3. [Struttura del progetto](#struttura-del-progetto)
4. [Database (Drift / SQLite)](#database)
5. [State management (Riverpod)](#state-management)
6. [Sistema di log](#sistema-di-log)
7. [Navigazione (GoRouter)](#navigazione)
8. [Tema e stili](#tema-e-stili)
9. [Modulo Finance — dettaglio](#modulo-finance)
10. [Come aggiungere un nuovo modulo](#come-aggiungere-un-nuovo-modulo)

---

## Panoramica

App desktop per Windows (target futuro: Android) che raccoglie in un'unica interfaccia quattro aree di produttività personale:

| Modulo | Stato | Descrizione |
|--------|-------|-------------|
| Finance | ✅ Completo | Conti, movimenti, grafici, obiettivi |
| To-do | ✅ Completo | Task, liste, scadenze con ore specifiche e priorità |
| Note | ✅ Completo | Cartelle, note con editor rich text Quill, grafici e tabelle embed |
| Calendario | ✅ Completo | Habit tracker (abitudini e log) + calendario eventi |

La filosofia è **offline-first**: SQLite è la fonte di verità. Nessun backend, nessun sync cloud (rimandato).

---

## Stack tecnologico

| Package | Versione | Ruolo |
|---------|----------|-------|
| `flutter_riverpod` | ^2.6.1 | State management |
| `drift` + `drift_flutter` | ^2.23.0 | ORM SQLite |
| `go_router` | ^14.6.2 | Navigazione dichiarativa |
| `fl_chart` | ^0.70.2 | Grafici (Pie, Bar, Line) |
| `intl` | ^0.20.1 | Locale it_IT, date/currency |
| `uuid` | ^4.5.1 | ID univoci client-side |
| `google_fonts` | ^6.2.1 | Font Inter |

**Perché Riverpod invece di Provider o Bloc?**  
Riverpod non richiede un `BuildContext` per leggere i provider, elimina il problema dello scope, e il `StateNotifier` permette di separare nettamente logica e UI senza boilerplate eccessivo.

**Perché Drift?**  
Drift genera codice type-safe dal schema Dart — niente stringhe SQL libere, niente cast manuali. Gli stream reattivi (`watch*`) permettono alla UI di aggiornarsi automaticamente senza polling.

---

## Struttura del progetto

```
lib/
  core/
    constants/
      categories.dart       # Liste categorie spese/entrate
    services/
      logger_service.dart   # Logging su file e terminale
    theme/
      app_colors.dart       # Palette colori centralizzata
      app_text_styles.dart  # Stili tipografici (Inter)
      app_theme.dart        # Material 3 ThemeData
    utils/
      currency_formatter.dart  # formatCurrency() → "€ 1.234,56"
      date_formatter.dart      # formatDateShort/Medium/MonthYear
  data/
    local/
      database.dart         # Schema Drift + metodi CRUD
      database.g.dart       # GENERATO da build_runner — non toccare
  features/
    finance/
      models/
        account_with_balance.dart  # DTO: Account + saldo calcolato
      providers/
        finance_providers.dart     # databaseProvider, financeProvider, goalsProvider
      screens/
        finance_screen.dart        # Layout a due colonne
      state/
        finance_notifier.dart      # StateNotifier per conti/movimenti
        finance_state.dart         # Stato immutabile finance
        goals_notifier.dart        # StateNotifier per obiettivi
        goals_state.dart           # Stato immutabile goals
      widgets/
        accounts_panel.dart        # Sidebar sinistra conti
        add_account_dialog.dart    # Dialog crea conto
        edit_account_dialog.dart   # Dialog modifica conto
        add_transaction_dialog.dart # Dialog aggiungi movimento
        add_goal_dialog.dart       # Dialog crea obiettivo
        goals_panel.dart           # Vista obiettivi con progress bar
        transactions_panel.dart    # Pannello destra (movimenti/grafici/obiettivi)
        charts_panel.dart          # Grafici Pie/Bar/Line
    notes/     # Fase 3
    calendar/  # Fase 4
    todo/      # Fase 2
  shared/
    navigation/
      router.dart         # GoRouter con ShellRoute
    widgets/
      nav_sidebar.dart    # Barra laterale di navigazione 68px
  main.dart
```

---

## Database

**File:** `lib/data/local/database.dart`  
**Generato:** `lib/data/local/database.g.dart`

Ogni volta che si modifica `database.dart`, rigenerare con:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Schema attuale (versione 6)

#### Tabella `accounts`
```
id            TEXT    PRIMARY KEY  (UUID v4, clientDefault)
name          TEXT    NOT NULL
color_value   INTEGER NOT NULL     (ARGB32 del colore)
opening_balance REAL  DEFAULT 0.0  (saldo di partenza)
created_at    DATETIME DEFAULT NOW
```

#### Tabella `transaction_entries`
```
id          TEXT     PRIMARY KEY (UUID v4)
account_id  TEXT     NOT NULL    (riferimento a accounts.id)
amount      REAL     NOT NULL
type        TEXT     NOT NULL    ('income' | 'expense')
category    TEXT     NOT NULL    (stringa libera)
date        DATETIME NOT NULL
note        TEXT     NULLABLE
created_at  DATETIME DEFAULT NOW
```

#### Tabella `goals`
```
id             TEXT     PRIMARY KEY (UUID v4)
name           TEXT     NOT NULL
target_amount  REAL     NOT NULL
current_amount REAL     DEFAULT 0.0
deadline       DATETIME NULLABLE
note           TEXT     NULLABLE
is_completed   BOOLEAN  DEFAULT false
created_at     DATETIME DEFAULT NOW
```

#### Tabella `todo_lists` (Fase 2)
```
id          TEXT     PRIMARY KEY (UUID v4)
name        TEXT     NOT NULL
color_value INTEGER  NOT NULL
created_at  DATETIME DEFAULT NOW
```

#### Tabella `todo_items` (Fase 2)
```
id           TEXT     PRIMARY KEY (UUID v4)
list_id      TEXT     NULLABLE    (riferimento a todo_lists.id)
title        TEXT     NOT NULL
note         TEXT     NULLABLE
is_done      BOOLEAN  DEFAULT false
priority     INTEGER  DEFAULT 0   (0: Bassa, 1: Media, 2: Alta)
due_date     DATETIME NULLABLE
has_due_time BOOLEAN  DEFAULT false (se la scadenza include l'ora specifica o scade a fine giornata)
completed_at DATETIME NULLABLE
created_at   DATETIME DEFAULT NOW
```

#### Tabella `note_folders` (Fase 3)
```
id          TEXT     PRIMARY KEY (UUID v4)
name        TEXT     NOT NULL
created_at  DATETIME DEFAULT NOW
```

#### Tabella `notes` (Fase 3)
```
id          TEXT     PRIMARY KEY (UUID v4)
title       TEXT     DEFAULT ''
content     TEXT     DEFAULT ''   (Delta JSON)
folder_id   TEXT     NULLABLE    (riferimento a note_folders.id)
is_pinned   BOOLEAN  DEFAULT false
created_at  DATETIME DEFAULT NOW
updated_at  DATETIME DEFAULT NOW
```

#### Tabella `habits` (Fase 4)
```
id         TEXT     PRIMARY KEY (UUID v4)
name       TEXT     NOT NULL
category   TEXT     DEFAULT ''   ('Mattina' | 'Pomeriggio' | 'Sera')
sort_order INTEGER  DEFAULT 0
created_at DATETIME DEFAULT NOW
```

#### Tabella `habit_logs` (Fase 4)
```
habit_id   TEXT     PRIMARY KEY
date       DATETIME PRIMARY KEY  (mezzanotte del giorno registrato)
status     TEXT     NOT NULL     ('done' | 'skip' | 'na')
```

#### Tabella `calendar_events` (Fase 4)
```
id          TEXT     PRIMARY KEY (UUID v4)
title       TEXT     NOT NULL
note        TEXT     NULLABLE
start_date  DATETIME NOT NULL
end_date    DATETIME NULLABLE
all_day     BOOLEAN  DEFAULT true
color_value INTEGER  DEFAULT 0xFF6C63FF
created_at  DATETIME DEFAULT NOW
```

### Migrazione

Il database usa versioning esplicito. Quando si aggiunge una tabella o una colonna, le migrazioni vengono descritte all'interno di `MigrationStrategy` in `database.dart`.
La cronologia delle versioni è la seguente:
- **v1**: Base (conti e transazioni)
- **v2**: Aggiunta tabella `goals` (obiettivi di risparmio)
- **v3**: Aggiunta tabelle `todo_lists` e `todo_items`
- **v4**: Aggiunta colonna `has_due_time` in `todo_items`
- **v5**: Aggiunta tabelle `note_folders` e `notes` per il modulo Note
- **v6**: Aggiunta tabelle `habits`, `habit_logs` e `calendar_events` per il Calendario/Habit tracker

### Metodi CRUD disponibili

I metodi CRUD sono definiti all'interno di `AppDatabase` ed espongono stream e future per ogni entità del sistema (watchAccounts, watchTransactions, watchGoals, watchTodoLists, watchTodoItems, watchFolders, watchNotes, watchHabits, watchHabitLogs, watchCalendarEvents, ecc.).


---

## State management

### Pattern base

```
AppDatabase (Drift)
    ↓ Stream
StateNotifier (FinanceNotifier / GoalsNotifier)
    ↓ state =
FinanceState / GoalsState (immutabile)
    ↓ ref.watch(provider)
ConsumerWidget → rebuild automatico
```

### Provider

`lib/features/finance/providers/finance_providers.dart`:

```dart
// Singleton del database, chiuso al dispose
final databaseProvider = Provider<AppDatabase>(...);

// Gestisce conti e movimenti
final financeProvider = StateNotifierProvider<FinanceNotifier, FinanceState>(...);

// Gestisce obiettivi
final goalsProvider = StateNotifierProvider<GoalsNotifier, GoalsState>(...);
```

**Regola:** tutti i provider condividono la stessa istanza di `AppDatabase` tramite `databaseProvider`. Non istanziare mai `AppDatabase()` direttamente nei widget.

### FinanceState (immutabile)

```dart
class FinanceState {
  final List<AccountWithBalance> accounts; // conti con saldi pre-calcolati
  final String? selectedAccountId;
  final List<TransactionEntry> transactions; // del conto selezionato
  final bool isLoading;

  double get totalBalance => ...;            // somma di tutti i saldi
  AccountWithBalance? get selectedAccount => ...;
}
```

`FinanceState.copyWith()` usa il pattern `_Sentinel` per distinguere `null` intenzionale da "non cambiato" nel campo `selectedAccountId`.

### FinanceNotifier — flusso interno

1. **Costruttore** → chiama `_subscribeToAccounts()`
2. Ogni emissione dello stream `watchAccounts()`:
   - Calcola i saldi con `_computeBalances()` (one-shot per ogni conto)
   - Determina `selectedAccountId` (con fallback al primo se il conto selezionato è stato eliminato)
   - Chiama `_subscribeToTransactions(selectedId)`
3. Ogni emissione dello stream `watchTransactionsByAccount()`:
   - Aggiorna le transazioni nello state
   - Chiama `_refreshBalances()` per ricalcolare i saldi (le tx cambiano il saldo effettivo)

**Nota:** il saldo non è salvato nel DB. Viene calcolato in memoria come `openingBalance + Σ income - Σ expense`. Questo lo rende sempre consistente.

### Come usare i provider nei widget

```dart
// Leggere lo stato (rebuild automatico)
final state = ref.watch(financeProvider);

// Chiamare un'azione (non causa rebuild)
ref.read(financeProvider.notifier).addAccount(...);

// Widget che non si rebuilda mai (performante)
class MyWidget extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) { ... }
}

// Widget con stato locale + accesso a Riverpod
class MyWidget extends ConsumerStatefulWidget {
  // usa ConsumerState<MyWidget>, ref disponibile come this.ref
  Widget build(BuildContext context) { ... }  // NO WidgetRef qui!
}
```

---

## Sistema di log

**File:** `lib/core/services/logger_service.dart`

Singleton inizializzato in `main()`:

```dart
AppLogger.instance.init();   // crea il file di log
AppLogger.instance.info('App avviata');
```

### Output

Ogni log appare:
1. **Terminale VS Code** (in tempo reale via `debugPrint`) — visibile durante `flutter run`
2. **File** su disco: `%LOCALAPPDATA%\ProductivityApp\logs\YYYY-MM-DD.log`

### Formato

```
[2026-06-18 14:32:01] [INFO   ] App avviata
[2026-06-18 14:32:05] [INFO   ] Conto aggiunto: Conto corrente (saldo iniziale: €1000.0)
[2026-06-18 14:33:10] [INFO   ] Movimento aggiunto: expense "Cibo" €25.5 [conto: abc-123]
[2026-06-18 14:34:00] [WARNING] ...
[2026-06-18 14:35:00] [ERROR  ] ...
```

### Dove vengono loggati gli eventi

| Evento | Livello |
|--------|---------|
| App avviata | INFO |
| Conto aggiunto / modificato / eliminato | INFO |
| Movimento aggiunto / eliminato | INFO |
| Obiettivo aggiunto / aggiornato / completato / eliminato | INFO |
| Logger non inizializzabile | ERROR |

### Aggiungere un log

```dart
import '../../../core/services/logger_service.dart';

AppLogger.instance.info('Messaggio informativo');
AppLogger.instance.warning('Avviso');
AppLogger.instance.error('Errore critico');
```

---

## Navigazione

**File:** `lib/shared/navigation/router.dart`

Usa GoRouter con `ShellRoute`: la sidebar è persistente mentre il contenuto cambia.

```
ShellRoute (_AppShell)
  ├── NavSidebar (68px, fisso)
  ├── VerticalDivider
  └── child (Expanded)
       ├── /finance  → FinanceScreen
       ├── /todo     → placeholder
       ├── /notes    → placeholder
       └── /calendar → placeholder
```

### Aggiungere una nuova route

In `router.dart`, aggiungere al `GoRoute` array dentro la `ShellRoute`:
```dart
GoRoute(
  path: '/todo',
  builder: (_, __) => const TodoScreen(),
),
```

E nella `NavSidebar`, aggiungere un nuovo `NavItem` con il path corrispondente.

---

## Tema e stili

### Regola fondamentale

**Mai** usare `Color(0xFF...)` o `TextStyle(...)` hardcoded nei widget. Sempre usare:
- `AppColors.*` per i colori
- `AppTextStyles.*` per la tipografia
- `formatCurrency()` / `formatDateMedium()` per i valori formattati

### AppColors (`lib/core/theme/app_colors.dart`)

| Costante | Hex | Uso |
|----------|-----|-----|
| `primary` | `#1E3A5F` | Blu scuro principale |
| `accent` | `#D4821A` | Arancio per azioni e accenti |
| `surface` | `#FFFFFF` | Sfondo pannelli |
| `surfaceElevated` | `#F9FAFB` | Sfondo elevato (input, tag) |
| `background` | `#F4F5F7` | Sfondo app |
| `income` | `#1A7A45` | Verde entrate |
| `expense` | `#C0392B` | Rosso spese |
| `textPrimary` | `#0D1B2A` | Testo principale |
| `textSecondary` | `#6B7A8D` | Testo secondario |
| `textDisabled` | `#B0BAC6` | Testo disabilitato/hint |
| `border` | `#D0D5DD` | Bordi input e card |
| `divider` | `#E2E5EA` | Linee divisorie |
| `navBackground` | `#0D1B2A` | Sfondo sidebar nav |
| `accountColors` | lista 8 | Colori pallino conto |

### AppTextStyles (`lib/core/theme/app_text_styles.dart`)

| Costante | Dimensione | Uso |
|----------|------------|-----|
| `displayAmount` | 28px bold | Importo grande (saldo totale) |
| `headingSection` | 11px, tracking alto | Label sezione (es. "CONTI") |
| `headingCard` | 15px bold | Titolo card o dialog |
| `bodyRegular` | 14px | Testo standard |
| `bodySmall` | 12px | Testo secondario, note |
| `amountMedium` | 16px tabular | Importo nelle transazioni |
| `amountSmall` | 13px tabular | Saldo piccolo nelle tile |
| `label` | 11px, tracking | Label campo, data, hint |

Il `tabular` nelle varianti `amount*` garantisce l'allineamento verticale dei numeri nelle liste.

---

## Modulo Finance

### Layout

```
┌─────────────────────────────────────────────────────────────┐
│ NavSidebar (68px) │ AccountsPanel (272px) │ TransactionsPanel│
│                   │                       │ (expanded)       │
└─────────────────────────────────────────────────────────────┘
```

**AccountsPanel:** lista conti con saldo, menu Modifica/Elimina, totale in basso.  
**TransactionsPanel:** tre view intercambiabili — Movimenti | Grafici | Obiettivi.

### Funzionalità implementate

#### Conti
- Creare un conto (nome, saldo iniziale, colore)
- Modificare un conto (tutti i campi)
- Eliminare un conto (con conferma — cancella anche i movimenti associati)
- Selezione conto: click sulla tile → aggiorna il pannello destro

#### Movimenti
- Aggiungere spesa o entrata (importo, categoria, data, nota)
- Categoria: selezione da lista predefinita o testo libero ("Personalizzata")
- Eliminare un movimento
- Calcolo saldo: `saldo_iniziale + Σ entrate - Σ spese` (real-time via stream)

#### Categorie predefinite
- **Spese:** Cibo, Trasporti, Casa, Salute, Svago, Abbigliamento, Abbonamenti, Istruzione, Altro
- **Entrate:** Stipendio, Freelance, Regalo, Rimborso, Investimenti, Altro
- **Personalizzata:** l'utente digita il nome della categoria

#### Grafici (ChartsPanel)
- **Torta:** spese raggruppate per categoria (% al hover)
- **Barre:** entrate vs spese per gli ultimi 6 mesi
- **Linea:** andamento del saldo nel tempo

#### Obiettivi (GoalsPanel)
- Creare un obiettivo (nome, importo target, importo attuale, scadenza, nota)
- Aggiornare il progresso (imposta il nuovo importo risparmiato)
- Segnare come completato
- Eliminare un obiettivo
- Progress bar visiva con percentuale
- Indicatore verde automatico quando `currentAmount >= targetAmount`

### Flusso dati completo

```
Utente compila dialog
        ↓
ref.read(financeProvider.notifier).addAccount(...)
        ↓
AppLogger.instance.info(...)  ← log su file + terminale
        ↓
AppDatabase.upsertAccount(companion)
        ↓
SQLite — riga inserita/aggiornata
        ↓
watchAccounts() stream emette nuova lista
        ↓
FinanceNotifier._subscribeToAccounts() callback
        ↓
_computeBalances() → AccountWithBalance[]
        ↓
state = state.copyWith(accounts: ...)
        ↓
ConsumerWidget rebuild → UI aggiornata
```

## Modulo Note

### Layout e Funzionalità

- **Cartelle e Note:** Organizzazione gerarchica. A sinistra la lista delle cartelle e delle note non categorizzate; al centro l'elenco delle note filtrate; a destra il pannello dell'editor.
- **Editor Rich Text:** Basato su `flutter_quill` ^11.5.1. Supporta la formattazione standard del testo (grassetto, corsivo, liste, intestazioni) e blocchi embed personalizzati.
- **Auto-salvataggio:** Il testo viene salvato automaticamente in locale su database SQLite a 800ms di inattività dall'ultimo carattere digitato, per prevenire perdite di dati.
- **Funzionalità Pin e Ricerca:** Possibilità di pinnare in alto le note principali e ricercare istantaneamente all'interno dei testi.

### Custom Embeds (Grafici e Tabelle)

Il modulo Note supporta l'inserimento di grafici dinamici (a barre, a torta, a linee) e tabelle interattive direttamente all'interno del flusso del testo.
- **Implementazione:** I widget custom sono implementati in `chart_embed.dart` e `table_embed.dart`.
- **Risoluzione dell'offset absolute (`_withOffset`):**
  - **Strategia primaria:** Ricerca l'offset nel document tree tramite `Node.documentOffset` solo se il nodo è effettivamente attaccato (`embedNode.parent != null`).
  - **Strategia di fallback (Robust Delta-walk):** Se il nodo è "detached" a causa di rebuild asincroni dell'editor rich-text, percorre l'intero Delta del documento decodificando l'ID del blocco custom. Supporta sia la chiave diretta che la chiave nidificata in `custom` (in formato Map, stringa JSON o `CustomBlockEmbed`).
- **Focus Safety:** Prima di modificare o eliminare un embed custom, viene rimosso il focus globale della tastiera via `FocusManager.instance.primaryFocus?.unfocus()`. Inoltre, la dialog di configurazione viene aperta tramite `useRootNavigator: true` sopra il subtree del QuillEditor. Questo evita crash del cursore causati da selezioni non allineate nell'albero di render di Quill.

---

## Come aggiungere un nuovo modulo

Esempio: aggiungere il modulo **To-do**.

### 1. Aggiungere la tabella al database

In `database.dart`:
```dart
class TodoItems extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get title => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Accounts, TransactionEntries, Goals, TodoItems])
class AppDatabase extends _$AppDatabase {
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(goals);
      if (from < 3) await m.createTable(todoItems);
    },
  );
  // ... metodi CRUD per todo
}
```

Poi rigenerare: `dart run build_runner build --delete-conflicting-outputs`

### 2. Creare state e notifier

```
lib/features/todo/
  state/
    todo_state.dart      # TodoState { List<TodoItem> items }
    todo_notifier.dart   # TodoNotifier extends StateNotifier<TodoState>
  providers/
    todo_providers.dart  # todoProvider = StateNotifierProvider<...>
```

### 3. Creare screen e widget

```
lib/features/todo/
  screens/
    todo_screen.dart
  widgets/
    todo_list.dart
    add_todo_dialog.dart
```

### 4. Collegare la route

In `router.dart`:
```dart
GoRoute(
  path: '/todo',
  builder: (_, __) => const TodoScreen(),
),
```

In `nav_sidebar.dart`, aggiornare la lista `_items` con il path `/todo`.

### 5. Verificare

```bash
flutter analyze   # deve restituire "No issues found"
flutter test      # se ci sono test
```

---

## Convenzioni di commit

Prima di ogni commit:
```bash
flutter analyze   # nessun errore
# Build opzionale per verificare la build Windows
flutter build windows --release
```

Formato messaggi: descrittivo, in italiano o inglese, senza prefissi tipo "fix:" o "feat:" se non già stabiliti nel progetto.
