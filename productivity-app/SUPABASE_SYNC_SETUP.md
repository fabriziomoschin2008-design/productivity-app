# Supabase Sync Setup

Lo stato del progetto ora e' questo:

- l'app inizializza Supabase
- il sync worker invia i record locali verso le tabelle remote
- i record locali sono pronti per avere ownership per utente con `user_id`
- il worker, quando trova una sessione attiva, assegna il tuo `user_id` ai record locali che ancora non ce l'hanno
- i payload inviati a Supabase includono `user_id`
- le impostazioni utente come la chiave `TMDb` possono essere syncate tramite la tabella `user_settings`

## Cosa fa il punto 2

Il punto 2 e' la soluzione sicura:

1. ogni riga ha un proprietario (`user_id`)
2. Supabase permette lettura e scrittura solo al proprietario
3. anche se un altro utente si registra, non vede i tuoi dati

La regola chiave e':

```sql
auth.uid() = user_id
```

## SQL da eseguire su Supabase

Apri il SQL Editor di Supabase ed esegui questo script.

```sql
alter table public.accounts add column if not exists user_id uuid;
alter table public.transaction_entries add column if not exists user_id uuid;
alter table public.goals add column if not exists user_id uuid;
alter table public.todo_lists add column if not exists user_id uuid;
alter table public.todo_items add column if not exists user_id uuid;
alter table public.note_folders add column if not exists user_id uuid;
alter table public.notes add column if not exists user_id uuid;
alter table public.habits add column if not exists user_id uuid;
alter table public.habit_logs add column if not exists user_id uuid;
alter table public.calendar_events add column if not exists user_id uuid;
alter table public.note_goals add column if not exists user_id uuid;
alter table public.trackers add column if not exists user_id uuid;
alter table public.movies add column if not exists user_id uuid;
alter table public.tv_series add column if not exists user_id uuid;
alter table public.games add column if not exists user_id uuid;

create table if not exists public.user_settings (
  user_id uuid not null references auth.users(id) on delete cascade,
  setting_key text not null,
  value text,
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz,
  primary key (user_id, setting_key)
);
```

Se nelle tabelle remote hai gia' dati tuoi e sei l'unico utente, puoi fare un backfill una sola volta sostituendo `<YOUR_USER_UUID>` con il tuo id utente Supabase:

```sql
update public.accounts set user_id = '<YOUR_USER_UUID>' where user_id is null;
update public.transaction_entries set user_id = '<YOUR_USER_UUID>' where user_id is null;
update public.goals set user_id = '<YOUR_USER_UUID>' where user_id is null;
update public.todo_lists set user_id = '<YOUR_USER_UUID>' where user_id is null;
update public.todo_items set user_id = '<YOUR_USER_UUID>' where user_id is null;
update public.note_folders set user_id = '<YOUR_USER_UUID>' where user_id is null;
update public.notes set user_id = '<YOUR_USER_UUID>' where user_id is null;
update public.habits set user_id = '<YOUR_USER_UUID>' where user_id is null;
update public.habit_logs set user_id = '<YOUR_USER_UUID>' where user_id is null;
update public.calendar_events set user_id = '<YOUR_USER_UUID>' where user_id is null;
update public.note_goals set user_id = '<YOUR_USER_UUID>' where user_id is null;
update public.trackers set user_id = '<YOUR_USER_UUID>' where user_id is null;
update public.movies set user_id = '<YOUR_USER_UUID>' where user_id is null;
update public.tv_series set user_id = '<YOUR_USER_UUID>' where user_id is null;
update public.games set user_id = '<YOUR_USER_UUID>' where user_id is null;
```

Poi rendi obbligatorio `user_id`:

```sql
alter table public.accounts alter column user_id set not null;
alter table public.transaction_entries alter column user_id set not null;
alter table public.goals alter column user_id set not null;
alter table public.todo_lists alter column user_id set not null;
alter table public.todo_items alter column user_id set not null;
alter table public.note_folders alter column user_id set not null;
alter table public.notes alter column user_id set not null;
alter table public.habits alter column user_id set not null;
alter table public.habit_logs alter column user_id set not null;
alter table public.calendar_events alter column user_id set not null;
alter table public.note_goals alter column user_id set not null;
alter table public.trackers alter column user_id set not null;
alter table public.movies alter column user_id set not null;
alter table public.tv_series alter column user_id set not null;
alter table public.games alter column user_id set not null;
```

## Policy RLS consigliate

Per ogni tabella:

```sql
alter table public.accounts enable row level security;

drop policy if exists "accounts_select_own" on public.accounts;
drop policy if exists "accounts_insert_own" on public.accounts;
drop policy if exists "accounts_update_own" on public.accounts;
drop policy if exists "accounts_delete_own" on public.accounts;

create policy "accounts_select_own"
on public.accounts
for select
to authenticated
using (auth.uid() = user_id);

create policy "accounts_insert_own"
on public.accounts
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "accounts_update_own"
on public.accounts
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "accounts_delete_own"
on public.accounts
for delete
to authenticated
using (auth.uid() = user_id);
```

Replica lo stesso schema per:

- `transaction_entries`
- `goals`
- `todo_lists`
- `todo_items`
- `note_folders`
- `notes`
- `habits`
- `habit_logs`
- `calendar_events`
- `note_goals`
- `trackers`
- `movies`
- `tv_series`
- `games`
- `user_settings`

## Come trovare il tuo user id

Puoi recuperarlo in uno di questi modi:

- da Supabase Dashboard -> Authentication -> Users
- facendo login nell'app e leggendo `Supabase.instance.client.auth.currentUser?.id`

## Cosa manca dopo questo step

Dopo aver eseguito lo script su Supabase, il test reale da fare e':

1. login con il tuo utente
2. creare o modificare un record nell'app
3. verificare che compaia nella tabella remota con il tuo `user_id`
4. aprire la stessa app su un'altra piattaforma e verificare il sync

Al momento il codice e' pronto per inviare dati in modo sicuro, ma serve ancora applicare le modifiche SQL lato Supabase per sbloccare definitivamente gli `insert/upsert`.

## Sync TMDb key

Per la chiave TMDb il codice usa ora questa priorita':

1. tabella Supabase `user_settings`
2. fallback ai metadata utente Supabase se la tabella non esiste ancora

Quindi:

- se esegui lo script SQL sopra, la chiave TMDb si sincronizzera' tramite `user_settings`
- se non lo esegui ancora, l'app continuera' a usare il fallback precedente
