# Competitor Analysis — Cubby (Productivity App)
*Aggiornato: giugno 2026 | Stack: Flutter/Windows → Android futuro*

---

## 1. Executive Summary

Cubby è rara nel panorama: unisce **finanze personali + note + calendario + to-do + tracker + intrattenimento** in un'unica app offline-first. Nessun competitor diretto copre tutti e sei i moduli; i rivali dominanti sono verticali (YNAB solo finanze, Obsidian solo note, Todoist solo task). Il vantaggio competitivo reale è l'integrazione e la privacy (dati locali). I gap critici sono tre: **ricorrenza** (task e transazioni ricorrenti), **sincronizzazione cloud/mobile** e **subtask**. Con dark mode + web già avviati, le prime 5 quick win (ricorrenza, subtask, budget mensile, tag, reminder custom) richiedono effort medio-basso e chiudono i gap più citati dagli utenti dei competitor. Nessun altro player combina finanze + note + abitudini in un'unica app desktop offline-first.

---

## 2. Funzionalità attuali di Cubby

### 2.1 Finanze ✅ Completo
| Feature | Stato |
|---|---|
| Conti bancari (CRUD, colore, saldo iniziale) | ✅ Completo |
| Transazioni (income/expense, categorie, note) | ✅ Completo |
| Grafici (pie spese, bar entrate/uscite, line saldo) | ✅ Completo |
| Obiettivi finanziari (target, progresso, scadenza) | ✅ Completo |
| Notifiche obiettivi (3gg, 1gg, scaduto) | ✅ Completo |
| Export Excel (stili, grafici embedded come immagini) | ✅ Completo |
| Import Excel (conti + transazioni) | ✅ Completo |
| Categorie predefinite | ✅ Completo |
| Budget mensile per categoria | ❌ Mancante |
| Transazioni ricorrenti | ❌ Mancante |
| Bank sync (Open Banking) | ❌ Mancante |
| Conversione valuta | ❌ Mancante |

### 2.2 Note ✅ Completo
| Feature | Stato |
|---|---|
| Editor rich text (flutter_quill) | ✅ Completo |
| Cartelle organizzazione | ✅ Completo |
| Pin nota | ✅ Completo |
| Ricerca (titolo + contenuto) | ✅ Completo |
| Allegati file locali | ✅ Completo |
| Embed grafici inline (fl_chart custom) | ✅ Completo |
| Embed tabelle editable | ✅ Completo |
| Link tra note | ✅ Completo |
| Obiettivi nelle note (NoteGoals) | ✅ Completo |
| Tag / etichette | ❌ Mancante |
| Templates di nota | ❌ Mancante |
| Export PDF/Word | ❌ Mancante |
| Web clipper | ❌ Mancante |
| Database view (stile Notion) | ❌ Mancante |

### 2.3 Calendario + Habit Tracker ✅ Completo
| Feature | Stato |
|---|---|
| Abitudini (CRUD, categorie mattina/pomeriggio/sera) | ✅ Completo |
| Vista giornaliera abitudini (slot 24h) | ✅ Completo |
| Vista settimanale abitudini | ✅ Completo |
| Vista mensile / heatmap | ✅ Completo |
| Log abitudini (done/skip/na) | ✅ Completo |
| Completion rate (escluso na) | ✅ Completo |
| Notifiche abitudini (20:00) | ✅ Completo |
| Calendario eventi (CRUD, all-day, timed, colore) | ✅ Completo |
| Notifiche eventi (30 min prima) | ✅ Completo |
| Viste mese/settimana/giorno per eventi | 🟡 Parziale (solo lista) |
| Abitudini ricorrenti (frequenza custom, non quotidiana) | ❌ Mancante |
| Sync Google/Apple Calendar | ❌ Mancante |
| Time blocking / day planner | ❌ Mancante |
| Streak tracking | ❌ Mancante |
| Reminder abitudine custom | ❌ Mancante |

### 2.4 To-Do ✅ Completo
| Feature | Stato |
|---|---|
| Liste task personalizzate (nome, colore) | ✅ Completo |
| Task (titolo, nota, priorità, scadenza) | ✅ Completo |
| Ora specifica (hasDueTime) | ✅ Completo |
| Notifiche task (08:00 per task in scadenza) | ✅ Completo |
| Subtask | ❌ Mancante |
| Task ricorrenti | ❌ Mancante |
| Tag / etichette | ❌ Mancante |
| Input linguaggio naturale ("venerdì alle 9") | ❌ Mancante |
| Vista Kanban | ❌ Mancante |
| Filtri avanzati (per priorità, tag, data) | ❌ Mancante |
| Reminder custom per singolo task | ❌ Mancante |
| Dipendenze tra task | ❌ Mancante |

