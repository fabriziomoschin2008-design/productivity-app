-- Point 2: secure per-user sync with Supabase
-- Backfill is already configured for user db2b2116-0e55-42d4-ad8a-8cd9ed188c14.

begin;

-- 1. Add user_id to every sync table
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

-- 2. Optional one-time backfill for existing remote rows
-- Only run if you already inserted rows remotely before enabling the secure model.
-- If your remote database is empty, you can skip this block.
update public.accounts set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;
update public.transaction_entries set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;
update public.goals set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;
update public.todo_lists set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;
update public.todo_items set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;
update public.note_folders set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;
update public.notes set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;
update public.habits set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;
update public.habit_logs set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;
update public.calendar_events set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;
update public.note_goals set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;
update public.trackers set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;
update public.movies set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;
update public.tv_series set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;
update public.games set user_id = 'db2b2116-0e55-42d4-ad8a-8cd9ed188c14' where user_id is null;

-- 3. Make ownership mandatory
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

-- 4. Helpful indexes
create index if not exists accounts_user_id_idx on public.accounts(user_id);
create index if not exists transaction_entries_user_id_idx on public.transaction_entries(user_id);
create index if not exists goals_user_id_idx on public.goals(user_id);
create index if not exists todo_lists_user_id_idx on public.todo_lists(user_id);
create index if not exists todo_items_user_id_idx on public.todo_items(user_id);
create index if not exists note_folders_user_id_idx on public.note_folders(user_id);
create index if not exists notes_user_id_idx on public.notes(user_id);
create index if not exists habits_user_id_idx on public.habits(user_id);
create index if not exists habit_logs_user_id_idx on public.habit_logs(user_id);
create index if not exists calendar_events_user_id_idx on public.calendar_events(user_id);
create index if not exists note_goals_user_id_idx on public.note_goals(user_id);
create index if not exists trackers_user_id_idx on public.trackers(user_id);
create index if not exists movies_user_id_idx on public.movies(user_id);
create index if not exists tv_series_user_id_idx on public.tv_series(user_id);
create index if not exists games_user_id_idx on public.games(user_id);

-- 5. Enable RLS
alter table public.accounts enable row level security;
alter table public.transaction_entries enable row level security;
alter table public.goals enable row level security;
alter table public.todo_lists enable row level security;
alter table public.todo_items enable row level security;
alter table public.note_folders enable row level security;
alter table public.notes enable row level security;
alter table public.habits enable row level security;
alter table public.habit_logs enable row level security;
alter table public.calendar_events enable row level security;
alter table public.note_goals enable row level security;
alter table public.trackers enable row level security;
alter table public.movies enable row level security;
alter table public.tv_series enable row level security;
alter table public.games enable row level security;

-- 6. Drop old broad policies if present
drop policy if exists "accounts_select_authenticated" on public.accounts;
drop policy if exists "accounts_insert_authenticated" on public.accounts;
drop policy if exists "accounts_update_authenticated" on public.accounts;
drop policy if exists "transaction_entries_select_authenticated" on public.transaction_entries;
drop policy if exists "transaction_entries_insert_authenticated" on public.transaction_entries;
drop policy if exists "transaction_entries_update_authenticated" on public.transaction_entries;
drop policy if exists "goals_select_authenticated" on public.goals;
drop policy if exists "goals_insert_authenticated" on public.goals;
drop policy if exists "goals_update_authenticated" on public.goals;
drop policy if exists "todo_lists_select_authenticated" on public.todo_lists;
drop policy if exists "todo_lists_insert_authenticated" on public.todo_lists;
drop policy if exists "todo_lists_update_authenticated" on public.todo_lists;
drop policy if exists "todo_items_select_authenticated" on public.todo_items;
drop policy if exists "todo_items_insert_authenticated" on public.todo_items;
drop policy if exists "todo_items_update_authenticated" on public.todo_items;
drop policy if exists "note_folders_select_authenticated" on public.note_folders;
drop policy if exists "note_folders_insert_authenticated" on public.note_folders;
drop policy if exists "note_folders_update_authenticated" on public.note_folders;
drop policy if exists "notes_select_authenticated" on public.notes;
drop policy if exists "notes_insert_authenticated" on public.notes;
drop policy if exists "notes_update_authenticated" on public.notes;
drop policy if exists "habits_select_authenticated" on public.habits;
drop policy if exists "habits_insert_authenticated" on public.habits;
drop policy if exists "habits_update_authenticated" on public.habits;
drop policy if exists "habit_logs_select_authenticated" on public.habit_logs;
drop policy if exists "habit_logs_insert_authenticated" on public.habit_logs;
drop policy if exists "habit_logs_update_authenticated" on public.habit_logs;
drop policy if exists "calendar_events_select_authenticated" on public.calendar_events;
drop policy if exists "calendar_events_insert_authenticated" on public.calendar_events;
drop policy if exists "calendar_events_update_authenticated" on public.calendar_events;
drop policy if exists "note_goals_select_authenticated" on public.note_goals;
drop policy if exists "note_goals_insert_authenticated" on public.note_goals;
drop policy if exists "note_goals_update_authenticated" on public.note_goals;
drop policy if exists "trackers_select_authenticated" on public.trackers;
drop policy if exists "trackers_insert_authenticated" on public.trackers;
drop policy if exists "trackers_update_authenticated" on public.trackers;
drop policy if exists "movies_select_authenticated" on public.movies;
drop policy if exists "movies_insert_authenticated" on public.movies;
drop policy if exists "movies_update_authenticated" on public.movies;
drop policy if exists "tv_series_select_authenticated" on public.tv_series;
drop policy if exists "tv_series_insert_authenticated" on public.tv_series;
drop policy if exists "tv_series_update_authenticated" on public.tv_series;
drop policy if exists "games_select_authenticated" on public.games;
drop policy if exists "games_insert_authenticated" on public.games;
drop policy if exists "games_update_authenticated" on public.games;

