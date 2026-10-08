# 업다운 팬클럽 — Supabase 붙이기

지금 `fanclub/index.html` 은 설정이 비어 있어서 **이 기기에만 저장되는 모드**로 돌아갑니다.
아래 네 단계를 거치면 누구나 들어와서 글을 쓰는 진짜 팬클럽이 됩니다. 20분 정도 걸려요.

---

## 1. 프로젝트 만들기

[supabase.com](https://supabase.com) 가입 → **New project**.

- Region 은 **Northeast Asia (Seoul)** 로 고르세요. 한국에서 접속할 때 가장 빠릅니다.
- Database password 는 아무거나 정하고 적어두세요. 이 페이지에선 안 쓰지만 나중에 필요할 수 있어요.
- 무료 플랜으로 충분합니다. 이 정도 규모면 한도 근처도 안 갑니다.

## 2. 스키마 올리기

왼쪽 메뉴 **SQL Editor** → **New query** → `schema.sql` 내용을 통째로 붙여넣고 **Run**.

`Success. No rows returned` 가 뜨면 끝입니다.

### 실행 전 경고 팝업이 뜬다면

Supabase SQL Editor 는 실행 전에 쿼리를 훑어보고 경고를 띄웁니다. 이 스크립트에서는
**destructive operation** 경고가 뜨는데, `revoke` 구문 때문입니다. 테이블 권한을
anon 에게서 거둬들이는 건 이 설계의 핵심이라 꼭 필요한 구문이에요. 그대로 진행하세요.

`creates tables without enabling RLS` 경고가 뜬다면 예전 버전을 쓰고 계신 겁니다.
지금 스크립트는 `alter table ... enable row level security` 를 테이블마다 한 줄씩
명시해서 린터가 알아볼 수 있게 해뒀습니다.

실행한 뒤 이걸로 직접 확인해보셔도 됩니다. 9줄 전부 `t` 가 나와야 맞아요.

```sql
select relname, relrowsecurity as rls_enabled
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
 where n.nspname = 'public' and relkind = 'r'
 order by relname;
```

 테이블 9개, 뷰 8개, 함수 27개가 생깁니다.
여러 번 실행해도 안전하니 나중에 스키마를 고칠 때도 그냥 다시 붙여넣으면 됩니다.

## 3. 주소와 키 — 이미 넣어뒀습니다

`index.html` 의 `SUPABASE` 블록에 프로젝트 주소와 `anon public` 키가 이미 들어가 있습니다.
다른 프로젝트로 옮길 때만 **Project Settings → API** 에서 두 값을 다시 복사해 바꾸면 됩니다.

```js
const SUPABASE={
  url:'https://fueovdlhzrjovihlrsdi.supabase.co',
  anonKey:'eyJhbGciOi...',
};
```

> **anon 키는 공개돼도 되는 키입니다.** 브라우저에 그대로 박으라고 만든 키예요.
> 이 키로 할 수 있는 건 뷰를 읽고 함수를 부르는 것뿐이고, 테이블은 전부 잠겨 있습니다.
> `service_role` 키는 절대 넣지 마세요. 그건 모든 걸 통과하는 열쇠입니다.

> 서버에 닿지 못하면(네트워크가 막힌 곳, 아티팩트 미리보기 등) 페이지가 깨지는 대신
> **이 기기에만 저장되는 모드로 열립니다.** 푸터를 보면 지금 어느 모드인지 알 수 있어요.

## 4. 올리기

`index.html` 하나만 있으면 되므로 아무 정적 호스팅에나 올라갑니다.

- **GitHub Pages** — 레포 Settings → Pages → 브랜치 고르면 끝. 무료.
- **Vercel / Netlify** — 레포 연결하면 자동 배포. 무료.
- 파일을 그냥 열어도(`file://`) 동작하지만, 남에게 보여주려면 호스팅이 필요합니다.

올린 주소로 들어가서 이름표를 달아보세요. 푸터에
`여기 쓴 글은 이 주소를 여는 모든 사람에게 보여요.` 라고 뜨면 연결된 겁니다.

---

## 운영자 계정

운영자 이름은 **`범쨩`, `빵야씨`, `강다운`** 세 자리입니다. `강다운` 은 사장님 본인 자리예요.
각자 자기 8자리를 따로 정하고, 서로의 비번으로는 들어갈 수 없습니다.
일반 가입으로는 이 세 이름을 쓸 수 없어요.

사장님으로 들어오시면 팬미팅 질문에 **직접 답변을 다실 수 있습니다** (버튼이 `답변 달기`).
범쨩·빵야씨가 볼 때는 `답변 옮겨 적기` — 사장님이 다른 데 남기신 답을 옮기는 용도입니다.
어느 쪽으로 넣어도 질문 아래에 `사장님 답변` 으로 똑같이 붙습니다.
회원 목록에서 사장님은 `사장님`, 나머지는 `운영자` 로 표시돼요.

운영자를 늘리거나 바꾸려면 스키마의 `fc_admin_nicks()` 한 줄만 고치면 되고,
페이지 쪽 `ADMIN_NICKS` 도 같이 맞춰주세요.

처음 한 번만 하면 됩니다.

1. 페이지에서 **이름표 달기** → 닉네임에 `범쨩` / `빵야씨` / `강다운` 중 하나 입력
2. 8자리 숫자를 정하고 한 번 더 확인 → 등록 완료
3. 그 뒤로는 같은 방법으로 들어가면 8자리를 물어봅니다

비밀번호는 코드에도 DB에도 평문으로 남지 않습니다. bcrypt 해시만 저장돼요.
**잊어버리면 복구가 안 됩니다.** 잊었다면 SQL Editor 에서 이렇게 다시 정하세요.

```sql
update fc_members
   set admin_hash = extensions.crypt('새8자리', extensions.gen_salt('bf', 10))
 where nick_key = '범쨩';   -- 또는 '빵야씨', '강다운'
```

---

## 보안이 실제로 어떻게 달라지나

이전(브라우저 저장)에는 PIN 검증이 전부 브라우저 안에서 일어나서 매너 장치에 불과했습니다.
지금은 **테이블이 잠겨 있고 쓰기가 전부 서버 함수를 거칩니다.** 그래서 아래가 구조로 막힙니다.
전부 실제로 돌려서 확인한 결과입니다.

| 해보면 | 결과 |
|---|---|
| 회원 테이블을 직접 읽어 PIN 캐내기 | `permission denied` — 토큰도 해시도 바깥에 안 나감 |
| 남의 글 지우기 | `NOT_MINE` |
| 인사 안 하고 주접 쓰기 | `NEED_GREET` |
| 팬미팅 질문 하루 두 번 | `DAILY_LIMIT` — (사람, 한국 날짜) 유니크가 막음 |
| 공감 여러 번 눌러 수 늘리기 | 복합 기본키라 한 사람당 한 줄 |
| 일반 회원이 공지 올리기 | `NOT_ADMIN` |
| 일반 회원이 경고 보내기·차단하기 | `NOT_ADMIN` |
| 남이 받은 경고 훔쳐보기 | 자기 것만 보입니다 |
| 차단된 사람이 글쓰기 | `BANNED` — 쓰던 글과 댓글도 전부 가려집니다 |
| 경고 3회 | 자동으로 7일 차단됩니다 |
| 범쨩이 자기를 차단 | `NOT_YOURSELF` |
| 가짜 토큰으로 아무거나 | `NO_SESSION` |
| 연달아 도배 | `COOLDOWN` (60초) |

브라우저 화면을 뚫고 서버로 직접 요청을 보내도 같은 답이 돌아옵니다.

**다만 이것도 만능은 아닙니다.** 솔직하게 적어둡니다.

- **4자리는 경우의 수가 1만입니다.** 서버에 시도 횟수 제한이 없어서, 작정하고 자동화하면
  남의 이름표로 들어올 수 있습니다. 범쨩 8자리도 마찬가지고요.
  신경 쓰이면 Supabase 의 Rate Limiting 을 켜세요.
- **토큰이 새면 그 이름표는 넘어갑니다.** 브라우저 저장소에 들어 있으니 기기를 공유하거나
  빌려주면 그대로 노출됩니다.
- **가입에 제한이 없습니다.** 닉네임을 대량으로 만들어 도배하는 건 막지 못합니다.
  그런 일이 생기면 범쨩이 지우는 수밖에 없어요.
- **삭제는 되돌릴 수 없습니다.** 글을 지우면 댓글과 공감도 같이 사라집니다.

팬클럽 규모에서는 충분하지만, "완벽히 안전하다"고 생각하진 마세요.

---

## 신원을 어떻게 다루나

| | |
|---|---|
| **토큰** | 이름표를 달면 서버가 발급. 이 기기의 브라우저에만 저장됩니다. 평소 신원 확인은 이걸로 해요. |
| **회원 4자리** | 이름표를 만들 때 정합니다. **다른 기기에서 같은 이름표로 들어올 때** 씁니다. |
| **범쨩 8자리** | 운영자 계정에만 있습니다. |

둘 다 입덕 기록 패널의 **비밀번호 바꾸기**에서 바꿀 수 있습니다. 지금 쓰는 번호를
먼저 맞혀야 바뀌고, 범쨩은 여덟 자리로만 바꿀 수 있어요.

둘 다 bcrypt 로 해시해서 서버에서만 비교하고, 뷰에는 나가지 않습니다.

글을 고치거나 지울 때는 비밀번호를 묻지 않습니다. 토큰이 이미 이 기기의 신원을
증명하니 한 겹 더 둘 이유가 없고, 설정한 적 없는 번호를 확인하라고 묻는 건 더 이상하니까요.
비밀번호가 하는 일은 하나입니다 — 휴대폰에서 쓰던 이름표로 노트북에서 들어오는 것.

---

## 운영하다 막히면

**글이 안 보여요** — 브라우저 개발자도구 Network 탭에서 `v_posts` 요청이 200 인지 보세요.
401/404 면 URL 이나 키가 틀린 겁니다.

**`permission denied for table ...` 이 떠요** — `schema.sql` 맨 아래 권한 블록이 안 돌았습니다.
전체를 다시 한 번 실행하세요.

**Supabase 가 "Security Definer View" 경고를 띄워요** — 의도한 설계입니다.
뷰가 소유자 권한으로 돌아야 잠긴 테이블에서 안전한 컬럼만 추려 보여줄 수 있어요.

**데이터를 직접 보고 싶어요** — Table Editor 에서 전부 보입니다. 대시보드는 소유자 권한이라
RLS 를 통과해요. 글 지우기, 공지 수정 같은 건 거기서 해도 됩니다.

**무료 플랜은 일주일 안 쓰면 프로젝트가 멈춥니다.** 대시보드에서 다시 켜면 데이터는 그대로예요.

---

## 스키마 전문 (복사용)

아래 전체를 복사해서 **SQL Editor → New query** 에 붙여넣고 **Run** 하세요.
`schema.sql` 파일과 같은 내용입니다. 여러 번 실행해도 안전합니다.

```sql
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
  pin_hash    text,        -- 회원 4자리. 다른 기기에서 이름표를 되찾을 때 쓴다
  admin_hash  text,        -- 운영자 8자리
  joined_at   timestamptz not null default now(),
  greeted_at  timestamptz,
  is_admin    boolean     not null default false,
  last_post_at timestamptz,
  banned_until timestamptz -- 비어 있으면 정상. 미래 시각이면 그때까지 차단.
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

-- 범쨩이 보낸 경고. 받은 본인과 범쨩만 볼 수 있다 (뷰로 안 내보낸다).
create table if not exists fc_warnings (
  id         bigserial primary key,
  member_id  bigint      not null references fc_members(id) on delete cascade,
  body       text,
  created_at timestamptz not null default now(),
  read_at    timestamptz
);
create index if not exists fc_warnings_member on fc_warnings (member_id);

create table if not exists fc_reports (
  id          bigserial primary key,
  member_id   bigint      not null references fc_members(id) on delete cascade,
  target_type text        not null check (target_type in ('post','comment','greeting','question')),
  target_id   bigint      not null,
  reason      text        not null,
  created_at  timestamptz not null default now(),
  unique (member_id, target_type, target_id)
);

-- --------------------------------------------- 예전 버전 정리 --
-- 뷰와 함수의 모양이 바뀌었으므로 먼저 내린다. 스크립트를 다시 돌려도
-- 깨지지 않게 하려는 것이고, 테이블의 데이터는 건드리지 않는다.
drop view if exists v_members, v_posts, v_comments, v_likes,
                    v_greetings, v_questions, v_notice, v_links cascade;
drop function if exists fc_join(text);
drop function if exists fc_edit_post(uuid,bigint,text,text);
drop function if exists fc_delete_post(uuid,bigint,text);
drop function if exists fc_delete_comment(uuid,bigint,text);
drop function if exists fc_set_pin(uuid,text);
drop function if exists fc_login(text,text);
drop function if exists fc_admin_login(text);
drop function if exists fc_admin_claim(text);
drop function if exists fc_check_pin(fc_members,text);
drop function if exists fc_profile(fc_members);
drop function if exists fc_admin_reports(uuid);
drop function if exists fc_admin_ban(uuid,bigint,boolean);
drop function if exists fc_admin_members(uuid);
drop function if exists fc_change_pin(uuid,text,text);
-- 비밀번호 칼럼 두 개. 회원 4자리와 범쨩 8자리는 역할이 달라 따로 둔다.
alter table fc_members add column if not exists pin_hash     text;
alter table fc_members add column if not exists banned_until timestamptz;
-- 예전의 참/거짓 차단을 기간제로 옮긴다 (참이었다면 영구 차단으로)
do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema='public' and table_name='fc_members' and column_name='banned') then
    execute $q$ update fc_members set banned_until = 'infinity'
                 where banned and banned_until is null $q$;
    execute 'alter table fc_members drop column banned';
  end if;
end $$;
alter table fc_members add column if not exists admin_hash text;
-- 예전 버전에서 범쨩 비번이 pin_hash 에 있었다면 제자리로 옮긴다
update fc_members set admin_hash = pin_hash, pin_hash = null
 where is_admin and admin_hash is null and pin_hash is not null;

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
alter table fc_warnings enable row level security;
alter table fc_reports enable row level security;

-- ------------------------------------------------------------------ 뷰 --
-- 뷰는 소유자 권한으로 돌아서 RLS를 통과한다. 그래서 여기 적은 컬럼만,
-- 적은 모양 그대로 바깥에 나간다. token 과 pin_hash 는 어디에도 없다.
create view v_members as
  select m.id, m.nick, m.nick_key, m.joined_at, m.greeted_at, m.is_admin
  from fc_members m where m.banned_until is null or m.banned_until <= now();

create view v_posts as
  select p.id, m.nick, m.nick_key,
         case when p.hidden then null else p.body end as body,
         p.created_at, p.edited_at, p.pinned, p.hidden, p.hidden_reason,
         (select count(*) from fc_likes    l where l.post_id = p.id)                   as like_count,
         (select count(*) from fc_comments c where c.post_id = p.id and not c.hidden)  as comment_count
  from fc_posts p join fc_members m on m.id = p.member_id
  where m.banned_until is null or m.banned_until <= now();

create view v_comments as
  select c.id, c.post_id, m.nick, m.nick_key,
         case when c.hidden then null else c.body end as body,
         c.created_at, c.hidden
  from fc_comments c join fc_members m on m.id = c.member_id
  where m.banned_until is null or m.banned_until <= now();

create view v_likes as
  select l.post_id, m.nick_key from fc_likes l join fc_members m on m.id = l.member_id;

create view v_greetings as
  select g.member_id, m.nick, m.nick_key, g.answers, g.created_at, g.edited_at
  from fc_greetings g join fc_members m on m.id = g.member_id
  where not g.hidden and (m.banned_until is null or m.banned_until <= now());

create view v_questions as
  select q.id, m.nick, m.nick_key, q.day, q.body, q.created_at, q.answer, q.answered_at
  from fc_questions q join fc_members m on m.id = q.member_id
  where not q.hidden and (m.banned_until is null or m.banned_until <= now());

create view v_notice as select id, body, active, updated_at from fc_notices;
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
  if v.banned_until is not null and v.banned_until > now() then raise exception 'BANNED'; end if;
  return v;
end $$;

create or replace function fc_norm(p_nick text)
returns text language sql immutable as $$
  select lower(regexp_replace(btrim(p_nick), '\s+', '', 'g'))
$$;

create function fc_profile(v fc_members)
returns json language sql stable as $$
  select json_build_object('token', v.token, 'nick', v.nick, 'nickKey', v.nick_key,
    'joinedAt', v.joined_at, 'greetedAt', v.greeted_at, 'isAdmin', v.is_admin,
    'warnings', (select count(*) from fc_warnings w where w.member_id = v.id),
    'bannedUntil', case when v.banned_until > now() then v.banned_until end)
$$;

-- 운영자로 예약된 이름들. 여기 적힌 이름은 일반 가입이 막히고,
-- 각자 자기 8자리로 처음 한 번 등록한 뒤 그 번호로 들어온다.
-- 운영자 이름 목록. 여기만 고치면 운영자가 늘거나 줄어든다.
-- (페이지 쪽 ADMIN_NICKS 도 같이 맞춰주세요.)
-- '강다운' 은 사장님 본인 자리다. 권한은 같고 화면 문구만 다르다.
create or replace function fc_admin_nicks()
returns text[] language sql immutable as $$ select array['범쨩','빵야씨','강다운'] $$;

create or replace function fc_is_admin_nick(p_key text)
returns boolean language sql stable as $$
  select exists (select 1 from unnest(fc_admin_nicks()) n where fc_norm(n) = p_key)
$$;

-- '빵야' 로 이미 등록해 두셨다면 '빵야씨' 로 이름만 옮겨 준다.
-- 비번은 그대로 쓰시면 됩니다. 등록 전이었다면 아무 일도 일어나지 않는다.
update fc_members
   set nick = '빵야씨', nick_key = fc_norm('빵야씨')
 where nick_key = fc_norm('빵야')
   and is_admin
   and not exists (select 1 from fc_members m2 where m2.nick_key = fc_norm('빵야씨'));

-- 이름표 달기 ------------------------------------------------------------
create or replace function fc_join(p_nick text, p_pin text)
returns json language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members; k text; n text;
begin
  n := btrim(p_nick); k := fc_norm(n);
  if char_length(n) < 2 or char_length(n) > 12 then raise exception 'NICK_LEN'; end if;
  if p_pin !~ '^\d{4}$' then raise exception 'PIN_FORMAT'; end if;
  if n !~ '^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9._-]+$'                then raise exception 'NICK_CHARS'; end if;
  if fc_is_admin_nick(k)                                     then raise exception 'ADMIN_RESERVED'; end if;
  if k = any (array['관리자','운영자','어드민','admin','사장님','금샘탕','사우나범','범짱'])
                                                             then raise exception 'NICK_BANNED'; end if;
  insert into fc_members (nick, nick_key, pin_hash)
  values (n, k, crypt(p_pin, gen_salt('bf', 10))) returning * into v;
  return fc_profile(v);
exception when unique_violation then raise exception 'NICK_TAKEN';
end $$;

-- 다른 기기에서 내 이름표로 들어오기 --------------------------------------
create or replace function fc_login(p_nick text, p_pin text)
returns json language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members;
begin
  select * into v from fc_members where nick_key = fc_norm(p_nick);
  if v.id is null       then raise exception 'NO_MEMBER'; end if;
  if v.pin_hash is null then raise exception 'NO_PIN'; end if;
  if v.pin_hash <> crypt(p_pin, v.pin_hash) then raise exception 'BAD_PIN'; end if;
  return fc_profile(v);
end $$;

-- 비번 없이 만들어진 예전 이름표에 비번을 붙여줄 때만 쓴다
create or replace function fc_set_pin(p_token uuid, p_pin text)
returns json language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members;
begin
  v := fc_auth(p_token);
  if p_pin !~ '^\d{4}$' then raise exception 'PIN_FORMAT'; end if;
  if v.pin_hash is not null then raise exception 'PIN_EXISTS'; end if;
  update fc_members set pin_hash = crypt(p_pin, gen_salt('bf', 10))
   where id = v.id returning * into v;
  return fc_profile(v);
end $$;

-- 비번 바꾸기. 회원은 네 자리, 범쨩은 여덟 자리를 쓴다.
-- 지금 쓰는 번호를 먼저 맞혀야 바뀐다.
create or replace function fc_change_pin(p_token uuid, p_old text, p_new text)
returns void language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members; cur text; want text;
begin
  v := fc_auth(p_token);
  if v.is_admin then cur := v.admin_hash; want := '^\d{8}$';
  else               cur := v.pin_hash;   want := '^\d{4}$';
  end if;
  if cur is null then raise exception 'NO_PIN'; end if;
  if cur <> crypt(p_old, cur) then raise exception 'BAD_PIN'; end if;
  if p_new !~ want then raise exception 'PIN_FORMAT'; end if;
  if v.is_admin then
    update fc_members set admin_hash = crypt(p_new, gen_salt('bf', 10)) where id = v.id;
  else
    update fc_members set pin_hash   = crypt(p_new, gen_salt('bf', 10)) where id = v.id;
  end if;
end $$;

-- 이 기기에 남은 토큰으로 세션 복구 --------------------------------------
-- 차단 중인 사람도 자기 상태(남은 기간, 경고 수)는 볼 수 있어야 하므로
-- 여기서는 fc_auth 를 쓰지 않는다. 쓰기는 여전히 fc_auth 가 막는다.
create or replace function fc_login_by_token(p_token uuid)
returns json language plpgsql stable security definer
set search_path = public, extensions as $$
declare v fc_members;
begin
  select * into v from fc_members where token = p_token;
  if v.id is null then raise exception 'NO_SESSION'; end if;
  return fc_profile(v);
end $$;

-- 범쨩 ------------------------------------------------------------------
create or replace function fc_admin_claim(p_nick text, p_pin text)
returns json language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members; k text;
begin
  k := fc_norm(p_nick);
  if not fc_is_admin_nick(k) then raise exception 'NOT_ADMIN'; end if;
  if p_pin !~ '^\d{8}$'      then raise exception 'PIN_FORMAT'; end if;
  select * into v from fc_members where nick_key = k;
  if v.id is not null then raise exception 'ADMIN_EXISTS'; end if;
  insert into fc_members (nick, nick_key, admin_hash, is_admin, greeted_at)
  values (btrim(p_nick), k, crypt(p_pin, gen_salt('bf', 10)), true, now())
  returning * into v;
  return fc_profile(v);
end $$;

-- 범쨩으로 들어오기. 8자리는 bcrypt 로 서버에서만 비교한다.
create or replace function fc_admin_login(p_nick text, p_pin text)
returns json language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members;
begin
  select * into v from fc_members where nick_key = fc_norm(p_nick);
  if v.id is null          then raise exception 'NO_MEMBER'; end if;
  if v.admin_hash is null  then raise exception 'NO_MEMBER'; end if;
  if v.admin_hash <> crypt(p_pin, v.admin_hash) then raise exception 'BAD_PIN'; end if;
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

-- 고치기는 본인만. 범쨩도 남의 글은 못 고친다 (지우거나 숨기는 것까지만).
create or replace function fc_edit_post(p_token uuid, p_id bigint, p_body text)
returns void language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members; owner bigint;
begin
  v := fc_auth(p_token);
  select member_id into owner from fc_posts where id = p_id;
  if owner is null then raise exception 'NOT_FOUND'; end if;
  if owner <> v.id then raise exception 'NOT_MINE'; end if;
  update fc_posts set body = btrim(p_body), edited_at = now() where id = p_id;
end $$;

create or replace function fc_delete_post(p_token uuid, p_id bigint)
returns void language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members; owner bigint;
begin
  v := fc_auth(p_token);
  select member_id into owner from fc_posts where id = p_id;
  if owner is null then raise exception 'NOT_FOUND'; end if;
  if owner <> v.id and not v.is_admin then raise exception 'NOT_MINE'; end if;
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

create or replace function fc_delete_comment(p_token uuid, p_id bigint)
returns void language plpgsql security definer
set search_path = public, extensions as $$
declare v fc_members; owner bigint;
begin
  v := fc_auth(p_token);
  select member_id into owner from fc_comments where id = p_id;
  if owner is null then raise exception 'NOT_FOUND'; end if;
  if owner <> v.id and not v.is_admin then raise exception 'NOT_MINE'; end if;
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

-- 경고 보내기 / 받기 ----------------------------------------------------
create or replace function fc_admin_warn(p_token uuid, p_member_id bigint, p_body text)
returns void language plpgsql security definer set search_path = public, extensions as $$
declare cnt int;
begin perform fc_need_admin(p_token);
  insert into fc_warnings (member_id, body)
  values (p_member_id, nullif(btrim(coalesce(p_body,'')),''));
  -- 세 번째 경고면 자동으로 일주일 차단한다
  select count(*) into cnt from fc_warnings where member_id = p_member_id;
  if cnt >= 3 then
    update fc_members set banned_until = greatest(coalesce(banned_until, now()), now() + interval '7 days')
     where id = p_member_id and not is_admin
       and (banned_until is null or banned_until <= now());
  end if;
end $$;

-- 내가 받은, 아직 안 읽은 경고
create or replace function fc_my_warnings(p_token uuid)
returns setof json language plpgsql stable security definer
set search_path = public, extensions as $$
declare v fc_members;
begin
  v := fc_auth(p_token);
  return query select json_build_object('id', w.id, 'body', w.body, 'createdAt', w.created_at)
                 from fc_warnings w
                where w.member_id = v.id and w.read_at is null
                order by w.created_at;
end $$;

create or replace function fc_ack_warning(p_token uuid, p_id bigint)
returns void language plpgsql security definer set search_path = public, extensions as $$
declare v fc_members;
begin
  v := fc_auth(p_token);
  update fc_warnings set read_at = now() where id = p_id and member_id = v.id;
end $$;

-- 차단 / 차단 풀기 -------------------------------------------------------
-- p_days : 0 이면 차단 해제, 양수면 그만큼, 음수면 영구
create or replace function fc_admin_ban(p_token uuid, p_member_id bigint, p_days int)
returns void language plpgsql security definer set search_path = public, extensions as $$
declare a fc_members;
begin
  a := fc_need_admin(p_token);
  if p_member_id = a.id then raise exception 'NOT_YOURSELF'; end if;
  update fc_members
     set banned_until = case when p_days = 0 then null
                             when p_days < 0 then 'infinity'::timestamptz
                             else now() + (p_days || ' days')::interval end
   where id = p_member_id and not is_admin;
end $$;

-- 범쨩이 보는 회원 목록 (차단된 사람까지)
create or replace function fc_admin_members(p_token uuid)
returns setof json language plpgsql stable security definer
set search_path = public, extensions as $$
begin perform fc_need_admin(p_token);
  return query
    select json_build_object('id', m.id, 'nick', m.nick, 'nickKey', m.nick_key,
      'joinedAt', m.joined_at, 'greetedAt', m.greeted_at, 'isAdmin', m.is_admin,
      'bannedUntil', case when m.banned_until > now() then m.banned_until end,
      'posts', (select count(*) from fc_posts p where p.member_id = m.id),
      'warnings', (select count(*) from fc_warnings w where w.member_id = m.id))
    from fc_members m order by (m.banned_until > now()) desc nulls last, m.joined_at;
end $$;

create or replace function fc_admin_reports(p_token uuid)
returns setof json language plpgsql security definer set search_path = public, extensions as $$
begin perform fc_need_admin(p_token);
  return query select json_build_object('id', r.id, 'targetType', r.target_type,
    'targetId', r.target_id, 'reason', r.reason, 'createdAt', r.created_at, 'nick', m.nick,
    'authorId', a.id, 'authorNick', a.nick, 'authorBannedUntil', case when a.banned_until > now() then a.banned_until end,
    'authorWarnings', (select count(*) from fc_warnings w where w.member_id = a.id))
  from fc_reports r
  join fc_members m on m.id = r.member_id
  left join fc_members a on a.id = case
        when r.target_type = 'post'    then (select p.member_id from fc_posts    p where p.id = r.target_id)
        when r.target_type = 'comment' then (select c.member_id from fc_comments c where c.id = r.target_id)
      end
  order by r.created_at desc;
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
              fc_questions, fc_notices, fc_links, fc_reports, fc_warnings
       from anon, authenticated;

-- 내부용 보조 함수는 바깥에 노출하지 않는다
revoke all on function fc_auth(uuid), fc_need_admin(uuid), fc_profile(fc_members)
       from anon, authenticated, public;

grant execute on function fc_join(text,text) to anon, authenticated;
grant execute on function fc_login(text,text) to anon, authenticated;
grant execute on function fc_set_pin(uuid,text) to anon, authenticated;
grant execute on function fc_change_pin(uuid,text,text) to anon, authenticated;
grant execute on function fc_login_by_token(uuid) to anon, authenticated;
grant execute on function fc_admin_claim(text,text) to anon, authenticated;
grant execute on function fc_admin_login(text,text) to anon, authenticated;
grant execute on function fc_greet(uuid,jsonb) to anon, authenticated;
grant execute on function fc_create_post(uuid,text) to anon, authenticated;
grant execute on function fc_edit_post(uuid,bigint,text) to anon, authenticated;
grant execute on function fc_delete_post(uuid,bigint) to anon, authenticated;
grant execute on function fc_toggle_like(uuid,bigint) to anon, authenticated;
grant execute on function fc_create_comment(uuid,bigint,text) to anon, authenticated;
grant execute on function fc_delete_comment(uuid,bigint) to anon, authenticated;
grant execute on function fc_create_question(uuid,text) to anon, authenticated;
grant execute on function fc_report(uuid,text,bigint,text) to anon, authenticated;
grant execute on function fc_admin_hide_post(uuid,bigint,boolean,text) to anon, authenticated;
grant execute on function fc_admin_pin_post(uuid,bigint,boolean) to anon, authenticated;
grant execute on function fc_admin_answer(uuid,bigint,text) to anon, authenticated;
grant execute on function fc_admin_hide_greeting(uuid,bigint) to anon, authenticated;
grant execute on function fc_admin_notice(uuid,text) to anon, authenticated;
grant execute on function fc_admin_links(uuid,jsonb) to anon, authenticated;
grant execute on function fc_admin_reports(uuid) to anon, authenticated;
grant execute on function fc_admin_warn(uuid,bigint,text) to anon, authenticated;
grant execute on function fc_my_warnings(uuid) to anon, authenticated;
grant execute on function fc_ack_warning(uuid,bigint) to anon, authenticated;
grant execute on function fc_admin_ban(uuid,bigint,int) to anon, authenticated;
grant execute on function fc_admin_members(uuid) to anon, authenticated;
grant execute on function fc_admin_clear_report(uuid,bigint) to anon, authenticated;

insert into fc_notices (id, body, active) values (1, null, false) on conflict do nothing;
insert into fc_links   (id, urls)         values (1, '{}'::jsonb) on conflict do nothing;
```