### 2.5 Tracker ✅ Completo
| Feature | Stato |
|---|---|
| Tracker con target, step, unità | ✅ Completo |
| Auto-increment giornaliero (mezzanotte) | ✅ Completo |
| Cicli completati | ✅ Completo |
| Colore personalizzato | ✅ Completo |
| Storico valori (grafici andamento) | ❌ Mancante |
| Import/export dati tracker | ❌ Mancante |

### 2.6 Intrattenimento ✅ Completo
| Feature | Stato |
|---|---|
| Film: ricerca TMDb, metadata, status, rating | ✅ Completo |
| Serie TV: stagioni watched, status auto | ✅ Completo |
| Giochi: obiettivi, status, rating | ✅ Completo |
| Dual language (it/en) | ✅ Completo |
| Integrazione IGDB per giochi | ❌ Mancante |

### 2.7 Cross-Feature
| Feature | Stato |
|---|---|
| Notifiche (local_notifier, Windows) | ✅ Completo |
| Logger eventi giornaliero | ✅ Completo |
| Error handler con snackbar | ✅ Completo |
| Offline-first (SQLite locale) | ✅ Completo |
| Dark mode | 🟡 In sviluppo |
| Web app | 🟡 In sviluppo |
| Mobile (Android/iOS) | ❌ Pianificato |
| Cloud sync | ❌ Pianificato (Supabase) |
| Collaborazione multi-utente | ❌ Mancante |
| AI assistant | ❌ Mancante |
| Widget OS (desktop/mobile) | ❌ Mancante |
| Import da altri app | ❌ Mancante |

---

## 3. Matrice Comparativa Competitor

> Legenda: ✅ presente | 🟡 parziale | ❌ assente | — non applicabile

### 3.1 Finanze
| Feature | **Cubby** | YNAB | Spendee | Monefy | Notion | ClickUp |
|---|---|---|---|---|---|---|
| Conti multipli | ✅ | ✅ | ✅ | ✅ | 🟡 | ❌ |
| Transazioni | ✅ | ✅ | ✅ | ✅ | 🟡 | ❌ |
| Categorie spese | ✅ | ✅ | ✅ | ✅ | 🟡 | ❌ |
| Grafici / report | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Obiettivi finanziari | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Import/Export Excel | ✅ | 🟡 | ❌ | ❌ | ✅ | ✅ |
| **Budget mensile per categoria** | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Transazioni ricorrenti** | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Bank sync (Open Banking)** | ❌ | ✅ | 🟡 | ❌ | ❌ | ❌ |
| **Gestione debiti/prestiti** | ❌ | ✅ | 🟡 | ❌ | ❌ | ❌ |
| **Suddivisione spese condivise** | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Export PDF report | ❌ | ✅ | ✅ | ❌ | ✅ | ✅ |

### 3.2 Note
| Feature | **Cubby** | Notion | Obsidian | Evernote | ClickUp | Anytype |
|---|---|---|---|---|---|---|
| Editor rich text | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Cartelle/spazi | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Allegati file | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Grafici inline | ✅ | ❌ | 🟡 | ❌ | ❌ | ❌ |
| Link tra note (backlink) | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Ricerca full-text | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Tag / etichette** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Templates** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Export PDF/Word** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Database view (tabelle relazionali)** | ❌ | ✅ | 🟡 | ❌ | ✅ | ✅ |
| **Web clipper** | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Graph view (grafo note)** | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ |
| **Versioning / cronologia** | ❌ | ✅ | 🟡 | ✅ | ✅ | ❌ |
| **AI writing assistant** | ❌ | ✅ | 🟡 | ✅ | ✅ | ❌ |
| Offline | ✅ | 🟡 | ✅ | 🟡 | 🟡 | ✅ |

### 3.3 Calendario + Abitudini
| Feature | **Cubby** | Google Cal | Fantastical | Sunsama | Akiflow | TickTick |
|---|---|---|---|---|---|---|
| Calendario eventi | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Notifiche eventi | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Vista giornaliera/settimanale/mensile | 🟡 | ✅ | ✅ | ✅ | ✅ | ✅ |
| Habit tracker | ✅ | ❌ | ❌ | 🟡 | ❌ | ✅ |
| Heatmap abitudini | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Sync Google/Apple Calendar** | ❌ | — | ✅ | ✅ | ✅ | ✅ |
| **Time blocking** | ❌ | 🟡 | ✅ | ✅ | ✅ | 🟡 |
| **Streak tracking** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Abitudini frequenza custom (3x/sett)** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Focus mode / Today view** | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ |
| **Reminder abitudine custom** | ❌ | — | — | 🟡 | — | ✅ |
| **Statistiche abitudini (trend)** | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ |
| **Integrazione calendari esterni** | ❌ | — | ✅ | ✅ | ✅ | ✅ |

