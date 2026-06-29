# Supabase Sync Setup - CUBBY

## Stato attuale del sync

Il progetto e' gia' predisposto per:

- login/logout utente con Supabase
- push delle modifiche locali verso il cloud
- pull dei dati remoti sulle altre piattaforme
- ownership per utente tramite `user_id`
- sync della chiave `TMDb` tramite `user_settings` con fallback ai metadata utente

In pratica:

- senza login l'app resta locale
- con login il sync tra desktop, Android e Web puo' funzionare sugli oggetti supportati

## Regola di sicurezza

Ogni riga deve appartenere al suo proprietario:

```sql
auth.uid() = user_id
```

Questo evita che un altro utente autenticato possa leggere o modificare i tuoi dati.

## Tabelle coinvolte

Le tabelle syncate sono:

- `accounts`
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

## SQL base da eseguire

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

## Backfill iniziale

Se nel database remoto hai gia' dati creati prima dell'introduzione di `user_id`, fai un backfill una sola volta sostituendo `<YOUR_USER_UUID>`:

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

Poi puoi rendere `user_id` obbligatorio:

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

## RLS consigliata

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

Replica lo stesso schema per tutte le altre tabelle elencate sopra, inclusa `user_settings`.

## Test minimo da fare

1. login nell'app con il tuo account
2. crea o modifica un dato
3. verifica la presenza del record remoto con il tuo `user_id`
4. apri l'app su un'altra piattaforma autenticata
5. verifica che il dato venga scaricato correttamente

## Note pratiche

- la schermata `Impostazioni` dell'app ora centralizza account, sync manuale e chiave TMDb
- la chiave TMDb si sincronizza in cloud quando l'utente e' autenticato
- se non hai ancora creato `user_settings`, l'app usa il fallback sui metadata Supabase utente