-- 7. Drop previous ownership policies if present
drop policy if exists "accounts_select_own" on public.accounts;
drop policy if exists "accounts_insert_own" on public.accounts;
drop policy if exists "accounts_update_own" on public.accounts;
drop policy if exists "accounts_delete_own" on public.accounts;

drop policy if exists "transaction_entries_select_own" on public.transaction_entries;
drop policy if exists "transaction_entries_insert_own" on public.transaction_entries;
drop policy if exists "transaction_entries_update_own" on public.transaction_entries;
drop policy if exists "transaction_entries_delete_own" on public.transaction_entries;

drop policy if exists "goals_select_own" on public.goals;
drop policy if exists "goals_insert_own" on public.goals;
drop policy if exists "goals_update_own" on public.goals;
drop policy if exists "goals_delete_own" on public.goals;

drop policy if exists "todo_lists_select_own" on public.todo_lists;
drop policy if exists "todo_lists_insert_own" on public.todo_lists;
drop policy if exists "todo_lists_update_own" on public.todo_lists;
drop policy if exists "todo_lists_delete_own" on public.todo_lists;

drop policy if exists "todo_items_select_own" on public.todo_items;
drop policy if exists "todo_items_insert_own" on public.todo_items;
drop policy if exists "todo_items_update_own" on public.todo_items;
drop policy if exists "todo_items_delete_own" on public.todo_items;

drop policy if exists "note_folders_select_own" on public.note_folders;
drop policy if exists "note_folders_insert_own" on public.note_folders;
drop policy if exists "note_folders_update_own" on public.note_folders;
drop policy if exists "note_folders_delete_own" on public.note_folders;

drop policy if exists "notes_select_own" on public.notes;
drop policy if exists "notes_insert_own" on public.notes;
drop policy if exists "notes_update_own" on public.notes;
drop policy if exists "notes_delete_own" on public.notes;

drop policy if exists "habits_select_own" on public.habits;
drop policy if exists "habits_insert_own" on public.habits;
drop policy if exists "habits_update_own" on public.habits;
drop policy if exists "habits_delete_own" on public.habits;

drop policy if exists "habit_logs_select_own" on public.habit_logs;
drop policy if exists "habit_logs_insert_own" on public.habit_logs;
drop policy if exists "habit_logs_update_own" on public.habit_logs;
drop policy if exists "habit_logs_delete_own" on public.habit_logs;

drop policy if exists "calendar_events_select_own" on public.calendar_events;
drop policy if exists "calendar_events_insert_own" on public.calendar_events;
drop policy if exists "calendar_events_update_own" on public.calendar_events;
drop policy if exists "calendar_events_delete_own" on public.calendar_events;

drop policy if exists "note_goals_select_own" on public.note_goals;
drop policy if exists "note_goals_insert_own" on public.note_goals;
drop policy if exists "note_goals_update_own" on public.note_goals;
drop policy if exists "note_goals_delete_own" on public.note_goals;

drop policy if exists "trackers_select_own" on public.trackers;
drop policy if exists "trackers_insert_own" on public.trackers;
drop policy if exists "trackers_update_own" on public.trackers;
drop policy if exists "trackers_delete_own" on public.trackers;

drop policy if exists "movies_select_own" on public.movies;
drop policy if exists "movies_insert_own" on public.movies;
drop policy if exists "movies_update_own" on public.movies;
drop policy if exists "movies_delete_own" on public.movies;

drop policy if exists "tv_series_select_own" on public.tv_series;
drop policy if exists "tv_series_insert_own" on public.tv_series;
drop policy if exists "tv_series_update_own" on public.tv_series;
drop policy if exists "tv_series_delete_own" on public.tv_series;

drop policy if exists "games_select_own" on public.games;
drop policy if exists "games_insert_own" on public.games;
drop policy if exists "games_update_own" on public.games;
drop policy if exists "games_delete_own" on public.games;

-- 8. Secure ownership policies
create policy "accounts_select_own" on public.accounts for select to authenticated using (auth.uid() = user_id);
create policy "accounts_insert_own" on public.accounts for insert to authenticated with check (auth.uid() = user_id);
create policy "accounts_update_own" on public.accounts for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "accounts_delete_own" on public.accounts for delete to authenticated using (auth.uid() = user_id);