### 3.4 To-Do
| Feature | **Cubby** | Todoist | TickTick | Things 3 | ClickUp | Akiflow |
|---|---|---|---|---|---|---|
| Liste task | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Priorità | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Scadenze | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Note su task | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Notifiche scadenza | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Subtask** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Task ricorrenti** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Tag / etichette** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Input linguaggio naturale** | ❌ | ✅ | ✅ | ✅ | 🟡 | ✅ |
| **Reminder custom per task** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Vista Kanban** | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ |
| **Pomodoro timer** | ❌ | ❌ | ✅ | ❌ | ❌ | 🟡 |
| **Filtri avanzati** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Dipendenze tra task** | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Today / Inbox view** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |

### 3.5 App ibride simili (all-in-one)
Nessun competitor combina **finanze + note + calendario + task + tracker + intrattenimento** in un'unica app. I più simili:

| App | Finance | Note | Calendar | Task | Habit | Offline | Note |
|---|---|---|---|---|---|---|---|
| **Cubby** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | **Unico con Finance+Entertainment** |
| Notion | ❌ | ✅ | 🟡 | ✅ | ❌ | 🟡 | Molto flessibile, richiede setup |
| ClickUp | ❌ | ✅ | ✅ | ✅ | ❌ | 🟡 | Orientato a team |
| Anytype | ❌ | ✅ | 🟡 | ✅ | ❌ | ✅ | Open source, blocchi |
| Capacities | ❌ | ✅ | 🟡 | ✅ | ✅ | 🟡 | Personal knowledge + abitudini |
| Akiflow | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | Task + time blocking |
| Sunsama | ❌ | ❌ | ✅ | ✅ | 🟡 | ❌ | Daily planner + integrations |
| Saga | ❌ | ✅ | ❌ | ✅ | ❌ | ✅ | Note + task, no finance |

---

## 4. Gap Analysis — Feature mancanti critiche

*Solo feature presenti in ≥2 competitor e assenti in Cubby*

### GAP-01: Task e transazioni ricorrenti
**Descrizione:** Possibilità di creare task (es. "pagare affitto il 1° del mese") e transazioni (es. "abbonamento Netflix -€14.99 ogni mese") che si rigenerano automaticamente secondo una regola (giornaliera, settimanale, mensile, annuale).
**Competitor:** Todoist, TickTick, Things 3, Akiflow (task); YNAB, Spendee, Monefy (transazioni)
**Perché interessa:** Riduce l'attrito quotidiano — l'utente non deve re-inserire manualmente le spese fisse. È la feature #1 richiesta dagli utenti di app di finanza personale.

### GAP-02: Subtask (task annidati)
**Descrizione:** Ogni task può avere uno o più sotto-task con proprio stato di completamento. Utile per scomporre progetti complessi.
**Competitor:** Todoist, TickTick, Things 3, ClickUp, Akiflow
**Perché interessa:** Permette di pianificare obiettivi multi-step senza creare liste separate. Già parzialmente risolto dagli "obiettivi" nei giochi — stessa logica applicabile ai task.

