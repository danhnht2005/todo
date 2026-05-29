-- Access fix for shared lists and tasks.
-- Run in Supabase SQL editor.

alter table public.task_lists enable row level security;
alter table public.task_list_members enable row level security;
alter table public.tasks enable row level security;
alter table public.steps enable row level security;

create index if not exists task_list_members_user_id_idx
  on public.task_list_members (user_id);

create index if not exists task_list_members_list_user_idx
  on public.task_list_members (list_id, user_id);

create index if not exists tasks_list_id_idx
  on public.tasks (list_id);

create or replace function public.is_task_list_member(target_list_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.task_list_members tlm
    where tlm.list_id = target_list_id
      and tlm.user_id = auth.uid()
  );
$$;

create or replace function public.is_task_list_owner(target_list_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.task_lists tl
    where tl.id = target_list_id
      and tl.user_id = auth.uid()
  );
$$;

create or replace function public.can_access_task_list(target_list_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select public.is_task_list_owner(target_list_id)
    or public.is_task_list_member(target_list_id);
$$;

create or replace function public.get_shared_task_lists()
returns setof public.task_lists
language sql
security definer
set search_path = public
as $$
  select tl.*
  from public.task_lists tl
  inner join public.task_list_members tlm
    on tlm.list_id = tl.id
  where tlm.user_id = auth.uid()
    and tl.user_id <> auth.uid()
  order by tl.created_at asc;
$$;

grant execute on function public.get_shared_task_lists()
to authenticated;

drop policy if exists "task_lists_select_owned_or_shared" on public.task_lists;
create policy "task_lists_select_owned_or_shared"
on public.task_lists for select
using (
  user_id = auth.uid()
  or public.is_task_list_member(id)
);

drop policy if exists "task_list_members_select_owner_or_self" on public.task_list_members;
create policy "task_list_members_select_owner_or_self"
on public.task_list_members for select
using (
  user_id = auth.uid()
  or public.is_task_list_owner(list_id)
);

drop policy if exists "tasks_select_owned_or_shared_list" on public.tasks;
create policy "tasks_select_owned_or_shared_list"
on public.tasks for select
using (
  user_id = auth.uid()
  or (list_id is not null and public.can_access_task_list(list_id))
);

drop policy if exists "tasks_insert_owned_accessible_list" on public.tasks;
create policy "tasks_insert_owned_accessible_list"
on public.tasks for insert
with check (
  user_id = auth.uid()
  and (list_id is null or public.can_access_task_list(list_id))
);

drop policy if exists "tasks_update_owned_or_shared_list" on public.tasks;
create policy "tasks_update_owned_or_shared_list"
on public.tasks for update
using (
  user_id = auth.uid()
  or (list_id is not null and public.can_access_task_list(list_id))
)
with check (
  user_id = auth.uid()
  or (list_id is not null and public.can_access_task_list(list_id))
);

drop policy if exists "tasks_delete_owned_or_shared_list" on public.tasks;
create policy "tasks_delete_owned_or_shared_list"
on public.tasks for delete
using (
  user_id = auth.uid()
  or (list_id is not null and public.can_access_task_list(list_id))
);

drop policy if exists "steps_select_accessible_task" on public.steps;
create policy "steps_select_accessible_task"
on public.steps for select
using (
  exists (
    select 1
    from public.tasks t
    where t.id = task_id
      and (
        t.user_id = auth.uid()
        or (t.list_id is not null and public.can_access_task_list(t.list_id))
      )
  )
);

drop policy if exists "steps_insert_accessible_task" on public.steps;
create policy "steps_insert_accessible_task"
on public.steps for insert
with check (
  exists (
    select 1
    from public.tasks t
    where t.id = task_id
      and (
        t.user_id = auth.uid()
        or (t.list_id is not null and public.can_access_task_list(t.list_id))
      )
  )
);

drop policy if exists "steps_update_accessible_task" on public.steps;
create policy "steps_update_accessible_task"
on public.steps for update
using (
  exists (
    select 1
    from public.tasks t
    where t.id = task_id
      and (
        t.user_id = auth.uid()
        or (t.list_id is not null and public.can_access_task_list(t.list_id))
      )
  )
);

drop policy if exists "steps_delete_accessible_task" on public.steps;
create policy "steps_delete_accessible_task"
on public.steps for delete
using (
  exists (
    select 1
    from public.tasks t
    where t.id = task_id
      and (
        t.user_id = auth.uid()
        or (t.list_id is not null and public.can_access_task_list(t.list_id))
      )
  )
);