create policy "transaction_entries_select_own" on public.transaction_entries for select to authenticated using (auth.uid() = user_id);
create policy "transaction_entries_insert_own" on public.transaction_entries for insert to authenticated with check (auth.uid() = user_id);
create policy "transaction_entries_update_own" on public.transaction_entries for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "transaction_entries_delete_own" on public.transaction_entries for delete to authenticated using (auth.uid() = user_id);

create policy "goals_select_own" on public.goals for select to authenticated using (auth.uid() = user_id);
create policy "goals_insert_own" on public.goals for insert to authenticated with check (auth.uid() = user_id);
create policy "goals_update_own" on public.goals for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "goals_delete_own" on public.goals for delete to authenticated using (auth.uid() = user_id);

create policy "todo_lists_select_own" on public.todo_lists for select to authenticated using (auth.uid() = user_id);
create policy "todo_lists_insert_own" on public.todo_lists for insert to authenticated with check (auth.uid() = user_id);
create policy "todo_lists_update_own" on public.todo_lists for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "todo_lists_delete_own" on public.todo_lists for delete to authenticated using (auth.uid() = user_id);

create policy "todo_items_select_own" on public.todo_items for select to authenticated using (auth.uid() = user_id);
create policy "todo_items_insert_own" on public.todo_items for insert to authenticated with check (auth.uid() = user_id);
create policy "todo_items_update_own" on public.todo_items for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "todo_items_delete_own" on public.todo_items for delete to authenticated using (auth.uid() = user_id);

create policy "note_folders_select_own" on public.note_folders for select to authenticated using (auth.uid() = user_id);
create policy "note_folders_insert_own" on public.note_folders for insert to authenticated with check (auth.uid() = user_id);
create policy "note_folders_update_own" on public.note_folders for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "note_folders_delete_own" on public.note_folders for delete to authenticated using (auth.uid() = user_id);

create policy "notes_select_own" on public.notes for select to authenticated using (auth.uid() = user_id);
create policy "notes_insert_own" on public.notes for insert to authenticated with check (auth.uid() = user_id);
create policy "notes_update_own" on public.notes for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "notes_delete_own" on public.notes for delete to authenticated using (auth.uid() = user_id);

create policy "habits_select_own" on public.habits for select to authenticated using (auth.uid() = user_id);
create policy "habits_insert_own" on public.habits for insert to authenticated with check (auth.uid() = user_id);
create policy "habits_update_own" on public.habits for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "habits_delete_own" on public.habits for delete to authenticated using (auth.uid() = user_id);

create policy "habit_logs_select_own" on public.habit_logs for select to authenticated using (auth.uid() = user_id);
create policy "habit_logs_insert_own" on public.habit_logs for insert to authenticated with check (auth.uid() = user_id);
create policy "habit_logs_update_own" on public.habit_logs for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "habit_logs_delete_own" on public.habit_logs for delete to authenticated using (auth.uid() = user_id);

create policy "calendar_events_select_own" on public.calendar_events for select to authenticated using (auth.uid() = user_id);
create policy "calendar_events_insert_own" on public.calendar_events for insert to authenticated with check (auth.uid() = user_id);
create policy "calendar_events_update_own" on public.calendar_events for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "calendar_events_delete_own" on public.calendar_events for delete to authenticated using (auth.uid() = user_id);

create policy "note_goals_select_own" on public.note_goals for select to authenticated using (auth.uid() = user_id);
create policy "note_goals_insert_own" on public.note_goals for insert to authenticated with check (auth.uid() = user_id);
create policy "note_goals_update_own" on public.note_goals for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "note_goals_delete_own" on public.note_goals for delete to authenticated using (auth.uid() = user_id);

create policy "trackers_select_own" on public.trackers for select to authenticated using (auth.uid() = user_id);
create policy "trackers_insert_own" on public.trackers for insert to authenticated with check (auth.uid() = user_id);
create policy "trackers_update_own" on public.trackers for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "trackers_delete_own" on public.trackers for delete to authenticated using (auth.uid() = user_id);

create policy "movies_select_own" on public.movies for select to authenticated using (auth.uid() = user_id);
create policy "movies_insert_own" on public.movies for insert to authenticated with check (auth.uid() = user_id);
create policy "movies_update_own" on public.movies for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "movies_delete_own" on public.movies for delete to authenticated using (auth.uid() = user_id);

create policy "tv_series_select_own" on public.tv_series for select to authenticated using (auth.uid() = user_id);
create policy "tv_series_insert_own" on public.tv_series for insert to authenticated with check (auth.uid() = user_id);
create policy "tv_series_update_own" on public.tv_series for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "tv_series_delete_own" on public.tv_series for delete to authenticated using (auth.uid() = user_id);

create policy "games_select_own" on public.games for select to authenticated using (auth.uid() = user_id);
create policy "games_insert_own" on public.games for insert to authenticated with check (auth.uid() = user_id);
create policy "games_update_own" on public.games for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "games_delete_own" on public.games for delete to authenticated using (auth.uid() = user_id);

commit;