### GAP-03: Tag / etichette cross-modulo
**Descrizione:** Sistema di etichette testuali applicabili a note, task, e opzionalmente transazioni. Permette di filtrare contenuti per tema (es. #lavoro, #personale, #progetto-casa) indipendentemente dalla cartella/lista.
**Competitor:** Notion, Obsidian, Evernote, Todoist, TickTick, ClickUp
**Perché interessa:** Con più moduli, l'utente ha bisogno di un asse di organizzazione trasversale oltre alla gerarchia cartella/lista.

### GAP-04: Budget mensile per categoria
**Descrizione:** L'utente imposta un tetto di spesa mensile per categoria (es. Cibo €400, Svago €150). L'app mostra progresso e alert quando si avvicina al limite.
**Competitor:** YNAB, Spendee, Monefy
**Perché interessa:** È il salto da "registro spese" a "gestione finanziaria attiva". YNAB ha costruito un'intera azienda su questo concetto.

### GAP-05: Reminder custom per singolo task
**Descrizione:** Ogni task può avere uno o più reminder a orario specifico, indipendente dalla scadenza (es. task con scadenza venerdì, reminder mercoledì alle 10:00 per iniziare).
**Competitor:** Todoist, TickTick, Things 3, ClickUp, Akiflow
**Perché interessa:** Attualmente Cubby invia notifiche solo alle 08:00 per task in scadenza entro domani. Manca il controllo granulare.

### GAP-06: Vista Today / Focus view
**Descrizione:** Schermata dedicata "Oggi" che aggrega da tutti i moduli: task in scadenza oggi, eventi del giorno, abitudini di oggi, budget rimanente del giorno.
**Competitor:** TickTick, Things 3, Akiflow, Sunsama, Todoist
**Perché interessa:** È la killer feature delle app all-in-one — l'utente apre l'app e vede subito cosa fare. Cubby attualmente non ha una vista aggregata.

### GAP-07: Time blocking / Day planner
**Descrizione:** Drag & drop dei task sul calendario per allocare tempo specifico. Visualizzazione del giorno come "agenda bloccata" per lavorare su task prioritari.
**Competitor:** Akiflow, Sunsama, Fantastical
**Perché interessa:** Chiude il loop tra "lista cose da fare" e "quando le faccio" — problema #1 delle app to-do classiche.

### GAP-08: Streak tracking per abitudini
**Descrizione:** Contatore di giorni consecutivi in cui un'abitudine è stata completata. Visualizzazione del "streak" corrente e massimo storico.
**Competitor:** TickTick, Habitica, Loop Habit Tracker
**Perché interessa:** La gamification dello streak è uno dei meccanismi psicologici più efficaci per mantenere le abitudini (effetto "don't break the chain").

### GAP-09: Templates di nota / progetto
**Descrizione:** L'utente può salvare una struttura di nota come template e riutilizzarla. Es. template "Riunione settimanale" con sezioni Agenda, Note, Azioni.
**Competitor:** Notion, Obsidian, ClickUp, Evernote
**Perché interessa:** Riduce il tempo per creare note strutturate ricorrenti. Particolarmente utile per note legate a obiettivi o progetti.

### GAP-10: Statistiche e trend abitudini
**Descrizione:** Dashboard con statistiche sulle abitudini: streak attuale/massimo, completion rate per settimana/mese/anno, grafici trend.
**Competitor:** TickTick, Habitify, Bearable
**Perché interessa:** La heatmap mensile attuale è un buon inizio ma non basta — l'utente vuole sapere "miglioro nel tempo?". Un grafico trend completion rate sarebbe sufficiente.

### GAP-11: Input linguaggio naturale per task
**Descrizione:** Digitare "riunione con Mario giovedì prossimo alle 14" crea automaticamente un task con scadenza giovedì e orario 14:00.
**Competitor:** Todoist (NLP eccellente), TickTick, Things 3, Fantastical
**Perché interessa:** Riduce drasticamente il tempo di inserimento. Particolarmente utile su mobile.

### GAP-12: Export PDF delle note
**Descrizione:** Esportazione di una nota (o cartella) in PDF, mantenendo formattazione, tabelle e immagini.
**Competitor:** Notion, Evernote, Obsidian (via community plugins), ClickUp
**Perché interessa:** Permette di condividere contenuti con persone che non hanno l'app.

---

## 5. Roadmap Prioritizzata

*Impatto = valore percepito dall'utente finale | Effort = complessità implementativa dato lo stack attuale*

| # | Feature | Impatto | Effort | Note tecniche |
|---|---|---|---|---|
| **1** | 🌑 Dark mode | Alto | Basso | Già iniziato nel commit corrente. Solo `AppColors` + theme switch |
| **2** | 🔁 Task ricorrenti | Alto | Medio | Nuovo campo `recurrenceRule` in TodoItems. Logica: copia task a nuova data al completamento |
| **3** | 💰 Budget mensile per categoria | Alto | Medio | Nuova tabella `Budgets`. Widget progress bar già disponibile |
| **4** | ✅ Subtask | Alto | Medio | Campo `parentId` in TodoItems (self-reference). UI annidata |
| **5** | 🔔 Reminder custom per task | Alto | Basso | Campo `reminderAt DateTime?` in TodoItems. Usa NotificationScheduler esistente |
| **6** | 🏷️ Tag cross-modulo | Medio | Medio | Tabelle `Tags` + `NotesTags` + `TodoItemsTags`. Filtri per tag |
| **7** | 📅 Vista Today aggregata | Alto | Medio | Nuova route `/today` che aggrega da tutti i provider. Query multiple |
| **8** | 🔥 Streak abitudini | Medio | Basso | Calcolo dal DB (contare giorni consecutivi in HabitLogs). Solo read, no schema change |
| **9** | 📊 Statistiche abitudini (trend) | Medio | Basso | Line chart completion rate mensile. Usa fl_chart già disponibile |
| **10** | 💸 Transazioni ricorrenti | Alto | Medio | Nuovo campo `recurrenceRule` in TransactionEntries. Logica simile a task ricorrenti |
| **11** | 📄 Templates nota | Medio | Medio | Tabella `NoteTemplates`. UI per salvare/caricare template |
| **12** | 🔤 Input linguaggio naturale | Medio | Alto | Parsing regex per pattern comuni ("lunedì", "alle 15", "ogni settimana") |
| **13** | 📦 Export PDF note | Medio | Alto | Dipendenza esterna (`pdf` package). Serializzazione Quill Delta → PDF |
| **14** | 📋 Vista Kanban task | Medio | Medio | Aggiunta view type in TodoScreen. DragTarget su colonne status |
| **15** | ⏱️ Time blocking | Medio | Alto | Refactor completo del calendario con slot temporali trascinabili |

---

## 6. Top 5 Azioni Immediate

### 🥇 1 — Completa Dark Mode *(effort: basso, già avviato)*
Il commit `673bbed` ha già iniziato il lavoro. Completare `AppColors` con palette scura, aggiungere toggle nel header/settings. È la feature più visibile e richiesta dagli utenti desktop. Aumenta la retention notturna.

**File coinvolti:** `lib/core/theme/app_colors.dart`, `lib/core/theme/app_theme.dart`, `lib/core/services/app_settings.dart`

---

### 🥈 2 — Reminder custom per singolo task *(effort: basso, alto impatto)*
Aggiungere campo `reminderAt DateTime?` a `TodoItems`. Nella UI del task, aggiungere date/time picker opzionale "Ricordamelo il...". `NotificationScheduler` esiste già — basta aggiungere un caso.

**File coinvolti:** `lib/data/local/database.dart` (migration v12), `lib/features/todo/`, `lib/core/notifications/notification_scheduler.dart`

---

### 🥉 3 — Streak tracking abitudini *(effort: basso, zero schema change)*
Calcolare streak direttamente da `HabitLogs` esistente: contare i giorni consecutivi precedenti con status `done`. Mostrare "🔥 X giorni" sulla HabitCard. Nessuna migrazione DB richiesta.

**File coinvolti:** `lib/features/calendar/state/calendar_notifier.dart`, `lib/features/calendar/widgets/habits_side_panel.dart`

---

### 🏅 4 — Task ricorrenti *(effort: medio, impatto altissimo)*
Campo `recurrenceType` (none/daily/weekly/monthly/yearly) + `recurrenceInterval` in `TodoItems`. Quando un task ricorrente è completato, generare automaticamente il prossimo con la data calcolata. Schema migration v12 (o v13 se dopo reminder).

**File coinvolti:** `lib/data/local/database.dart`, `lib/features/todo/state/todo_notifier.dart`, `lib/features/todo/widgets/` (add/edit task dialog)

---

### 🏅 5 — Budget mensile per categoria *(effort: medio, differenziante vs finanza)*
Nuova tabella `Budgets` (category, monthlyLimit, month). Widget nella sezione finanze: progress bar per categoria con alert quando >80%. Chiude il gap più importante rispetto a YNAB/Spendee senza richiedere bank sync.

**File coinvolti:** `lib/data/local/database.dart` (migration), `lib/features/finance/` (nuovi widgets + stato)

---

## 7. Posizionamento competitivo finale

```
                        OFFLINE-FIRST
                              ▲
                          CUBBY ★
                      (Finance+Note+
                       Cal+Task+Track)
                              │
   SPECIALIZZATO ─────────────┼────────────── ALL-IN-ONE
   (1 modulo)                 │              (tutto ma cloud)
   YNAB, Todoist,             │          Notion, ClickUp,
   Obsidian                   │          Anytype, CapacitIES
                              │
                              ▼
                         CLOUD-ONLY
```

**Vantaggio difendibile di Cubby:** Unica app che unisce finanze personali con produttività in modalità completamente offline/locale. Dati privati, zero abbonamenti cloud, zero condivisione dei propri movimenti bancari.

**Rischio principale:** Il vantaggio "tutto in uno" si trasforma in svantaggio se le funzionalità di ogni modulo restano notevolmente inferiori ai verticali specializzati. La priorità deve essere raggiungere la feature parity sulle 5 funzionalità core (ricorrenza, subtask, budget, streak, reminder) prima di aggiungere nuovi moduli.
