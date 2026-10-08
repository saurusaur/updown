-- ===========================================================================
-- 업다운 팬클럽 — Supabase 스키마
-- Supabase 대시보드 > SQL Editor 에 통째로 붙여넣고 실행하면 됩니다.
-- 여러 번 실행해도 안전합니다.
--
-- 설계 원칙 하나: 테이블을 직접 열어주지 않는다.
--   모든 테이블에 RLS를 켜고 정책을 하나도 안 만들어서 바깥에서는 아무것도
--   못 읽고 못 씁니다. 읽기는 안전한 컬럼만 추린 뷰로, 쓰기는 전부 함수로만
--   나갑니다. 그래서 anon 키가 공개돼도 남의 글을 지우거나 PIN을 캐낼 수 없어요.
--   PIN은 bcrypt로 해시해서 서버에서만 비교합니다.
-- ===========================================================================

create extension if not exists pgcrypto with schema extensions;

-- ---------------------------------------------------------------- 테이블 --
create table if not exists fc_members (
  id          bigserial primary key,
  nick        text        not null,
  nick_key    text        not null unique,
  token       uuid        not null default gen_random_uuid() unique,
  pin_hash    text,
  joined_at   timestamptz not null default now(),
  greeted_at  timestamptz,
  is_admin    boolean     not null default false,
  last_post_at timestamptz,
  banned      boolean     not null default false
);

create table if not exists fc_posts (
  id            bigserial primary key,
  member_id     bigint      not null references fc_members(id) on delete cascade,
  body          text        not null check (char_length(body) between 1 and 500),
  created_at    timestamptz not null default now(),
  edited_at     timestamptz,
  pinned        boolean     not null default false,
  hidden        boolean     not null default false,
  hidden_reason text,
  report_count  int         not null default 0
);
create index if not exists fc_posts_created on fc_posts (created_at desc);

create table if not exists fc_comments (
  id         bigserial primary key,
  post_id    bigint      not null references fc_posts(id) on delete cascade,
  member_id  bigint      not null references fc_members(id) on delete cascade,
  body       text        not null check (char_length(body) between 1 and 200),
  created_at timestamptz not null default now(),
  hidden     boolean     not null default false
);
create index if not exists fc_comments_post on fc_comments (post_id);

-- 공감은 복합 기본키로 1인 1회를 구조로 막는다
create table if not exists fc_likes (
  post_id    bigint      not null references fc_posts(id) on delete cascade,
  member_id  bigint      not null references fc_members(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, member_id)
);

create table if not exists fc_greetings (
  member_id  bigint      primary key references fc_members(id) on delete cascade,
  answers    jsonb       not null,
  created_at timestamptz not null default now(),
  edited_at  timestamptz,
  hidden     boolean     not null default false
);

-- 팬미팅은 (사람, 한국 날짜) 유니크로 하루 한 장을 구조로 막는다
create table if not exists fc_questions (
  id          bigserial primary key,
  member_id   bigint      not null references fc_members(id) on delete cascade,
  day         date        not null,
  body        text        not null check (char_length(body) between 5 and 200),
  created_at  timestamptz not null default now(),
  answer      text,
  answered_at timestamptz,
  hidden      boolean     not null default false,
  unique (member_id, day)
);

create table if not exists fc_notices (
  id         int primary key default 1 check (id = 1),
  body       text,
  active     boolean     not null default false,
  updated_at timestamptz not null default now()
);

