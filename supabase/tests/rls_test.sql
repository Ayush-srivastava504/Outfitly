-- Outfitly Community schema test. Runs entirely inside a transaction that is ROLLED BACK:
-- nothing persists. Usage: psql "<conn>" -v ON_ERROR_STOP=1 -f supabase/tests/rls_test.sql
\set QUIET on
begin;

-- Fake users (auth schema) — rolled back at the end.
insert into auth.users (id, instance_id, aud, role, email) values
  ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'alice@test.invalid'),
  ('00000000-0000-0000-0000-0000000000b2', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'bob@test.invalid'),
  ('00000000-0000-0000-0000-0000000000c3', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'carol@test.invalid'),
  ('00000000-0000-0000-0000-0000000000d4', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'dave@test.invalid');

create or replace function pg_temp.as_user(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
end $$;
create or replace function pg_temp.check(ok boolean, label text) returns void language plpgsql as $$
begin
  if not ok then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end $$;

-- Alice creates profile + post.
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
insert into profiles (id, username, display_name) values (auth.uid(), 'alice', 'Alice');
insert into posts (owner, kind, local_ref, title, image_paths)
  values (auth.uid(), 'item', 'local-1', 'Navy shirt', array['00000000-0000-0000-0000-0000000000a1/p1.jpg']);

-- Alice cannot create a profile/post for someone else, nor fake counters.
do $$ begin
  begin
    insert into profiles (id, username, display_name) values ('00000000-0000-0000-0000-0000000000b2', 'fakebob', 'x');
    raise exception 'FAIL: inserted profile for another user';
  exception when insufficient_privilege then null; end;
  begin
    insert into posts (owner, kind, local_ref, title, image_paths, like_count) values (auth.uid(), 'item', 'x', 'x', array['a'], 999);
    raise exception 'FAIL: inserted fake like_count';
  exception when insufficient_privilege then null; end;
end $$;
select pg_temp.check(true, 'cannot impersonate or fake counters');

-- Bob sees Alice's post, likes it once, views it.
reset role;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000b2');
insert into profiles (id, username, display_name) values (auth.uid(), 'bob', 'Bob');
select pg_temp.check((select count(*) from posts) = 1, 'bob sees alice''s public post');
insert into likes (post_id, user_id) select id, auth.uid() from posts;
select record_view(id) from posts;
select record_view(id) from posts;  -- same day: counted once
select pg_temp.check((select like_count from posts) = 1, 'like counter incremented by trigger');
select pg_temp.check((select view_count from posts) = 1, 'view counted once per user per day');
do $$ begin
  begin
    update posts set like_count = 1000;
    if (select like_count from posts) = 1000 then raise exception 'FAIL: bob changed counters'; end if;
  exception when insufficient_privilege then null; end;
end $$;
select pg_temp.check((select like_count from posts) = 1, 'no direct counter tampering');

-- Alice's analytics.
reset role;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select record_view(id) from posts;  -- owner views don't count
select pg_temp.check((select likes from my_stats()) = 1 and (select views from my_stats()) = 1 and (select posts from my_stats()) = 1, 'my_stats totals');
select pg_temp.check((select likes_7d from my_stats()) = 1, 'my_stats 7-day likes');

-- Unlike.
reset role;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000b2');
delete from likes where user_id = auth.uid();
select pg_temp.check((select like_count from posts) = 0, 'unlike decrements counter');

-- Blocking: Bob blocks Alice → Bob no longer sees her posts.
insert into blocks (blocker, blocked) values (auth.uid(), '00000000-0000-0000-0000-0000000000a1');
select pg_temp.check((select count(*) from posts) = 0, 'blocked user''s posts hidden');
delete from blocks where blocker = auth.uid();

-- Three reports auto-hide a post.
insert into reports (post_id, reporter, reason) select id, auth.uid(), 'spam' from posts;
reset role;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000c3');
insert into profiles (id, username, display_name) values (auth.uid(), 'carol', 'Carol');
insert into reports (post_id, reporter, reason) select id, auth.uid(), 'spam' from posts;
reset role;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000d4');
insert into profiles (id, username, display_name) values (auth.uid(), 'dave', 'Dave');
select pg_temp.check((select count(*) from posts) = 1, 'post visible after 2 reports');
insert into reports (post_id, reporter, reason) select id, auth.uid(), 'nudity' from posts;
select pg_temp.check((select count(*) from posts) = 0, 'post auto-hidden after 3 reports');
reset role;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select pg_temp.check((select count(*) from posts) = 1, 'owner still sees own hidden post');

-- Private profile: Alice goes private → others can't see her posts.
update profiles set is_public = false where id = auth.uid();
reset role;
update posts set hidden = false;  -- admin un-hide to isolate the privacy check
select pg_temp.as_user('00000000-0000-0000-0000-0000000000b2');
select pg_temp.check((select count(*) from posts) = 0, 'private profile posts hidden from others');

-- Account deletion cascades everything.
reset role;
select pg_temp.as_user('00000000-0000-0000-0000-0000000000a1');
select delete_my_account();
reset role;
select pg_temp.check(not exists (select 1 from profiles where id = '00000000-0000-0000-0000-0000000000a1'), 'account deletion removes profile');
select pg_temp.check(not exists (select 1 from posts where owner = '00000000-0000-0000-0000-0000000000a1'), 'account deletion removes posts');

rollback;
\echo ALL RLS TESTS PASSED (transaction rolled back)
