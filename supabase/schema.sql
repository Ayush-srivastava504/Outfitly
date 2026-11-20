-- Outfitly Community — Supabase schema
-- Run once in Supabase Dashboard → SQL Editor (or `supabase db push` with the CLI).
-- Every table has Row Level Security: users can only change their own rows.

-- ───────────────────────── Profiles ─────────────────────────
create table if not exists public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  username     text not null unique check (username ~ '^[a-z0-9_]{3,24}$'),
  display_name text not null check (char_length(display_name) between 1 and 40),
  bio          text check (char_length(bio) <= 160),
  is_public    boolean not null default true,
  created_at   timestamptz not null default now()
);

-- ───────────────────────── Posts (shared items / outfits) ─────────────────────────
create table if not exists public.posts (
  id          uuid primary key default gen_random_uuid(),
  owner       uuid not null references public.profiles (id) on delete cascade,
  kind        text not null check (kind in ('item', 'outfit')),
  local_ref   text not null,                       -- local item/outfit id, prevents double-sharing
  title       text not null check (char_length(title) between 1 and 80),
  caption     text check (char_length(caption) <= 300),
  category    text,
  color_name  text,
  image_paths text[] not null check (array_length(image_paths, 1) between 1 and 4),
  like_count  integer not null default 0,
  view_count  integer not null default 0,
  hidden      boolean not null default false,      -- set automatically after 3 reports
  created_at  timestamptz not null default now(),
  unique (owner, kind, local_ref)
);
create index if not exists posts_feed_idx on public.posts (created_at desc) where not hidden;
create index if not exists posts_owner_idx on public.posts (owner, created_at desc);