create table if not exists fc_links (
  id         int primary key default 1 check (id = 1),
  urls       jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists fc_reports (
  id          bigserial primary key,
  member_id   bigint      not null references fc_members(id) on delete cascade,
  target_type text        not null check (target_type in ('post','comment','greeting','question')),
  target_id   bigint      not null,
  reason      text        not null,
  created_at  timestamptz not null default now(),
  unique (member_id, target_type, target_id)
);

-- --------------------------------------------------------------- 잠그기 --
-- 정책을 하나도 만들지 않는다. RLS가 켜져 있고 정책이 없으면 바깥에서는
-- 읽기도 쓰기도 전부 막힌다. 아래 뷰와 함수만이 유일한 통로다.
alter table fc_members enable row level security;
alter table fc_posts enable row level security;
alter table fc_comments enable row level security;
alter table fc_likes enable row level security;
alter table fc_greetings enable row level security;
alter table fc_questions enable row level security;
alter table fc_notices enable row level security;
alter table fc_links enable row level security;
alter table fc_reports enable row level security;

-- ------------------------------------------------------------------ 뷰 --
-- 뷰는 소유자 권한으로 돌아서 RLS를 통과한다. 그래서 여기 적은 컬럼만,
-- 적은 모양 그대로 바깥에 나간다. token 과 pin_hash 는 어디에도 없다.
create or replace view v_members as
  select m.id, m.nick, m.nick_key, m.joined_at, m.greeted_at, m.is_admin,
         (m.pin_hash is not null) as has_pin
  from fc_members m where not m.banned;

create or replace view v_posts as
  select p.id, m.nick, m.nick_key,
         case when p.hidden then null else p.body end as body,
         p.created_at, p.edited_at, p.pinned, p.hidden, p.hidden_reason,
         (select count(*) from fc_likes    l where l.post_id = p.id)                   as like_count,
         (select count(*) from fc_comments c where c.post_id = p.id and not c.hidden)  as comment_count
  from fc_posts p join fc_members m on m.id = p.member_id
  where not m.banned;

create or replace view v_comments as
  select c.id, c.post_id, m.nick, m.nick_key,
         case when c.hidden then null else c.body end as body,
         c.created_at, c.hidden
  from fc_comments c join fc_members m on m.id = c.member_id
  where not m.banned;

create or replace view v_likes as
  select l.post_id, m.nick_key from fc_likes l join fc_members m on m.id = l.member_id;

create or replace view v_greetings as
  select g.member_id, m.nick, m.nick_key, g.answers, g.created_at, g.edited_at
  from fc_greetings g join fc_members m on m.id = g.member_id
  where not g.hidden and not m.banned;

create or replace view v_questions as
  select q.id, m.nick, m.nick_key, q.day, q.body, q.created_at, q.answer, q.answered_at
  from fc_questions q join fc_members m on m.id = q.member_id
  where not q.hidden and not m.banned;

create or replace view v_notice as select id, body, active, updated_at from fc_notices;
create or replace view v_links  as select id, urls, updated_at from fc_links;

-- ------------------------------------------------------------------ 함수 --
-- 전부 security definer. 바깥에서 테이블을 못 만지니 쓰기는 여기로만 들어온다.
-- 신원은 토큰(기기마다 하나)으로 확인하고, 글 수정·삭제처럼 되돌릴 수 없는
-- 동작은 PIN까지 서버에서 다시 본다.

create or replace function fc_auth(p_token uuid)
returns fc_members language plpgsql stable security definer
set search_path = public, extensions as $$
declare v fc_members;
begin
  select * into v from fc_members where token = p_token;
  if v.id is null then raise exception 'NO_SESSION'; end if;
  if v.banned then raise exception 'BANNED'; end if;
  return v;
end $$;

create or replace function fc_norm(p_nick text)
returns text language sql immutable as $$
  select lower(regexp_replace(btrim(p_nick), '\s+', '', 'g'))
$$;

create or replace function fc_profile(v fc_members)
returns json language sql stable as $$
  select json_build_object('token', v.token, 'nick', v.nick, 'nickKey', v.nick_key,
    'joinedAt', v.joined_at, 'greetedAt', v.greeted_at, 'isAdmin', v.is_admin,
    'hasPin', v.pin_hash is not null)
$$;

-- 이름표 달기 ------------------------------------------------------------
create or replace function fc_join(p_nick text)
returns json language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members; k text; n text;
begin
  n := btrim(p_nick); k := fc_norm(n);
  if char_length(n) < 2 or char_length(n) > 12 then raise exception 'NICK_LEN'; end if;
  if n !~ '^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9._-]+$'                then raise exception 'NICK_CHARS'; end if;
  if k = fc_norm('범쨩')                                     then raise exception 'ADMIN_RESERVED'; end if;
  if k = any (array['관리자','운영자','어드민','admin','사장님','금샘탕','사우나범','범짱'])
                                                             then raise exception 'NICK_BANNED'; end if;
  insert into fc_members (nick, nick_key) values (n, k) returning * into v;
  return fc_profile(v);
exception when unique_violation then raise exception 'NICK_TAKEN';
end $$;

-- 다른 기기에서 돌아오기 (PIN 이 진짜로 하는 일) --------------------------
create or replace function fc_login(p_nick text, p_pin text)
returns json language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members;
begin
  select * into v from fc_members where nick_key = fc_norm(p_nick);
  if v.id is null      then raise exception 'NO_MEMBER'; end if;
  if v.banned          then raise exception 'BANNED'; end if;
  if v.pin_hash is null then raise exception 'NO_PIN'; end if;
  if v.pin_hash <> crypt(p_pin, v.pin_hash) then raise exception 'BAD_PIN'; end if;
  return fc_profile(v);
end $$;

-- 이 기기에 남은 토큰으로 세션 복구 --------------------------------------
create or replace function fc_login_by_token(p_token uuid)
returns json language plpgsql stable security definer
set search_path = public, extensions as $$
declare v fc_members;
begin v := fc_auth(p_token); return fc_profile(v); end $$;

create or replace function fc_set_pin(p_token uuid, p_pin text)
returns json language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members;
begin
  v := fc_auth(p_token);
  if p_pin !~ '^\d{4}$' then raise exception 'PIN_FORMAT'; end if;
  if v.pin_hash is not null then raise exception 'PIN_EXISTS'; end if;
  update fc_members set pin_hash = crypt(p_pin, gen_salt('bf', 10)) where id = v.id
    returning * into v;
  return fc_profile(v);
end $$;

create or replace function fc_check_pin(v fc_members, p_pin text)
returns void language plpgsql as $$
begin
  if v.pin_hash is null then raise exception 'NO_PIN'; end if;
  if v.pin_hash <> crypt(p_pin, v.pin_hash) then raise exception 'BAD_PIN'; end if;
end $$;

-- 범쨩 ------------------------------------------------------------------
create or replace function fc_admin_claim(p_pin text)
returns json language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members;
begin
  if p_pin !~ '^\d{8}$' then raise exception 'PIN_FORMAT'; end if;
  select * into v from fc_members where nick_key = fc_norm('범쨩');
  if v.id is not null then raise exception 'ADMIN_EXISTS'; end if;
  insert into fc_members (nick, nick_key, pin_hash, is_admin, greeted_at)
  values ('범쨩', fc_norm('범쨩'), crypt(p_pin, gen_salt('bf', 10)), true, now())
  returning * into v;
  return fc_profile(v);
end $$;

create or replace function fc_need_admin(p_token uuid)
returns fc_members language plpgsql stable security definer
set search_path = public, extensions as $$
declare v fc_members;
begin
  v := fc_auth(p_token);
  if not v.is_admin then raise exception 'NOT_ADMIN'; end if;
  return v;
end $$;

-- 인사해요 → 정회원 승급 --------------------------------------------------
create or replace function fc_greet(p_token uuid, p_answers jsonb)
returns json language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members;
begin
  v := fc_auth(p_token);
  if char_length(coalesce(p_answers->>'q1','')) < 5
  or char_length(coalesce(p_answers->>'q2','')) < 5 then raise exception 'GREET_SHORT'; end if;
  insert into fc_greetings (member_id, answers) values (v.id, p_answers)
  on conflict (member_id) do update set answers = excluded.answers, edited_at = now();
  update fc_members set greeted_at = coalesce(greeted_at, now()) where id = v.id returning * into v;
  return fc_profile(v);
end $$;

-- 주접 -------------------------------------------------------------------
create or replace function fc_create_post(p_token uuid, p_body text)
returns bigint language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members; new_id bigint;
begin
  v := fc_auth(p_token);
  if v.greeted_at is null then raise exception 'NEED_GREET'; end if;
  if not v.is_admin and v.last_post_at is not null
     and v.last_post_at > now() - interval '60 seconds' then raise exception 'COOLDOWN'; end if;
  insert into fc_posts (member_id, body) values (v.id, btrim(p_body)) returning id into new_id;
  update fc_members set last_post_at = now() where id = v.id;
  return new_id;
end $$;

create or replace function fc_edit_post(p_token uuid, p_id bigint, p_body text, p_pin text)
returns void language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members; owner bigint;
begin
  v := fc_auth(p_token); perform fc_check_pin(v, p_pin);
  select member_id into owner from fc_posts where id = p_id;
  if owner is null    then raise exception 'NOT_FOUND'; end if;
  if owner <> v.id    then raise exception 'NOT_MINE'; end if;
  update fc_posts set body = btrim(p_body), edited_at = now() where id = p_id;
end $$;

create or replace function fc_delete_post(p_token uuid, p_id bigint, p_pin text)
returns void language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members; owner bigint;
begin
  v := fc_auth(p_token);
  select member_id into owner from fc_posts where id = p_id;
  if owner is null then raise exception 'NOT_FOUND'; end if;
  if owner = v.id then perform fc_check_pin(v, p_pin);
  elsif not v.is_admin then raise exception 'NOT_MINE'; end if;
  delete from fc_posts where id = p_id;   -- 댓글·공감은 on delete cascade 로 같이 내려감
end $$;

-- 공감 : 눌린 상태를 토글하고 실제 개수를 돌려준다 ------------------------
create or replace function fc_toggle_like(p_token uuid, p_post_id bigint)
returns json language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members; liked boolean;
begin
  v := fc_auth(p_token);
  delete from fc_likes where post_id = p_post_id and member_id = v.id;
  if found then liked := false;
  else insert into fc_likes (post_id, member_id) values (p_post_id, v.id); liked := true;
  end if;
  return json_build_object('liked', liked,
    'count', (select count(*) from fc_likes where post_id = p_post_id));
end $$;

-- 댓글 -------------------------------------------------------------------
create or replace function fc_create_comment(p_token uuid, p_post_id bigint, p_body text)
returns bigint language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members; new_id bigint;
begin
  v := fc_auth(p_token);
  if v.greeted_at is null then raise exception 'NEED_GREET'; end if;
  insert into fc_comments (post_id, member_id, body) values (p_post_id, v.id, btrim(p_body))
    returning id into new_id;
  return new_id;
end $$;

create or replace function fc_delete_comment(p_token uuid, p_id bigint, p_pin text)
returns void language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members; owner bigint;
begin
  v := fc_auth(p_token);
  select member_id into owner from fc_comments where id = p_id;
  if owner is null then raise exception 'NOT_FOUND'; end if;
  if owner = v.id then perform fc_check_pin(v, p_pin);
  elsif not v.is_admin then raise exception 'NOT_MINE'; end if;
  delete from fc_comments where id = p_id;
end $$;

-- 팬미팅 : 하루 한 장은 (사람, 한국 날짜) 유니크가 막는다 -----------------
create or replace function fc_create_question(p_token uuid, p_body text)
returns bigint language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members; new_id bigint;
begin
  v := fc_auth(p_token);
  if v.greeted_at is null then raise exception 'NEED_GREET'; end if;
  insert into fc_questions (member_id, day, body)
  values (v.id, (now() at time zone 'Asia/Seoul')::date, btrim(p_body))
  returning id into new_id;
  return new_id;
exception when unique_violation then raise exception 'DAILY_LIMIT';
end $$;

create or replace function fc_report(p_token uuid, p_type text, p_target bigint, p_reason text)
returns void language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members;
begin
  v := fc_auth(p_token);
  insert into fc_reports (member_id, target_type, target_id, reason)
  values (v.id, p_type, p_target, left(btrim(p_reason), 200))
  on conflict (member_id, target_type, target_id) do nothing;
  if p_type = 'post' then
    update fc_posts set report_count = (select count(*) from fc_reports r
      where r.target_type = 'post' and r.target_id = p_target) where id = p_target;
  end if;
end $$;

-- 범쨩 전용 ---------------------------------------------------------------
create or replace function fc_admin_hide_post(p_token uuid, p_id bigint, p_hidden boolean, p_reason text)
returns void language plpgsql security definer set search_path = public, extensions as $$
begin perform fc_need_admin(p_token);
  update fc_posts set hidden = p_hidden,
         hidden_reason = case when p_hidden then nullif(btrim(coalesce(p_reason,'')),'') else null end
   where id = p_id;
end $$;

create or replace function fc_admin_pin_post(p_token uuid, p_id bigint, p_pinned boolean)
returns void language plpgsql security definer set search_path = public, extensions as $$
begin perform fc_need_admin(p_token); update fc_posts set pinned = p_pinned where id = p_id; end $$;

create or replace function fc_admin_answer(p_token uuid, p_id bigint, p_answer text)
returns void language plpgsql security definer set search_path = public, extensions as $$
begin perform fc_need_admin(p_token);
  update fc_questions set answer = nullif(btrim(coalesce(p_answer,'')),''),
         answered_at = case when nullif(btrim(coalesce(p_answer,'')),'') is null then null else now() end
   where id = p_id;
end $$;

create or replace function fc_admin_hide_greeting(p_token uuid, p_member_id bigint)
returns void language plpgsql security definer set search_path = public, extensions as $$
begin perform fc_need_admin(p_token);
  update fc_greetings set hidden = true where member_id = p_member_id;
  update fc_members   set greeted_at = null where id = p_member_id;
end $$;

create or replace function fc_admin_notice(p_token uuid, p_body text)
returns void language plpgsql security definer set search_path = public, extensions as $$
declare b text;
begin perform fc_need_admin(p_token); b := nullif(btrim(coalesce(p_body,'')),'');
  insert into fc_notices (id, body, active, updated_at) values (1, b, b is not null, now())
  on conflict (id) do update set body = excluded.body, active = excluded.active, updated_at = now();
end $$;

create or replace function fc_admin_links(p_token uuid, p_urls jsonb)
returns void language plpgsql security definer set search_path = public, extensions as $$
begin perform fc_need_admin(p_token);
  insert into fc_links (id, urls, updated_at) values (1, p_urls, now())
  on conflict (id) do update set urls = excluded.urls, updated_at = now();
end $$;

create or replace function fc_admin_reports(p_token uuid)
returns setof json language plpgsql security definer set search_path = public, extensions as $$
begin perform fc_need_admin(p_token);
  return query select json_build_object('id', r.id, 'targetType', r.target_type,
    'targetId', r.target_id, 'reason', r.reason, 'createdAt', r.created_at, 'nick', m.nick)
  from fc_reports r join fc_members m on m.id = r.member_id order by r.created_at desc;
end $$;

create or replace function fc_admin_clear_report(p_token uuid, p_id bigint)
returns void language plpgsql security definer set search_path = public, extensions as $$
begin perform fc_need_admin(p_token); delete from fc_reports where id = p_id; end $$;

-- ------------------------------------------------------------------ 권한 --
-- 뷰는 읽기만, 함수는 실행만. 테이블 자체는 anon 에게 아무 권한도 주지 않는다.
grant select on v_members to anon, authenticated;
grant select on v_posts to anon, authenticated;
grant select on v_comments to anon, authenticated;
grant select on v_likes to anon, authenticated;
grant select on v_greetings to anon, authenticated;
grant select on v_questions to anon, authenticated;
grant select on v_notice to anon, authenticated;
grant select on v_links to anon, authenticated;

revoke all on fc_members, fc_posts, fc_comments, fc_likes, fc_greetings,
              fc_questions, fc_notices, fc_links, fc_reports from anon, authenticated;

-- 내부용 보조 함수는 바깥에 노출하지 않는다
revoke all on function fc_auth(uuid), fc_need_admin(uuid),
                       fc_check_pin(fc_members, text), fc_profile(fc_members)
       from anon, authenticated, public;

grant execute on function fc_join(text) to anon, authenticated;
grant execute on function fc_login(text,text) to anon, authenticated;
grant execute on function fc_login_by_token(uuid) to anon, authenticated;
grant execute on function fc_set_pin(uuid,text) to anon, authenticated;
grant execute on function fc_admin_claim(text) to anon, authenticated;
grant execute on function fc_greet(uuid,jsonb) to anon, authenticated;
grant execute on function fc_create_post(uuid,text) to anon, authenticated;
grant execute on function fc_edit_post(uuid,bigint,text,text) to anon, authenticated;
grant execute on function fc_delete_post(uuid,bigint,text) to anon, authenticated;
grant execute on function fc_toggle_like(uuid,bigint) to anon, authenticated;
grant execute on function fc_create_comment(uuid,bigint,text) to anon, authenticated;
grant execute on function fc_delete_comment(uuid,bigint,text) to anon, authenticated;
grant execute on function fc_create_question(uuid,text) to anon, authenticated;
grant execute on function fc_report(uuid,text,bigint,text) to anon, authenticated;
grant execute on function fc_admin_hide_post(uuid,bigint,boolean,text) to anon, authenticated;
grant execute on function fc_admin_pin_post(uuid,bigint,boolean) to anon, authenticated;
grant execute on function fc_admin_answer(uuid,bigint,text) to anon, authenticated;
grant execute on function fc_admin_hide_greeting(uuid,bigint) to anon, authenticated;
grant execute on function fc_admin_notice(uuid,text) to anon, authenticated;
grant execute on function fc_admin_links(uuid,jsonb) to anon, authenticated;
grant execute on function fc_admin_reports(uuid) to anon, authenticated;
grant execute on function fc_admin_clear_report(uuid,bigint) to anon, authenticated;

insert into fc_notices (id, body, active) values (1, null, false) on conflict do nothing;
insert into fc_links   (id, urls)         values (1, '{}'::jsonb) on conflict do nothing;