-- ───────────────────────── Likes ─────────────────────────
create table if not exists public.likes (
  post_id    uuid not null references public.posts (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create or replace function public.bump_like_count() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' then
    update posts set like_count = like_count + 1 where id = new.post_id;
  else
    update posts set like_count = greatest(like_count - 1, 0) where id = old.post_id;
  end if;
  return null;
end $$;
drop trigger if exists likes_count on public.likes;
create trigger likes_count after insert or delete on public.likes
  for each row execute function public.bump_like_count();

-- ───────────────────────── Views (analytics) ─────────────────────────
-- One view per user per post per day; owners' own views don't count.
create table if not exists public.post_views (
  post_id uuid not null references public.posts (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  day     date not null default current_date,
  primary key (post_id, user_id, day)
);

create or replace function public.record_view(p_post uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  if exists (select 1 from posts where id = p_post and owner <> auth.uid()) then
    insert into post_views (post_id, user_id) values (p_post, auth.uid()) on conflict do nothing;
    if found then
      update posts set view_count = view_count + 1 where id = p_post;
    end if;
  end if;
end $$;

-- Owner analytics: totals + per-post stats for the signed-in user.
create or replace function public.my_stats()
returns table (posts integer, likes integer, views integer, likes_7d integer, views_7d integer)
language sql security definer set search_path = public stable as $$
  select
    (select count(*)::int from posts where owner = auth.uid()),
    (select coalesce(sum(like_count), 0)::int from posts where owner = auth.uid()),
    (select coalesce(sum(view_count), 0)::int from posts where owner = auth.uid()),
    (select count(*)::int from likes l join posts p on p.id = l.post_id
       where p.owner = auth.uid() and l.created_at > now() - interval '7 days'),
    (select count(*)::int from post_views v join posts p on p.id = v.post_id
       where p.owner = auth.uid() and v.day > current_date - 7);
$$;

-- ───────────────────────── Safety: reports & blocks ─────────────────────────
create table if not exists public.reports (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references public.posts (id) on delete cascade,
  reporter   uuid not null references public.profiles (id) on delete cascade,
  reason     text not null check (reason in ('spam', 'nudity', 'harassment', 'hate', 'other')),
  details    text check (char_length(details) <= 300),
  created_at timestamptz not null default now(),
  unique (post_id, reporter)
);

create or replace function public.auto_hide_reported() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if (select count(*) from reports where post_id = new.post_id) >= 3 then
    update posts set hidden = true where id = new.post_id;
  end if;
  return null;
end $$;
drop trigger if exists reports_autohide on public.reports;
create trigger reports_autohide after insert on public.reports
  for each row execute function public.auto_hide_reported();

create table if not exists public.blocks (
  blocker    uuid not null references public.profiles (id) on delete cascade,
  blocked    uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker, blocked),
  check (blocker <> blocked)
);

-- ───────────────────────── Account deletion (required by Google Play) ─────────────────────────
-- The app deletes the user's storage files first (Storage API), then calls this.
create or replace function public.delete_my_account() returns void
language plpgsql security definer set search_path = public, auth as $$
begin
  delete from auth.users where id = auth.uid();   -- cascades to profiles, posts, likes, views, reports, blocks
end $$;
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

-- ───────────────────────── Row Level Security ─────────────────────────
alter table public.profiles   enable row level security;
alter table public.posts      enable row level security;
alter table public.likes      enable row level security;
alter table public.post_views enable row level security;
alter table public.reports    enable row level security;
alter table public.blocks     enable row level security;

drop policy if exists "profiles readable" on public.profiles;
create policy "profiles readable" on public.profiles for select to authenticated
  using (is_public or id = auth.uid());
drop policy if exists "own profile insert" on public.profiles;
create policy "own profile insert" on public.profiles for insert to authenticated with check (id = auth.uid());
drop policy if exists "own profile update" on public.profiles;
create policy "own profile update" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists "feed visible posts" on public.posts;
create policy "feed visible posts" on public.posts for select to authenticated using (
  owner = auth.uid()
  or (
    not hidden
    and exists (select 1 from profiles p where p.id = owner and p.is_public)
    and not exists (select 1 from blocks b where b.blocker = auth.uid() and b.blocked = owner)
    and not exists (select 1 from blocks b where b.blocker = owner and b.blocked = auth.uid())
  )
);
drop policy if exists "own posts insert" on public.posts;
create policy "own posts insert" on public.posts for insert to authenticated
  with check (owner = auth.uid() and like_count = 0 and view_count = 0 and not hidden);
drop policy if exists "own posts delete" on public.posts;
create policy "own posts delete" on public.posts for delete to authenticated using (owner = auth.uid());
-- No UPDATE policy: counters/hidden are only changed by the security-definer functions above.

drop policy if exists "likes readable" on public.likes;
create policy "likes readable" on public.likes for select to authenticated using (true);
drop policy if exists "own likes" on public.likes;
create policy "own likes" on public.likes for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "own unlike" on public.likes;
create policy "own unlike" on public.likes for delete to authenticated using (user_id = auth.uid());

drop policy if exists "own reports" on public.reports;
create policy "own reports" on public.reports for insert to authenticated with check (reporter = auth.uid());
drop policy if exists "see own reports" on public.reports;
create policy "see own reports" on public.reports for select to authenticated using (reporter = auth.uid());

drop policy if exists "own blocks" on public.blocks;
create policy "own blocks" on public.blocks for all to authenticated using (blocker = auth.uid()) with check (blocker = auth.uid());

-- post_views: no direct access; only via record_view().

-- ───────────────────────── Storage ─────────────────────────
-- Public-read bucket; users may only write inside a folder named after their user id.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('wardrobe', 'wardrobe', true, 2097152, array['image/jpeg', 'image/png'])
on conflict (id) do nothing;

drop policy if exists "wardrobe own upload" on storage.objects;
create policy "wardrobe own upload" on storage.objects for insert to authenticated
  with check (bucket_id = 'wardrobe' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "wardrobe own delete" on storage.objects;
create policy "wardrobe own delete" on storage.objects for delete to authenticated
  using (bucket_id = 'wardrobe' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "wardrobe own list" on storage.objects;
create policy "wardrobe own list" on storage.objects for select to authenticated
  using (bucket_id = 'wardrobe' and (storage.foldername(name))[1] = auth.uid()::text);

-- ───────────────────────── Grants ─────────────────────────
-- Newer Supabase projects don't auto-expose tables to the API roles; grant only what the app needs.
-- RLS policies above still decide which ROWS each user may touch.
revoke all on public.profiles, public.posts, public.likes, public.post_views, public.reports, public.blocks from anon;
grant usage on schema public to authenticated;
grant select, insert, update on public.profiles to authenticated;
grant select, insert, delete on public.posts to authenticated;
grant select, insert, delete on public.likes to authenticated;
grant select, insert on public.reports to authenticated;
grant select, insert, delete on public.blocks to authenticated;
-- post_views: no direct grant (only via record_view()).
revoke all on function public.record_view(uuid), public.my_stats() from public, anon;
grant execute on function public.record_view(uuid), public.my_stats() to authenticated;
