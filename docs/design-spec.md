# 금샘탕을 운영하시는 강다운 사장님 팬클럽 — 디자인 스펙

> **현재 구현 상태:** 스킨은 **픽셀 한 종으로 고정**됐다. 손그림(스킨 A)은
> 페이지에서 제거됐고, 아래 A-1~A-7은 되돌릴 때를 위한 기록으로 남긴다.
> 대제목만은 예외로, 스킨 A의 레터링(납작한 파랑 글씨 + '팬' 한 글자 빨강,
> 아웃라인·그림자 없음)이 픽셀 화면에도 그대로 쓰인다.

> **산출물 제약:** 단일 HTML 파일(인라인 CSS/JS). 외부 리소스는 **Google Fonts만** 허용.
> **레퍼런스:** `금샘탕 도감` 포스터 — 하늘색 배경 / 흰 카드 / 손그림 선화 / 계란후라이 캐릭터 / 올드스쿨 엠블럼.
> **스킨 2종:** `A 손그림(도감)` · `B 픽셀`. **레이아웃·DOM·컴포넌트 구조는 완전 공용**, 바뀌는 건 색·폰트·테두리·그림자·아이콘·모션뿐.

---

## 0. 스킨 시스템

루트 엘리먼트에 스킨과 테마를 각각 찍는다. 두 축은 독립이다(스킨 2 × 테마 2 = 4가지 조합 전부 성립).

```html
<html lang="ko" data-skin="doodle" data-theme="auto">
```

| 속성 | 값 | 의미 |
|---|---|---|
| `data-skin` | `doodle` (기본) / `pixel` | 비주얼 스킨 |
| `data-theme` | `auto` (기본) / `light` / `dark` | 컬러 테마 |

```css
/* 캐스케이드 순서 — 반드시 이 순서로 */
/* 1) 공용 구조 토큰 (스킨 무관)            */
/* 2) [data-skin="doodle"] 라이트 값        */
/* 3) [data-skin="doodle"] 다크 값 (auto+명시) */
/* 4) [data-skin="pixel"]  라이트 값        */
/* 5) [data-skin="pixel"]  다크 값 (auto+명시) */
```

### 철칙 3가지

1. **토큰 이름은 두 스킨이 100% 동일하다.** 스킨은 *값만* 바꾼다. 스킨 전용 변수를 새로 만들지 않는다.
2. 새 변수가 필요하면 **양쪽 스킨 모두에 같은 이름으로 정의**한다. 한쪽에서 안 쓰더라도 무해한 값(`none`, `0`, `1px`)을 넣어 둔다.
3. 컴포넌트 CSS는 **토큰만 참조**한다. `#fff`, `2px solid black`, `border-radius:12px` 같은 하드코딩 금지.

---

## 1. 공용 토큰 사전

모든 컴포넌트가 참조하는 변수 목록. **스킨 A/B 모두 이 표의 이름을 전부 정의한다.**

### 1-1. 컬러 슬롯 (19개)

| 변수 | 역할 | 비고 |
|---|---|---|
| `--bg` | 페이지 배경 | |
| `--bg-deep` | 배경 하단 그라데이션 / 푸터 띠 | |
| `--bg-soft` | 입력창 focus 배경, 선택 영역 | |
| `--card` | 카드 바탕 | |
| `--card-2` | 서브 카드 / 인용 / 입력창 바닥 | |
| `--ink` | 본문 텍스트 | |
| `--line` | 테두리 · 선화 stroke · 오프셋 그림자 색 | **그림자 색도 이 토큰** |
| `--ink-soft` | 보조 본문 | |
| `--grey` | 메타 텍스트(시간·조회수) | 카드 위에서만 사용 |
| `--grey-mute` | 장식선·비활성 아이콘 | **텍스트 금지** |
| `--grey-line` | 리스트 구분선 | |
| `--yolk` | 노른자 — 강조 / 대제목 fill / 선택 상태 | 두 스킨 공통 주인공 |
| `--yolk-deep` | 노른자 눌림·음영 | |
| `--red` | 로고 레드 / 삭제·신고 / 좋아요 활성 | |
| `--blue` | 로고 블루 — **면·선 전용** | |
| `--blue-ink` | 링크 텍스트 / 포커스 링 | 대비 확보한 값 |
| `--leaf` | 엠블럼 그린 — 뱃지 면색 | |
| `--leaf-ink` | 성공 메시지 텍스트 | |
| `--plum` | 온천마크 자주 — 인기글 뱃지 | |
| `--egg-w` | 계란 흰자(캐릭터 SVG 전용 면색) | SVG가 참조 |

### 1-2. 형태 슬롯 (11개)

| 변수 | 역할 | A(손그림) 성향 | B(픽셀) 성향 |
|---|---|---|---|
| `--bd` | 기본 테두리 | `2px solid` | `3px solid` |
| `--bd-thick` | 강조 테두리 | `3px solid` | `4px solid` |
| `--r-a` | 비뚤 라운드 A (카드) | 4방향 불균등 | `0` |
| `--r-b` | 비뚤 라운드 B (교차 배치) | 4방향 불균등 | `0` |
| `--r-pill` | 알약형 (버튼·태그) | 큰 불균등 라운드 | `0` |
| `--sh` | 오프셋 하드 그림자 | `4px 4px 0` | `4px 4px 0` |
| `--sh-sm` / `--sh-lg` | 소/대 그림자 | | |
| `--sh-press` | 눌린 상태 그림자 | `1px 1px 0` | `0 0 0` |
| `--clip` | 모서리 깎기 clip-path | `none` | 8비트 계단 polygon |
| `--tex` | 표면 패턴 배경 | `none` | 체커/스캔라인 그라데이션 |
| `--ease` | 이징 | `cubic-bezier(.34,1.56,.64,1)` | `steps(N)` |

### 1-3. 타이포 슬롯 (4개) · 레이아웃 슬롯

| 변수 | 역할 |
|---|---|
| `--font-display` | 로고체 / 대제목 / 카운터 숫자 |
| `--font-head` | 섹션 헤더 / 카드 제목 |
| `--font-hand` | 주석 · 캐릭터 대사 · 손글씨 라벨 |
| `--font-body` | 본문 / UI / 메타 |
| `--t-hero` `--t-logo` `--t-count` `--t-h1` `--t-h2` `--t-h3` `--t-body` `--t-ui` `--t-meta` `--t-hand` | 사이즈 스케일 (§ 4-2) |
| `--s1`~`--s16` | 4px 배수 간격 |
| `--wrap` `--gutter` `--tap` | 1024px / 16px / 44px |

### 1-4. 공용 구조 토큰 (스킨 무관, 한 번만 선언)

```css
:root{
  --s1:4px; --s2:8px; --s3:12px; --s4:16px; --s5:20px;
  --s6:24px; --s8:32px; --s10:40px; --s12:48px; --s16:64px;
  --wrap:1024px; --gutter:16px; --tap:44px;
  --dur-fast:120ms; --dur:200ms; --dur-slow:420ms;

  --t-hero:42px; --t-logo:22px; --t-count:30px;
  --t-h1:24px; --t-h2:20px; --t-h3:17px;
  --t-body:15px; --t-ui:14px; --t-meta:12px; --t-hand:16px;
}
@media (min-width:768px){
  :root{
    --t-hero:68px; --t-logo:26px; --t-count:36px;
    --t-h1:28px; --t-h2:22px; --t-h3:18px;
    --t-body:16px; --t-ui:15px; --t-meta:13px; --t-hand:17px;
  }
}
/* 한글 줄바꿈 — 어절 단위로 끊어야 읽힌다 */
h1,h2,h3,p,li,button,label{ word-break:keep-all; overflow-wrap:anywhere; }
body{ background:var(--bg); color:var(--ink); }
```

---

## 2. 두 스킨 대조표

| 기준 | **A — 손그림(도감)** | **B — 픽셀** |
|---|---|---|
| 한 줄 컨셉 | 목욕탕 벽에 붙은 손그림 도감 | 90년대 동네 목욕탕 × 8비트 게임 |
| 배경 `--bg` | `#A4D9E3` (포스터 원본 추출) | `#5AC8E0` (채도 up) |
| 카드 `--card` | `#FFFFFF` | `#F7F7EF` (CRT 오프화이트) |
| 잉크 `--ink` | `#141414` 순수 블랙 | `#0F1626` 패미컴 딥네이비 |
| 노른자 `--yolk` | `#FFE209` | `#FFC90E` (주황기 섞인 도트 노랑) |
| 팔레트 색 수 | 자유 (선화 중심) | **16색 제한** |
| 디스플레이 폰트 | Black Han Sans | Press Start 2P(영문·숫자) + Black Han Sans(한글) |
| 본문 폰트 | Noto Sans KR | Do Hyeon (한글) + Silkscreen (영문·숫자) |
| 테두리 | `2px solid` | `3px solid` |
| 모서리 | 4방향 불균등 라운드 | `radius:0` + `clip-path` 계단 깎기 |
| 그림자 | `4px 4px 0` 오프셋 하드 | `4px 4px 0` 오프셋 하드 (동일) |
| 표면 | 단색 | 체커 패턴 / 스캔라인 |
| 아이콘 | 손그림 stroke SVG (`linecap:round`) | `<rect>` 그리드 SVG (`crispEdges`) |
| 대제목 아웃라인 | `-webkit-text-stroke` + `paint-order` | 1px 스텝 `text-shadow` 계단 쌓기 |
| 모션 이징 | `cubic-bezier(.34,1.56,.64,1)` 탄성 | `steps(2~6)` 계단 |
| 공감 모션 | 스팀이 부드럽게 피어오름 | 도트 스팀이 한 칸씩 점프 |
| 다크 컨셉 | 불 끈 욕장(짙은 청록) + 흰 선화 반전 | 밤하늘 인디고 + 게임보이 아이보리 |

---

# 스킨 A — 손그림(도감)

## A-1. 컨셉

### 한 줄 정의

> **"목욕탕 탈의실 벽에 붙은 손그림 도감을, 그대로 웹으로 옮긴 팬클럽 게시판"**
> 하늘색 타일 벽 위에 흰 종이 카드를 붙이고, 검은 볼펜으로 그린 계란후라이들이 그 사이를 굴러다니는 화면.

### 무드 키워드 5

| # | 키워드 | 화면에서의 의미 |
|---|---|---|
| 1 | **손그림 (Hand-drawn)** | 모든 경계선은 2px 검은 선. 네 모서리 라운드가 서로 다름. 자를 대지 않은 느낌 |
| 2 | **탕 안 수증기 (Steamy)** | 하늘색 배경, 스팀 마크 장식, 공감·로딩 모션은 전부 "김 오르는" 방향 |
| 3 | **올드스쿨 도감 (Field Guide)** | 섹션마다 라벨 + 아이콘 + 주석 글씨. 정보가 "채집"된 것처럼 배치 |
| 4 | **계란후라이 (Yolk)** | 노른자 노랑이 유일한 주인공 색. 강조는 전부 노랑으로 수렴 |
| 5 | **주접스러운 다정함 (Warm & Goofy)** | 빈 상태·에러·성공 메시지까지 캐릭터가 대신 말함. 시스템 말투 금지 |

### 안티 패턴

- 그라데이션 버튼, 글래스모피즘, 블러 배경 → 손그림 세계관이 깨짐
- 부드러운 회색 그림자(`0 4px 12px rgba(0,0,0,.08)`) → **오프셋 하드 그림자만** 사용
- 이모지 남발 → 아이콘은 인라인 SVG 선화로. 이모지는 캡션 톤과 동일하게 포인트 1~2개만
- 네 모서리 동일 `border-radius` → 반드시 4방향 값을 다르게

---

## A-2. 컬러 토큰

포스터 원본 이미지에서 **픽셀 추출**한 값이다.
(추출: 배경 `#A4D9E3` 284,331px · 노른자 `#FEE208` · 로고 블루 `#2FA4D8` · 로고 레드 `#DC3230` · 엠블럼 그린 `#45945D` · 온천마크 자주 `#BC1F56` · 선화 `#000000`)

### 라이트

| 변수 | HEX | 대비비 |
|---|---|---|
| `--bg` | `#A4D9E3` | ink 대비 **11.94:1** |
| `--bg-deep` | `#7FC6D6` | — |
| `--bg-soft` | `#D6EEF4` | — |
| `--card` | `#FFFFFF` | ink 대비 **18.42:1** |
| `--card-2` | `#FBFAF5` | ink 대비 **17.63:1** |
| `--ink` | `#141414` | — |
| `--line` | `#111111` | — |
| `--ink-soft` | `#4A4A4A` | — |
| `--grey` | `#6E7A80` | card 대비 **4.41:1** ✅ |
| `--grey-mute` | `#9AA6AC` | 2.49:1 → **장식 전용** |
| `--grey-line` | `#D9DEE1` | — |
| `--yolk` | `#FFE209` | ink 대비 **14.15:1** |
| `--yolk-deep` | `#E8B800` | — |
| `--red` | `#DB302E` | 흰글씨 **4.69:1** ✅ |
| `--blue` | `#2FA4D8` | 흰배경 텍스트 2.83:1 ❌ → **면·선 전용** |
| `--blue-ink` | `#1B7FAE` | card 대비 **4.47:1** ✅ |
| `--leaf` | `#45945D` | 면색 전용 |
| `--leaf-ink` | `#2E7A46` | card 대비 **5.27:1** ✅ |
| `--plum` | `#BC1F56` | card 대비 **6.05:1** ✅ |
| `--egg-w` | `#FFFFFF` | — |

### 다크

**컨셉:** 불 끈 목욕탕 = "물빛이 남은 짙은 청록". 하늘색의 **색상(hue 192°)은 유지하고 명도만 내린다.**
선화를 검정 → **계란 흰자 아이보리(`#F2EFE4`)로 반전**시키면 어두운 물 위에 흰 계란이 떠 있는 그림이 된다.
**노른자만은 톤을 낮추지 않는다** — 다크에서 유일하게 빛나는 게 노른자여야 감성이 산다.

| 변수 | HEX | 대비비 |
|---|---|---|
| `--bg` | `#0E2A33` | — |
| `--bg-deep` | `#081C23` | — |
| `--bg-soft` | `#1F4A57` | — |
| `--card` | `#1B3A44` | ink 대비 **10.51:1** |
| `--card-2` | `#16333C` | — |
| `--ink` | `#F2EFE4` | 순백 X — 눈 피로 down |
| `--line` | `#EDE8D8` | 선화 반전 |
| `--ink-soft` | `#CFCCC0` | — |
| `--grey` | `#9DB0B7` | card 대비 **5.38:1** ✅ |
| `--grey-mute` | `#5E767F` | 장식 전용 |
| `--grey-line` | `#2C5763` | — |
| `--yolk` | `#FFDE2E` | card 대비 **9.07:1** |
| `--yolk-deep` | `#C9A600` | — |
| `--red` | `#FF6B60` | card 대비 **4.34:1** |
| `--blue` | `#4FBDEA` | 면·선 |
| `--blue-ink` | `#6FD0F5` | card 대비 **6.92:1** ✅ |
| `--leaf` | `#4E9E66` | — |
| `--leaf-ink` | `#6CC98A` | card 대비 **5.97:1** ✅ |
| `--plum` | `#FF7FA8` | card 대비 **5.10:1** ✅ |
| `--egg-w` | `#F2EFE4` | — |

### CSS

```css
[data-skin="doodle"]{
  --bg:#A4D9E3; --bg-deep:#7FC6D6; --bg-soft:#D6EEF4;
  --card:#FFFFFF; --card-2:#FBFAF5;
  --ink:#141414; --line:#111111; --ink-soft:#4A4A4A;
  --grey:#6E7A80; --grey-mute:#9AA6AC; --grey-line:#D9DEE1;
  --yolk:#FFE209; --yolk-deep:#E8B800;
  --red:#DB302E; --blue:#2FA4D8; --blue-ink:#1B7FAE;
  --leaf:#45945D; --leaf-ink:#2E7A46; --plum:#BC1F56;
  --egg-w:#FFFFFF;

  --bd:2px solid var(--line);
  --bd-thick:3px solid var(--line);
  --r-a:18px 22px 20px 24px;
  --r-b:22px 16px 24px 18px;
  --r-pill:40px 38px 42px 36px;
  --sh:4px 4px 0 var(--line);
  --sh-sm:3px 3px 0 var(--line);
  --sh-lg:6px 6px 0 var(--line);
  --sh-press:1px 1px 0 var(--line);
  --clip:none;
  --tex:none;
  --ease:cubic-bezier(.34,1.56,.64,1);

  --font-display:'Black Han Sans','Noto Sans KR',sans-serif;
  --font-head:'Do Hyeon','Noto Sans KR',sans-serif;
  --font-hand:'Gaegu','Noto Sans KR',cursive;
  --font-body:'Noto Sans KR',system-ui,sans-serif;
}

/* 다크 — auto 모드 */
@media (prefers-color-scheme: dark){
  [data-skin="doodle"]:not([data-theme="light"]){
    --bg:#0E2A33; --bg-deep:#081C23; --bg-soft:#1F4A57;
    --card:#1B3A44; --card-2:#16333C;
    --ink:#F2EFE4; --line:#EDE8D8; --ink-soft:#CFCCC0;
    --grey:#9DB0B7; --grey-mute:#5E767F; --grey-line:#2C5763;
    --yolk:#FFDE2E; --yolk-deep:#C9A600;
    --red:#FF6B60; --blue:#4FBDEA; --blue-ink:#6FD0F5;
    --leaf:#4E9E66; --leaf-ink:#6CC98A; --plum:#FF7FA8;
    --egg-w:#F2EFE4;
  }
}
/* 다크 — 명시 선택 */
[data-skin="doodle"][data-theme="dark"]{
  --bg:#0E2A33; --bg-deep:#081C23; --bg-soft:#1F4A57;
  --card:#1B3A44; --card-2:#16333C;
  --ink:#F2EFE4; --line:#EDE8D8; --ink-soft:#CFCCC0;
  --grey:#9DB0B7; --grey-mute:#5E767F; --grey-line:#2C5763;
  --yolk:#FFDE2E; --yolk-deep:#C9A600;
  --red:#FF6B60; --blue:#4FBDEA; --blue-ink:#6FD0F5;
  --leaf:#4E9E66; --leaf-ink:#6CC98A; --plum:#FF7FA8;
  --egg-w:#F2EFE4;
}

[data-skin="doodle"] body{
  background:radial-gradient(120% 80% at 50% 0%, var(--bg) 0%, var(--bg-deep) 100%) fixed;
}
```

> **다크모드 주의:** `--line`이 밝아지므로 `--sh` 오프셋 그림자도 자동으로 아이보리가 된다.
> 검은 그림자를 하드코딩하지 말 것. 전부 `var(--line)` 참조.

---

## A-3. 타이포그래피

### 폰트 선정 근거

포스터의 `금샘탕 도감` 레터링을 분해하면:
**① 획이 매우 굵다(볼드 이상) ② 획 끝이 각지고 뭉툭하다 ③ 자소가 네모틀을 꽉 채운다 ④ 세로획이 미세하게 기울어 손글씨 티가 난다.**

| 후보 (Google Fonts) | 평가 | 채택 |
|---|---|---|
| **Black Han Sans** | ①②③ 전부 만족. 초굵은 각진 산세리프 + 네모틀 꽉 참 → `금샘탕 도감` 레터링과 **가장 근접**. ④ 손글씨 불규칙성만 없는데 CSS `rotate`/`skew` + 아웃라인으로 보충 가능 | ✅ **디스플레이** |
| Do Hyeon | 각지고 굵지만 Black Han Sans보다 한 체급 가벼움. 대제목엔 임팩트 부족, **섹션 헤더로 쓰면 자연스러운 위계**가 생김 | ✅ **섹션 헤더** |
| Gaegu | 삐뚤빼뚤 연필 손글씨. 포스터의 작은 **주석 글씨**(`가끔 온도가 같거나 바뀐다`) 역할에 정확히 대응 | ✅ **주석/대사** |
| Jua | 둥글둥글 손글씨. 귀엽지만 각짐이 없어 레터링 재현 실패 | ❌ |
| Nanum Pen Script | 획이 너무 얇고 흘려 씀. 대제목 불가, Gaegu와 역할 중복 | ❌ |
| Gowun Dodum | 본문 가독성은 좋으나 웨이트가 400 하나뿐 → UI 위계를 못 만듦 | ❌ |
| Pretendard | 톤은 맞지만 **Google Fonts에 없음**(jsDelivr 배포) → 외부 리소스 제약 위반 | ❌ |
| **Noto Sans KR** | 400/500/700 제공, 한글 가독성 표준. 본문·UI 담당 | ✅ **본문/UI** |

### 로드 (link 1개)

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Black+Han+Sans&family=Do+Hyeon&family=Gaegu:wght@400;700&family=Noto+Sans+KR:wght@400;500;700&family=Press+Start+2P&family=Silkscreen:wght@400;700&display=swap" rel="stylesheet">
```
> 스킨 B의 `Press Start 2P` / `Silkscreen`까지 **한 번에 받는다.** (둘 다 라틴 서브셋만이라 합쳐 ~20KB. 스킨 전환 시 FOUT 없음)

### 3단 위계 & 사이즈 스케일

모바일 값 → (데스크탑 값). 배수 1.25 기준.

| 레벨 | 토큰 | 폰트 | 크기 | line-height | letter-spacing | 용도 |
|---|---|---|---|---|---|---|
| **D 디스플레이** | `--t-hero` | display | 42 → (68) | 1.05 | -0.02em | `업다운 팬클럽!` |
| | `--t-logo` | display | 22 → (26) | 1.10 | -0.01em | 헤더 로고 `금샘탕` |
| | `--t-count` | display | 30 → (36) | 1.00 | 0 | `00일째` 숫자 |
| **H 헤더** | `--t-h1` | head | 24 → (28) | 1.25 | 0 | 대섹션 |
| | `--t-h2` | head | 20 → (22) | 1.30 | 0 | 섹션 헤더 `인기글` |
| | `--t-h3` | head | 17 → (18) | 1.35 | 0 | 카드 제목 |
| **B 본문/UI** | `--t-body` | body 400 | 15 → (16) | 1.70 | -0.005em | 글 본문 |
| | `--t-ui` | body 500 | 14 → (15) | 1.40 | 0 | 버튼·라벨·탭 |
| | `--t-meta` | body 400 | 12 → (13) | 1.40 | 0 | 시간·카운트 |
| | `--t-hand` | hand 400 | 16 → (17) | 1.50 | 0 | 주석·캐릭터 대사 |

```css
body{font:400 var(--t-body)/1.7 var(--font-body); -webkit-text-size-adjust:100%;}
.t-hero {font:400 var(--t-hero)/1.05 var(--font-display); letter-spacing:-.02em;}
.t-logo {font:400 var(--t-logo)/1.1  var(--font-display); letter-spacing:-.01em;}
.t-count{font:400 var(--t-count)/1   var(--font-display);}
h2      {font:400 var(--t-h2)/1.3    var(--font-head);}
h3      {font:400 var(--t-h3)/1.35   var(--font-head);}
.t-ui   {font:500 var(--t-ui)/1.4    var(--font-body);}
.t-meta {font:400 var(--t-meta)/1.4  var(--font-body); color:var(--grey);}
.t-hand {font:400 var(--t-hand)/1.5  var(--font-hand);}
```

---

## A-4. 레터링 처리법 — "업다운 팬클럽!"

포스터의 `금샘탕 도감`은 **노란 면 + 굵은 검은 아웃라인 + 아래로 떨어진 두께감**이다. 3단으로 재현한다.

### 1) 기본 — `paint-order` (모던 브라우저)

`-webkit-text-stroke`는 획을 **글자 중앙 기준**으로 그려서 획을 갉아먹는다.
`paint-order: stroke fill`을 주면 stroke를 **먼저** 칠하고 fill을 위에 덮어 획 굵기가 보존된다. 이게 핵심.

```css
.lettering{
  font:400 var(--t-hero)/1.05 var(--font-display);
  letter-spacing:-.02em;
  color:var(--yolk);
  -webkit-text-stroke:7px var(--line);
  paint-order:stroke fill;          /* ← 이 한 줄이 전부 */
  text-shadow:0 5px 0 var(--line);  /* 아래로 떨어지는 두께 */
  display:inline-block;
  transform:rotate(-1.4deg);        /* 손글씨 기울기 */
}
@media (min-width:768px){ .lettering{ -webkit-text-stroke-width:10px; text-shadow:0 7px 0 var(--line); } }
```

### 2) 폴백 — 8방향 `text-shadow` 아웃라인

`paint-order` 미지원 시 그림자를 8방향으로 깔아 아웃라인을 흉내낸다.

```css
@supports not (paint-order: stroke){
  .lettering{
    -webkit-text-stroke:0;
    text-shadow:
      -3px -3px 0 var(--line),  0 -3px 0 var(--line),  3px -3px 0 var(--line),
      -3px  0   0 var(--line),                          3px  0   0 var(--line),
      -3px  3px 0 var(--line),  0  3px 0 var(--line),  3px  3px 0 var(--line),
      -4px -1px 0 var(--line),  4px  1px 0 var(--line),
       0    7px 0 var(--line);   /* 두께감 */
  }
}
```

### 3) 글자별 흔들기 — 손글씨 불규칙성

각 글자를 `<span>`으로 쪼개고 `:nth-child`로 회전·오프셋을 다르게 준다. **JS 불필요.**

```html
<h1 class="lettering" aria-label="업다운 팬클럽!">
  <span>업</span><span>다</span><span>운</span><span class="sp"></span>
  <span>팬</span><span>클</span><span>럽</span><span>!</span>
</h1>
```
```css
.lettering span{display:inline-block;}
.lettering .sp{width:.28em;}
.lettering span:nth-child(3n)  {transform:rotate(2.2deg)  translateY(-2px);}
.lettering span:nth-child(3n+1){transform:rotate(-1.8deg) translateY(1px);}
.lettering span:nth-child(4n)  {transform:rotate(1.1deg)  translateY(2px);}
.lettering span:last-child     {transform:rotate(6deg) translateY(-3px); color:var(--red);}
```
> `aria-label`을 반드시 걸 것. span으로 쪼개면 스크린리더가 한 글자씩 끊어 읽는다.

### 4) 양옆 스팀 마크 `{{{`

포스터처럼 제목 좌우에 스팀 3획을 세운다. **SVG 1개를 3번 반복**하고 각도·크기를 다르게.

```html
<div class="hero">
  <div class="steam steam-l" aria-hidden="true">
    <!-- §A-6 스팀 SVG × 3 -->
  </div>
  <h1 class="lettering">…</h1>
  <div class="steam steam-r" aria-hidden="true"><!-- × 3 --></div>
</div>
```
```css
.hero{display:grid; grid-template-columns:auto 1fr auto; align-items:center; gap:var(--s2);}
.steam{display:flex; gap:2px;}
.steam svg{width:16px; height:54px; stroke:var(--line); fill:none;}
.steam svg:nth-child(1){height:40px; transform:rotate(-6deg);}
.steam svg:nth-child(2){height:58px;}
.steam svg:nth-child(3){height:46px; transform:rotate(5deg);}
.steam-r{transform:scaleX(-1);}   /* 오른쪽은 좌우 반전 */
@media (max-width:420px){ .steam svg:nth-child(3){display:none;} } /* 360px에선 2획만 */
```

---

## A-5. 컴포넌트 스타일 가이드

### 카드

```css
.card{
  background:var(--card);
  border:var(--bd);
  border-radius:var(--r-a);
  box-shadow:var(--sh);
  clip-path:var(--clip);
  padding:var(--s5);
  transition:transform var(--dur) var(--ease), box-shadow var(--dur) var(--ease);
}
/* 리스트에서 교차 배치 — 같은 라운드가 반복되면 기계 티가 난다 */
.card:nth-child(even){ border-radius:var(--r-b); }
.card:nth-child(3n)  { transform:rotate(-.4deg); }
.card:nth-child(3n+2){ transform:rotate(.35deg); }

.card:hover{ transform:translate(-2px,-2px) rotate(0deg); box-shadow:var(--sh-lg); }
.card:active{ transform:translate(3px,3px); box-shadow:var(--sh-press); }

.card--sub{ background:var(--card-2); box-shadow:var(--sh-sm); }
```

### 버튼

```css
.btn{
  min-height:var(--tap); padding:0 var(--s5);
  display:inline-flex; align-items:center; justify-content:center; gap:var(--s2);
  font:500 var(--t-ui)/1 var(--font-body);
  border:var(--bd); border-radius:var(--r-pill);
  box-shadow:var(--sh-sm); clip-path:var(--clip);
  cursor:pointer;
  transition:transform var(--dur-fast) var(--ease), box-shadow var(--dur-fast) var(--ease);
}
.btn:hover { transform:translate(-1px,-1px); box-shadow:var(--sh); }
.btn:active{ transform:translate(3px,3px);   box-shadow:var(--sh-press); }

.btn--primary{ background:var(--yolk); color:var(--ink); }   /* 14.15:1 */
.btn--primary:active{ background:var(--yolk-deep); }
.btn--ghost  { background:var(--card); color:var(--ink); }
.btn--danger { background:var(--red);  color:var(--card); }  /* 4.69:1 */
.btn[disabled]{ background:var(--grey-line); color:var(--grey); box-shadow:none;
                transform:none; cursor:not-allowed; }
```

### 입력창

```css
.field{
  width:100%; min-height:var(--tap); padding:var(--s3) var(--s4);
  font:400 var(--t-body)/1.5 var(--font-body);
  color:var(--ink); background:var(--card-2);
  border:var(--bd); border-radius:var(--r-b);
  box-shadow:inset 2px 2px 0 rgb(0 0 0 / .05);
  clip-path:var(--clip);
}
.field::placeholder{ color:var(--grey); font-family:var(--font-hand); }
.field:focus-visible{
  outline:3px solid var(--blue-ink); outline-offset:2px;
  background:var(--bg-soft);
}
textarea.field{ min-height:120px; resize:vertical; line-height:1.7; }
```

### 태그 / 뱃지

```css
.tag{
  display:inline-flex; align-items:center; gap:4px;
  height:26px; padding:0 10px;
  font:500 var(--t-meta)/1 var(--font-body);
  border:var(--bd); border-radius:var(--r-pill);
  background:var(--card); color:var(--ink);
  clip-path:var(--clip);
}
.tag--hot { background:var(--plum); color:var(--card); border-color:var(--line); }
.tag--new { background:var(--yolk); color:var(--ink); }
.tag--mine{ background:var(--leaf); color:var(--card); }
.tag--notice{ background:var(--blue); color:var(--ink); } /* blue는 면색으로만 */
```

### 모달 / 팝업 (활동규칙 · 비번입력)

```css
.modal-back{
  position:fixed; inset:0; z-index:90;
  background:color-mix(in srgb, var(--ink) 55%, transparent);
  display:grid; place-items:end center;          /* 모바일: 바텀시트 */
  padding:0;
}
.modal{
  width:100%; max-width:480px;
  background:var(--card);
  border:var(--bd-thick); border-bottom:0;
  border-radius:24px 20px 0 0;
  box-shadow:0 -4px 0 var(--line);
  padding:var(--s6) var(--s5) calc(var(--s6) + env(safe-area-inset-bottom));
  animation:sheet-up var(--dur-slow) var(--ease);
}
.modal::before{                                   /* 손잡이 바 */
  content:""; display:block; width:52px; height:5px; margin:0 auto var(--s5);
  background:var(--grey-mute); border-radius:99px;
}
@media (min-width:768px){
  .modal-back{ place-items:center; padding:var(--s6); }
  .modal{ border:var(--bd-thick); border-radius:var(--r-a);
          box-shadow:var(--sh-lg); animation:pop-in var(--dur) var(--ease); }
}
@keyframes sheet-up{ from{ transform:translateY(100%); } to{ transform:none; } }
@keyframes pop-in  { from{ transform:scale(.92) rotate(-1deg); opacity:0; } to{ transform:none; opacity:1; } }

/* 비번입력 — 4칸 도트 */
.pin{ display:flex; gap:var(--s3); justify-content:center; }
.pin i{
  width:44px; height:52px; display:grid; place-items:center;
  background:var(--card-2); border:var(--bd); border-radius:var(--r-b);
  font:400 24px/1 var(--font-display);
}
.pin i[data-filled]{ background:var(--yolk); }
.pin.is-wrong{ animation:shake 360ms var(--ease); }
@keyframes shake{ 0%,100%{transform:none} 25%{transform:translateX(-7px) rotate(-1deg)}
                  50%{transform:translateX(7px) rotate(1deg)} 75%{transform:translateX(-4px)} }
```

### 좋아요(공감) 버튼 — 계란 + 스팀 모티프

계란을 누르면 **노른자가 부풀고, 스팀 3줄이 위로 피어오르고, 카운트 숫자가 갈아끼워진다.**

```html
<button class="like" aria-pressed="false" aria-label="공감">
  <span class="like__egg"><!-- §A-6 반짝 계란 SVG --></span>
  <span class="like__steam" aria-hidden="true"><i></i><i></i><i></i></span>
  <span class="like__n"><b>12</b></span>
</button>
```
```css
.like{
  position:relative; min-height:var(--tap); padding:0 var(--s4) 0 var(--s2);
  display:inline-flex; align-items:center; gap:var(--s2);
  background:var(--card); border:var(--bd); border-radius:var(--r-pill);
  box-shadow:var(--sh-sm); clip-path:var(--clip); cursor:pointer;
}
.like__egg svg{ width:30px; height:30px; display:block;
  transition:transform var(--dur) var(--ease); }
.like[aria-pressed="true"]{ background:var(--yolk); }
.like[aria-pressed="true"] .like__egg svg{ transform:scale(1.18) rotate(-8deg); }

/* 스팀 3줄 — 눌린 순간만 피어오름 */
.like__steam{ position:absolute; top:-6px; left:16px; display:flex; gap:5px; pointer-events:none; }
.like__steam i{
  width:3px; height:14px; background:var(--line); border-radius:99px;
  opacity:0; transform:translateY(4px);
}
.like.is-pop .like__steam i{ animation:puff 640ms var(--ease) forwards; }
.like.is-pop .like__steam i:nth-child(2){ animation-delay:70ms; }
.like.is-pop .like__steam i:nth-child(3){ animation-delay:140ms; }
@keyframes puff{
  0%  { opacity:0; transform:translateY(4px)   scaleY(.4); }
  35% { opacity:1; transform:translateY(-10px) scaleY(1); }
  100%{ opacity:0; transform:translateY(-26px) scaleY(1.3) translateX(3px); }
}

/* 카운트 롤업 — 숫자가 위로 갈아끼워짐 */
.like__n{ overflow:hidden; height:1.2em; font:500 var(--t-ui)/1.2 var(--font-body); }
.like.is-pop .like__n b{ animation:roll 280ms var(--ease); }
@keyframes roll{ from{ transform:translateY(100%); opacity:0; } to{ transform:none; opacity:1; } }
```
```js
btn.addEventListener('click', () => {
  const on = btn.getAttribute('aria-pressed') === 'true';
  btn.setAttribute('aria-pressed', String(!on));
  btn.querySelector('b').textContent = String(n + (on ? 0 : 1));
  if (!on){ btn.classList.remove('is-pop'); void btn.offsetWidth; btn.classList.add('is-pop'); }
});
```

### 섹션 헤더 (아이콘 + 라벨)

포스터의 주석선 느낌을 살려 **라벨 오른쪽으로 점선이 쭉 뻗는다.**

```html
<h2 class="sec">
  <span class="sec__ico"><!-- 인라인 SVG 20×20 --></span>
  <span class="sec__label">최근 주접</span>
  <span class="sec__note t-hand">사장님 몰래 씁니다</span>
</h2>
```
```css
.sec{ display:flex; align-items:center; gap:var(--s2); margin:var(--s8) 0 var(--s4); }
.sec__ico{ width:30px; height:30px; display:grid; place-items:center; flex:0 0 auto;
  background:var(--yolk); border:var(--bd); border-radius:var(--r-pill);
  box-shadow:var(--sh-sm); clip-path:var(--clip); }
.sec__ico svg{ width:18px; height:18px; stroke:var(--line); fill:none; }
.sec__label{ font:400 var(--t-h2)/1.3 var(--font-head); color:var(--ink); }
.sec__note{ color:var(--ink-soft); white-space:nowrap; }
.sec::after{ content:""; flex:1 1 auto; height:0;
  border-top:2px dashed var(--grey-mute); margin-left:var(--s2); }
@media (max-width:420px){ .sec__note{ display:none; } }
```

### 빈 상태 (empty state) — 멍~ 계란

```html
<div class="empty">
  <!-- §A-6 멍 계란 SVG -->
  <p class="empty__t t-hand">아직 아무도 안 왔어요..</p>
  <p class="empty__s">첫 주접의 주인공이 되어보기로</p>
  <button class="btn btn--primary">글 남기기</button>
</div>
```
```css
.empty{
  display:grid; justify-items:center; gap:var(--s3);
  padding:var(--s12) var(--s5);
  background:var(--card-2); border:2px dashed var(--grey-mute);
  border-radius:var(--r-a); clip-path:var(--clip);
}
.empty svg{ width:96px; height:auto; opacity:.9;
  animation:bob 3.2s ease-in-out infinite; }
.empty__t{ font-size:calc(var(--t-hand) + 2px); color:var(--ink); }
.empty__s{ font:400 var(--t-meta)/1.5 var(--font-body); color:var(--grey); }
@keyframes bob{ 0%,100%{transform:translateY(0) rotate(-2deg)} 50%{transform:translateY(-6px) rotate(2deg)} }
```

**빈 상태 카피 (섹션별)** — 시스템 말투 금지, 캐릭터가 말한다.

| 섹션 | 카피 |
|---|---|
| 인기글 | `아직 인기 터진 글이 없어요.. / 지금 쓰면 1등` |
| 최근 주접 | `아직 아무도 안 왔어요.. / 첫 주접의 주인공이 되어보기로` |
| 인사해요 | `조용하네요, 탕에 물만 차는 중.. / 인사 한 줄 남기고 가요` |
| 팬미팅 | `질문 대기 중.. / 사장님께 궁금한 거 하나쯤 있잖아요?!` |
| 검색결과 없음 | `못 찾았어요.. / 다른 말로 한 번 더 찾아볼까요` |

---

## A-6. 계란 캐릭터 SVG (손그림)

**공통 규칙**
- 색은 전부 토큰 참조 → `fill="var(--egg-w)"`, `stroke="var(--line)"`. 다크모드에서 자동 반전된다.
- `stroke-linecap="round" stroke-linejoin="round"` + `vector-effect="non-scaling-stroke"` → 크기 바뀌어도 선 굵기 유지.
- 장식용이면 `aria-hidden="true"`, 의미가 있으면 `role="img"` + `<title>`.
- 흰자 외곽선은 일부러 정원(正圓)이 아니다. 좌표를 건드려 더 찌그러뜨려도 된다.

### ① 반짝 (기본 / 좋아요 / 성공)

```html
<svg viewBox="0 0 120 104" width="72" height="62" role="img" aria-labelledby="eg1">
  <title id="eg1">신난 계란후라이</title>
  <g fill="none" stroke="var(--line)" stroke-width="3.2"
     stroke-linecap="round" stroke-linejoin="round" vector-effect="non-scaling-stroke">
    <!-- 흰자 -->
    <path fill="var(--egg-w)" d="M108 54 Q104 30 90 24 Q76 12 60 18 Q40 10 29 23
      Q12 32 14 54 Q12 74 33 81 Q44 94 60 88 Q80 94 88 82 Q110 76 108 54 Z"/>
    <!-- 노른자 -->
    <ellipse fill="var(--yolk)" cx="58" cy="52" rx="21" ry="19"/>
    <!-- 눈 -->
    <ellipse fill="var(--line)" stroke="none" cx="50" cy="48" rx="2.7" ry="3.6"/>
    <ellipse fill="var(--line)" stroke="none" cx="66" cy="48" rx="2.7" ry="3.6"/>
    <!-- 입 -->
    <path d="M51 59 Q58 66 65 58" stroke-width="2.8"/>
    <!-- 팔 -->
    <path d="M36 62 Q28 66 26 73" stroke-width="2.6"/>
    <path d="M80 62 Q88 66 90 73" stroke-width="2.6"/>
  </g>
  <!-- 반짝 -->
  <g fill="var(--yolk)" stroke="var(--line)" stroke-width="2" stroke-linejoin="round">
    <path d="M20 18 L23 25 L30 28 L23 31 L20 38 L17 31 L10 28 L17 25 Z"/>
    <path d="M100 12 L102 17 L107 19 L102 21 L100 26 L98 21 L93 19 L98 17 Z"/>
  </g>
</svg>
```

### ② 졸림 (로딩 / 대기 / 심야)

```html
<svg viewBox="0 0 120 104" width="72" height="62" role="img" aria-labelledby="eg2">
  <title id="eg2">졸고 있는 계란후라이</title>
  <g fill="none" stroke="var(--line)" stroke-width="3.2"
     stroke-linecap="round" stroke-linejoin="round" vector-effect="non-scaling-stroke">
    <path fill="var(--egg-w)" d="M104 58 Q106 36 92 28 Q78 16 60 22 Q40 14 28 28
      Q12 36 16 58 Q14 76 34 83 Q46 94 62 89 Q80 94 88 84 Q106 78 104 58 Z"/>
    <ellipse fill="var(--yolk)" cx="57" cy="56" rx="21" ry="18"/>
    <!-- 감은 눈 -->
    <path d="M45 52 Q50 57 55 52" stroke-width="2.8"/>
    <path d="M61 52 Q66 57 71 52" stroke-width="2.8"/>
    <!-- 벌어진 입 -->
    <ellipse fill="var(--line)" stroke="none" cx="57" cy="65" rx="3.4" ry="4.4"/>
    <!-- 늘어진 팔 -->
    <path d="M33 68 Q24 72 20 78" stroke-width="2.6"/>
  </g>
  <!-- zZ -->
  <g fill="none" stroke="var(--line)" stroke-width="3"
     stroke-linecap="round" stroke-linejoin="round">
    <path d="M88 24 L100 24 L88 36 L100 36"/>
    <path d="M104 6 L112 6 L104 14 L112 14"/>
  </g>
</svg>
```

### ③ 멍~ (빈 상태 / 404 / 결과 없음)

```html
<svg viewBox="0 0 120 104" width="72" height="62" role="img" aria-labelledby="eg3">
  <title id="eg3">멍때리는 계란후라이</title>
  <g fill="none" stroke="var(--line)" stroke-width="3.2"
     stroke-linecap="round" stroke-linejoin="round" vector-effect="non-scaling-stroke">
    <path fill="var(--egg-w)" d="M106 52 Q102 28 88 22 Q74 10 58 17 Q38 9 27 24
      Q10 34 15 55 Q13 75 32 82 Q45 93 61 87 Q79 93 87 81 Q108 74 106 52 Z"/>
    <ellipse fill="var(--yolk)" cx="59" cy="51" rx="20" ry="18"/>
    <!-- 점 눈 (멀찍이) -->
    <circle fill="var(--line)" stroke="none" cx="50" cy="49" r="2.5"/>
    <circle fill="var(--line)" stroke="none" cx="68" cy="49" r="2.5"/>
    <!-- 일자 입 -->
    <path d="M55 61 L64 61" stroke-width="2.8"/>
  </g>
  <!-- 멍~ 물결 -->
  <path d="M92 28 Q97 22 102 28 Q107 34 112 28" fill="none"
        stroke="var(--line)" stroke-width="2.6" stroke-linecap="round"/>
</svg>
```

### ④ 스팀 마크 (1획) — 3개 반복해서 `{{{`

```html
<svg viewBox="0 0 20 60" width="16" height="48" aria-hidden="true">
  <path d="M10 4 C3 12 17 18 10 26 C3 34 17 40 10 48 C6 52 8 56 11 58"
        fill="none" stroke="var(--line)" stroke-width="5.5"
        stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### ⑤ 원형 엠블럼 배지 (금샘탕 올드스쿨)

```html
<svg viewBox="0 0 100 100" width="80" height="80" role="img" aria-labelledby="em1">
  <title id="em1">금샘탕 엠블럼</title>
  <defs>
    <path id="laurel" d="M26 76 Q13 54 26 30"/>
  </defs>
  <!-- 배지 바닥 -->
  <circle cx="50" cy="50" r="46" fill="var(--yolk)" stroke="var(--line)" stroke-width="3"/>
  <circle cx="50" cy="50" r="39" fill="none" stroke="var(--line)" stroke-width="1.6"
          stroke-dasharray="5 4"/>
  <!-- 월계수 (왼쪽 그리고 미러) -->
  <g fill="none" stroke="var(--leaf)" stroke-width="3" stroke-linecap="round">
    <use href="#laurel"/>
    <use href="#laurel" transform="translate(100,0) scale(-1,1)"/>
  </g>
  <g fill="var(--leaf)" stroke="var(--line)" stroke-width="1.2">
    <ellipse cx="20" cy="66" rx="6" ry="3.4" transform="rotate(-28 20 66)"/>
    <ellipse cx="17" cy="54" rx="6" ry="3.4" transform="rotate(-6 17 54)"/>
    <ellipse cx="20" cy="42" rx="6" ry="3.4" transform="rotate(18 20 42)"/>
    <ellipse cx="80" cy="66" rx="6" ry="3.4" transform="rotate(28 80 66)"/>
    <ellipse cx="83" cy="54" rx="6" ry="3.4" transform="rotate(6 83 54)"/>
    <ellipse cx="80" cy="42" rx="6" ry="3.4" transform="rotate(-18 80 42)"/>
  </g>
  <!-- 온천 마크 : 탕 + 김 3줄 -->
  <path d="M33 68 Q50 60 67 68 Q50 75 33 68 Z" fill="var(--blue)"
        stroke="var(--line)" stroke-width="2" stroke-linejoin="round"/>
  <g fill="none" stroke="var(--plum)" stroke-width="4" stroke-linecap="round">
    <path d="M40 56 C35 50 45 47 40 41"/>
    <path d="M50 54 C45 48 55 45 50 39"/>
    <path d="M60 56 C55 50 65 47 60 41"/>
  </g>
  <!-- 별 3 -->
  <g fill="var(--card)" stroke="var(--line)" stroke-width="1.4" stroke-linejoin="round">
    <path d="M50 14 L52 20 L58 22 L52 24 L50 30 L48 24 L42 22 L48 20 Z"/>
    <path d="M35 20 L36.5 24 L41 25.5 L36.5 27 L35 31 L33.5 27 L29 25.5 L33.5 24 Z"/>
    <path d="M65 20 L66.5 24 L71 25.5 L66.5 27 L65 31 L63.5 27 L59 25.5 L63.5 24 Z"/>
  </g>
</svg>
```

---

## A-7. 마이크로 인터랙션 & 모션 (스킨 A)

| 대상 | 트리거 | 동작 | 시간 |
|---|---|---|---|
| 카드 | hover | `translate(-2,-2)` + 그림자 `4px→6px`, 기울기 0으로 정렬 | 200ms `--ease` |
| 카드 / 버튼 | active | `translate(3,3)` + 그림자 `1px` (**눌려 들어가는 종이**) | 120ms |
| 좋아요 | click | 노른자 `scale(1.18) rotate(-8deg)` + 스팀 3줄 순차 상승 + 숫자 롤업 | 640ms |
| FAB | hover | `rotate(-6deg) scale(1.06)` | 200ms |
| 섹션 | 진입 | `translateY(14px)+opacity 0` → 정위치, 순차 80ms stagger | 420ms |
| 대제목 | 최초 1회 | 글자별 `scale(.7)→1` 순차 40ms stagger | 400ms |
| 모달 | open | 모바일 바텀시트 슬라이드업 / 데스크탑 `scale(.92) rotate(-1deg)` → 팝 | 200~420ms |
| 비번 오답 | 실패 | `shake` 좌우 흔들림 | 360ms |
| 로딩 | pending | 졸린 계란 `bob` 상하 + `zZ` 페이드 반복 | 3.2s loop |

```css
/* 페이지 진입 — IntersectionObserver 없이 CSS만 */
.reveal{ opacity:0; transform:translateY(14px);
  animation:reveal var(--dur-slow) var(--ease) forwards; }
.reveal:nth-of-type(1){animation-delay:.00s} .reveal:nth-of-type(2){animation-delay:.08s}
.reveal:nth-of-type(3){animation-delay:.16s} .reveal:nth-of-type(4){animation-delay:.24s}
.reveal:nth-of-type(5){animation-delay:.32s} .reveal:nth-of-type(6){animation-delay:.40s}
@keyframes reveal{ to{ opacity:1; transform:none; } }

/* 대제목 등장 */
.lettering span{ animation:letter-pop 400ms var(--ease) backwards; }
.lettering span:nth-child(1){animation-delay:.04s} .lettering span:nth-child(2){animation-delay:.08s}
.lettering span:nth-child(3){animation-delay:.12s} .lettering span:nth-child(5){animation-delay:.16s}
.lettering span:nth-child(6){animation-delay:.20s} .lettering span:nth-child(7){animation-delay:.24s}
.lettering span:nth-child(8){animation-delay:.30s}
@keyframes letter-pop{ from{ opacity:0; transform:scale(.7) translateY(10px); } }
```

### `prefers-reduced-motion` 대응

**전부 끄지 않는다.** 이동·회전·스케일만 죽이고 **opacity 전환은 남긴다** (상태 변화는 여전히 보여야 함).

```css
@media (prefers-reduced-motion: reduce){
  *, *::before, *::after{
    animation-duration:.01ms !important;
    animation-iteration-count:1 !important;
    transition-duration:.01ms !important;
    scroll-behavior:auto !important;
  }
  .reveal{ opacity:1; transform:none; animation:none; }
  .card:hover, .btn:hover, .fab:hover{ transform:none; }
  .card:active,.btn:active{ transform:none; box-shadow:var(--sh-press); } /* 피드백은 그림자로 */
  .like[aria-pressed="true"]{ outline:3px solid var(--line); outline-offset:2px; } /* 모션 대신 테두리 */
  .empty svg{ animation:none; }
}
```

---

# 스킨 B — 픽셀

## B-1. 컨셉

### 한 줄 정의

> **"90년대 동네 목욕탕 앞 오락실, 그 화면 안에 들어간 금샘탕"**
> 계란후라이는 16×16 스프라이트가 되고, 탕은 타일맵이 되고, 공감 카운트는 게임 스코어가 된다.

### 무드 키워드 5

| # | 키워드 | 화면에서의 의미 |
|---|---|---|
| 1 | **8비트 스프라이트 (Sprite)** | 모든 아이콘이 `<rect>` 격자. 대각선·곡선 금지, 계단으로만 |
| 2 | **제한 팔레트 (16 Colors)** | 색을 16개로 묶는다. 중간톤 금지 — 있는 색만 재사용 |
| 3 | **하드 엣지 (Crisp)** | `border-radius:0`, 안티앨리어싱 억제, 정수 px만 사용 |
| 4 | **동네 오락실 (Arcade)** | 카운터는 스코어, 버튼은 A/B 버튼, 로딩은 `NOW LOADING...` |
| 5 | **목욕탕 타일 (Tilemap)** | 배경은 체커·스캔라인 패턴. 여백조차 타일처럼 규칙적 |

### 안티 패턴

- 부드러운 곡선, `border-radius`, 그라데이션 → 즉시 픽셀감 소멸
- 소수점 px (`padding:7.5px`) → 격자가 깨진다. **4의 배수만**
- 픽셀 SVG를 소수 배율로 확대 (`width:37px`) → 뭉개짐. **정수 배율만** (16/32/48/64/80)
- 반투명 오버레이 → 딕셀(dithering) 패턴으로 대체

---

## B-2. 컬러 토큰 (동일 변수명, 값만 교체)

**16색 제한 팔레트.** 하늘색 배경·노른자·로고 빨강/파랑 계보는 계승하되 채도를 올리고 중간톤을 제거했다.

### 라이트

| 변수 | HEX | 메모 | 대비비 |
|---|---|---|---|
| `--bg` | `#5AC8E0` | 채도 올린 하늘 (도트 배경) | ink 대비 **9.26:1** |
| `--bg-deep` | `#2E9BC4` | 체커 패턴 짝수칸 / 푸터 | — |
| `--bg-soft` | `#A8E6F2` | focus 배경 | — |
| `--card` | `#F7F7EF` | CRT 오프화이트 | ink 대비 **16.77:1** |
| `--card-2` | `#E0E6E0` | 서브 면 | ink 대비 **14.24:1** |
| `--ink` | `#0F1626` | 패미컴 딥네이비 (순검정보다 레트로) | — |
| `--line` | `#0F1626` | ink와 동일 — 도트는 선/면 구분이 없다 | — |
| `--ink-soft` | `#3C4A66` | — | — |
| `--grey` | `#4E5F78` | card 대비 **6.04:1** ✅ | |
| `--grey-mute` | `#9AA8BC` | 장식 전용 | — |
| `--grey-line` | `#C3CDD9` | — | — |
| `--yolk` | `#FFC90E` | 주황기 섞인 도트 노랑 | ink 대비 **11.70:1** |
| `--yolk-deep` | `#E08A00` | 노른자 음영(도트 셰이딩용) | — |
| `--red` | `#D42121` | card 텍스트 **4.83:1** ✅ | |
| `--blue` | `#1B8FE0` | 면·선 전용 (텍스트 3.22:1 ❌) | — |
| `--blue-ink` | `#0F5FB0` | card 대비 **5.94:1** ✅ | |
| `--leaf` | `#2FA84F` | 면색 | — |
| `--leaf-ink` | `#1E7A38` | card 대비 **5.01:1** ✅ | |
| `--plum` | `#C2185B` | card 대비 **5.46:1** ✅ | |
| `--egg-w` | `#FFFFFF` | 스프라이트 흰자 | — |

### 다크

**컨셉:** 전원 켠 브라운관. 배경은 **패미컴 밤하늘 인디고**, 글자는 **게임보이 아이보리(살짝 그린 기)**. 노른자는 더 밝게 태운다.

| 변수 | HEX | 대비비 |
|---|---|---|
| `--bg` | `#0B1026` | — |
| `--bg-deep` | `#05070F` | — |
| `--bg-soft` | `#1C2A50` | — |
| `--card` | `#151C38` | ink 대비 **14.66:1** |
| `--card-2` | `#101733` | — |
| `--ink` | `#EAF3E0` | 게임보이 아이보리 |
| `--line` | `#EAF3E0` | — |
| `--ink-soft` | `#C2D0BC` | — |
| `--grey` | `#8FA0C0` | card 대비 **6.34:1** ✅ |
| `--grey-mute` | `#4B5A80` | 장식 전용 |
| `--grey-line` | `#2A3660` | — |
| `--yolk` | `#FFD23F` | card 대비 **11.59:1** |
| `--yolk-deep` | `#C98A00` | — |
| `--red` | `#FF5C5C` | card 대비 **5.53:1** ✅ |
| `--blue` | `#4FA9FF` | 면·선 |
| `--blue-ink` | `#79C3FF` | card 대비 **8.81:1** ✅ |
| `--leaf` | `#2FA84F` | 면색 |
| `--leaf-ink` | `#6BE59A` | card 대비 **10.60:1** ✅ |
| `--plum` | `#FF6BA8` | card 대비 **6.31:1** ✅ |
| `--egg-w` | `#EAF3E0` | — |

### CSS

```css
[data-skin="pixel"]{
  --bg:#5AC8E0; --bg-deep:#2E9BC4; --bg-soft:#A8E6F2;
  --card:#F7F7EF; --card-2:#E0E6E0;
  --ink:#0F1626; --line:#0F1626; --ink-soft:#3C4A66;
  --grey:#4E5F78; --grey-mute:#9AA8BC; --grey-line:#C3CDD9;
  --yolk:#FFC90E; --yolk-deep:#E08A00;
  --red:#D42121; --blue:#1B8FE0; --blue-ink:#0F5FB0;
  --leaf:#2FA84F; --leaf-ink:#1E7A38; --plum:#C2185B;
  --egg-w:#FFFFFF;

  --bd:3px solid var(--line);
  --bd-thick:4px solid var(--line);
  --r-a:0; --r-b:0; --r-pill:0;
  --sh:4px 4px 0 var(--line);
  --sh-sm:3px 3px 0 var(--line);
  --sh-lg:6px 6px 0 var(--line);
  --sh-press:0 0 0 var(--line);
  --clip:polygon(6px 0,calc(100% - 6px) 0,100% 6px,100% calc(100% - 6px),
                 calc(100% - 6px) 100%,6px 100%,0 calc(100% - 6px),0 6px);
  --tex:repeating-linear-gradient(0deg, transparent 0 3px,
        color-mix(in srgb, var(--ink) 6%, transparent) 3px 4px);
  --ease:steps(4, end);

  --font-display:'Press Start 2P','Black Han Sans','Noto Sans KR',sans-serif;
  --font-head:'Silkscreen','Do Hyeon','Noto Sans KR',sans-serif;
  --font-hand:'Silkscreen','Do Hyeon','Noto Sans KR',sans-serif;
  --font-body:'Silkscreen','Do Hyeon','Noto Sans KR',sans-serif;
}

@media (prefers-color-scheme: dark){
  [data-skin="pixel"]:not([data-theme="light"]){
    --bg:#0B1026; --bg-deep:#05070F; --bg-soft:#1C2A50;
    --card:#151C38; --card-2:#101733;
    --ink:#EAF3E0; --line:#EAF3E0; --ink-soft:#C2D0BC;
    --grey:#8FA0C0; --grey-mute:#4B5A80; --grey-line:#2A3660;
    --yolk:#FFD23F; --yolk-deep:#C98A00;
    --red:#FF5C5C; --blue:#4FA9FF; --blue-ink:#79C3FF;
    --leaf:#2FA84F; --leaf-ink:#6BE59A; --plum:#FF6BA8;
    --egg-w:#EAF3E0;
  }
}
[data-skin="pixel"][data-theme="dark"]{
  --bg:#0B1026; --bg-deep:#05070F; --bg-soft:#1C2A50;
  --card:#151C38; --card-2:#101733;
  --ink:#EAF3E0; --line:#EAF3E0; --ink-soft:#C2D0BC;
  --grey:#8FA0C0; --grey-mute:#4B5A80; --grey-line:#2A3660;
  --yolk:#FFD23F; --yolk-deep:#C98A00;
  --red:#FF5C5C; --blue:#4FA9FF; --blue-ink:#79C3FF;
  --leaf:#2FA84F; --leaf-ink:#6BE59A; --plum:#FF6BA8;
  --egg-w:#EAF3E0;
}

/* 배경 : 목욕탕 타일 체커 (8px 격자) */
[data-skin="pixel"] body{
  background:
    conic-gradient(from 90deg at 50% 50%,
      var(--bg) 0 25%, var(--bg-deep) 0 50%,
      var(--bg) 0 75%, var(--bg-deep) 0 100%) 0 0 / 16px 16px,
    var(--bg);
  background-attachment:fixed;
  image-rendering:pixelated;
}
[data-skin="pixel"] svg{ shape-rendering:crispEdges; }
[data-skin="pixel"] img{ image-rendering:pixelated; }
```

> **체커 명도차는 최소로.** `--bg`와 `--bg-deep` 차이가 크면 배경이 시끄러워서 카드 글씨가 안 읽힌다.
> 강하다 싶으면 `--bg-deep`을 `color-mix(in srgb, var(--bg) 88%, var(--ink))`로 낮춰 쓸 것.

---

## B-3. 타이포그래피 (픽셀) — 현실적 결론

### 문제

**Google Fonts에는 한글 픽셀(비트맵) 폰트가 없다.** 대표 후보들의 실제 상황:

| 후보 | 배포 | 이 프로젝트에서 |
|---|---|---|
| **Galmuri9 / Galmuri11** | 자체 CDN (`cdn.jsdelivr.net/gh/projectnoonnu`) | 한글 픽셀 품질 최고지만 **Google Fonts 아님 → 제약 위반** ❌ |
| **DungGeunMo (둥근모꼴)** | 눈누/jsDelivr | 동일 이유로 ❌ |
| **Neo둥근모** | 자체 배포 | 동일 이유로 ❌ |
| **Press Start 2P** | ✅ Google Fonts | **라틴 전용** (한글 글리프 0) |
| **Silkscreen** | ✅ Google Fonts | **라틴 전용**, Press Start 2P보다 작고 가독 좋음 |
| **VT323 / Pixelify Sans** | ✅ Google Fonts | 라틴 전용, 획이 얇아 대제목엔 부적합 |

### 결론 — **글리프 폴백 하이브리드**

브라우저는 `font-family` 스택에서 **글리프가 없는 폰트를 글자 단위로 건너뛴다.**
즉 `font-family:'Press Start 2P','Black Han Sans'`로 쓰면 **영문·숫자는 자동으로 픽셀 폰트, 한글은 자동으로 Black Han Sans**가 된다. `unicode-range` @font-face를 직접 쓸 필요가 없다.

| 레벨 | 스택 | 근거 |
|---|---|---|
| **display** | `'Press Start 2P', 'Black Han Sans', sans-serif` | 카운터 숫자 `00`, `FAN CLUB` 같은 라틴이 핵심 픽셀 인상을 만든다. 한글은 Black Han Sans가 각져서 도트와 충돌이 가장 적음 |
| **head / body / hand** | `'Silkscreen', 'Do Hyeon', sans-serif` | Press Start 2P는 본문 크기에서 x-height가 과해 읽기 힘들다. Silkscreen이 메트릭이 훨씬 온순 |

> 픽셀 스킨에서는 `--font-hand`가 `--font-body`와 같은 값이다. **8비트 세계에 손글씨는 없다.**
> 대신 손글씨가 담당하던 "주석" 역할은 `[ ]` 대괄호와 `>` 화살표 기호로 낸다 — `> 사장님 몰래 씁니다`

### 메트릭 보정 (필수)

Press Start 2P는 em 대비 글자가 크고 자간이 넓다. 같은 `font-size`면 한글보다 라틴이 훨씬 커 보인다.

```css
[data-skin="pixel"] .t-hero,
[data-skin="pixel"] .t-count{
  font-size-adjust:0.52;      /* 지원 브라우저: 자동 보정 */
  letter-spacing:0;            /* Press Start 2P는 자간을 이미 품고 있다 */
}
/* 미지원 폴백 : 라틴만 감싸 크기 개별 조정 */
.lat{ font-size:.74em; }      /* <span class="lat">00</span>일째 */
```

### 안티앨리어싱 억제 (한글 폴백 폰트용)

한글은 벡터 폰트라서 그냥 두면 가장자리가 부드럽다. 도트 질감에 맞춰 눌러 준다.

```css
[data-skin="pixel"]{
  -webkit-font-smoothing:none;   /* Chrome/Safari (macOS) */
  -moz-osx-font-smoothing:grayscale;
  font-smooth:never;             /* 레거시, 무해 */
  text-rendering:optimizeSpeed;
}
/* 정수 px 사이즈만 쓴다 — 힌팅이 깨지는 걸 최소화 */
[data-skin="pixel"]{
  --t-hero:40px; --t-logo:20px; --t-count:28px;
  --t-h1:24px; --t-h2:20px; --t-h3:16px;
  --t-body:14px; --t-ui:12px; --t-meta:10px; --t-hand:12px;
}
@media (min-width:768px){
  [data-skin="pixel"]{
    --t-hero:64px; --t-logo:24px; --t-count:32px;
    --t-h1:28px; --t-h2:20px; --t-h3:16px;
    --t-body:16px; --t-ui:14px; --t-meta:12px; --t-hand:14px;
  }
}
[data-skin="pixel"] body{ line-height:1.6; }  /* 픽셀 폰트는 행간을 조금 넓혀야 읽힌다 */
```

> **나중에 CSP가 jsDelivr를 허용하면** `--font-body`/`--font-head`의 두 번째 항목만
> `'DungGeunMo'` 또는 `'Galmuri11'`로 바꾸면 끝. 컴포넌트 CSS는 손댈 게 없다.

---

## B-4. 레터링 픽셀 버전 — "업다운 팬클럽!"

**`-webkit-text-stroke`를 쓰지 않는다.** stroke는 곡선을 부드럽게 갉아서 도트감을 죽인다.
대신 **1~3px 정수 스텝 `text-shadow`를 계단으로 쌓아** 8비트 아웃라인을 만든다.

```css
[data-skin="pixel"] .lettering{
  font:400 var(--t-hero)/1.1 var(--font-display);
  color:var(--yolk);
  -webkit-text-stroke:0;
  transform:none;                 /* 회전 금지 — 도트가 깨진다 */
  letter-spacing:.02em;
  text-shadow:
    /* ① 1px 링 — 8방향 */
    -3px  0 0 var(--line),  3px  0 0 var(--line),
     0  -3px 0 var(--line),  0   3px 0 var(--line),
    -3px -3px 0 var(--line),  3px -3px 0 var(--line),
    -3px  3px 0 var(--line),  3px  3px 0 var(--line),
    /* ② 2px 링 — 두께 보강 */
    -6px  0 0 var(--line),  6px  0 0 var(--line),
     0  -6px 0 var(--line),  0   6px 0 var(--line),
    /* ③ 계단식 드롭 섀도 — 대각으로 3칸 */
     3px  6px 0 var(--line),  6px  9px 0 var(--line),
     6px 12px 0 var(--red),   9px 15px 0 var(--line);
}
[data-skin="pixel"] .lettering span{ transform:none !important; }  /* A스킨 흔들기 무효화 */
[data-skin="pixel"] .lettering span:last-child{ color:var(--red); }
@media (min-width:768px){
  [data-skin="pixel"] .lettering{
    text-shadow:
      -4px 0 0 var(--line), 4px 0 0 var(--line), 0 -4px 0 var(--line), 0 4px 0 var(--line),
      -4px -4px 0 var(--line), 4px -4px 0 var(--line), -4px 4px 0 var(--line), 4px 4px 0 var(--line),
      -8px 0 0 var(--line), 8px 0 0 var(--line), 0 -8px 0 var(--line), 0 8px 0 var(--line),
       4px 8px 0 var(--line), 8px 12px 0 var(--line),
       8px 16px 0 var(--red), 12px 20px 0 var(--line);
  }
}
```

> **드롭 섀도에 `--red`를 한 층 끼우는 게 핵심.** 검정만 쌓으면 그냥 두꺼운 글씨지만,
> 빨강 한 겹이 들어가면 패미컴 타이틀 화면 특유의 "색 어긋난 인쇄" 느낌이 난다.

### 픽셀 스팀 `{{{`

스킨 A의 `.steam` 컨테이너를 그대로 쓰고 내부 SVG만 §B-6 ④로 교체한다. 회전은 끈다.

```css
[data-skin="pixel"] .steam svg{ transform:none !important; width:16px; }
[data-skin="pixel"] .steam svg:nth-child(1){ height:32px; }
[data-skin="pixel"] .steam svg:nth-child(2){ height:48px; }
[data-skin="pixel"] .steam svg:nth-child(3){ height:40px; }
```

---

## B-5. 컴포넌트 픽셀 처리

컴포넌트 CSS 본체는 **스킨 A와 동일한 클래스·동일한 토큰 참조**를 쓴다. 아래는 `[data-skin="pixel"]` 아래에서만 추가로 얹는 오버라이드다.

### 카드 — 계단 모서리 + 딕셀 패턴

```css
[data-skin="pixel"] .card{
  border-radius:0;
  clip-path:var(--clip);                  /* 8비트 코너 깎기 */
  background:var(--tex), var(--card);     /* 스캔라인 텍스처 */
  background-blend-mode:normal;
  transform:none !important;              /* A스킨 기울기 무효화 */
}
[data-skin="pixel"] .card:nth-child(even){ border-radius:0; }
[data-skin="pixel"] .card:hover { transform:translate(-4px,-4px) !important; box-shadow:8px 8px 0 var(--line); }
[data-skin="pixel"] .card:active{ transform:translate(4px,4px)  !important; box-shadow:var(--sh-press); }
```

> `clip-path`와 `box-shadow`는 **같이 쓰면 그림자가 잘린다.** 계단 모서리 + 그림자를 둘 다 원하면
> 래퍼를 하나 두고 **바깥에 그림자, 안쪽에 clip-path**를 건다.
> ```css
> .card-wrap{ box-shadow:var(--sh); }
> .card-wrap > .card{ clip-path:var(--clip); box-shadow:none; }
> ```

### 버튼 — 눌리는 A/B 버튼

```css
[data-skin="pixel"] .btn{
  border-radius:0; clip-path:var(--clip);
  font-family:var(--font-body); letter-spacing:.04em;
  text-transform:none;
  box-shadow:var(--sh);
  transition:transform 60ms steps(2,end), box-shadow 60ms steps(2,end);
}
[data-skin="pixel"] .btn:hover { transform:translate(-2px,-2px); box-shadow:6px 6px 0 var(--line); }
[data-skin="pixel"] .btn:active{ transform:translate(4px,4px);  box-shadow:0 0 0 var(--line); }

/* 노른자 버튼에 도트 셰이딩 한 겹 (오른쪽·아래가 어둡다) */
[data-skin="pixel"] .btn--primary{
  background:
    linear-gradient(to left,  var(--yolk-deep) 0 4px, transparent 4px),
    linear-gradient(to top,   var(--yolk-deep) 0 4px, transparent 4px),
    var(--yolk);
}
[data-skin="pixel"] .btn--danger{ color:var(--card); }   /* 4.83:1 */
```

### 입력창

```css
[data-skin="pixel"] .field{
  border-radius:0; clip-path:none;               /* 입력창은 각을 살린다 */
  box-shadow:inset 3px 3px 0 var(--grey-line);   /* 파인 느낌 */
  background:var(--card-2);
  font-family:var(--font-body);
}
[data-skin="pixel"] .field:focus-visible{
  outline:4px solid var(--blue-ink); outline-offset:0;  /* offset 0 = 격자 유지 */
  background:var(--bg-soft);
}
[data-skin="pixel"] .field::placeholder{ color:var(--grey); }
/* 캐럿 깜빡임도 계단으로 */
[data-skin="pixel"] .field{ caret-color:var(--red); }
```

### 태그 / 뱃지

```css
[data-skin="pixel"] .tag{
  border-radius:0; clip-path:none;
  border-width:2px; height:24px; padding:0 8px;
  letter-spacing:.04em;
}
[data-skin="pixel"] .tag--hot::before{ content:"★ "; }
[data-skin="pixel"] .tag--new::before{ content:"NEW "; font-size:.85em; }
```

### 모달 — 8비트 다이얼로그 박스

```css
[data-skin="pixel"] .modal-back{
  /* 반투명 대신 딕셀(dithering) 격자 */
  background:
    repeating-conic-gradient(var(--ink) 0 25%, transparent 0 50%) 0 0 / 4px 4px,
    color-mix(in srgb, var(--ink) 35%, transparent);
}
[data-skin="pixel"] .modal{
  border-radius:0;
  border:var(--bd-thick);
  box-shadow:0 0 0 4px var(--card), 0 0 0 8px var(--line);  /* 이중 프레임 */
  background:var(--card);
  animation:none;
}
[data-skin="pixel"] .modal::before{                          /* 손잡이 → 타이틀 바 */
  content:"■ ■ ■"; width:auto; height:auto; background:none;
  font:400 var(--t-meta)/1 var(--font-body); color:var(--grey-mute);
  letter-spacing:.4em; text-align:center; margin-bottom:var(--s4);
}
[data-skin="pixel"] .pin i{ border-radius:0; clip-path:none; border-width:3px; }
```

### 좋아요 — 도트 스팀 스프라이트

```css
[data-skin="pixel"] .like{ border-radius:0; clip-path:var(--clip); }
[data-skin="pixel"] .like__egg svg{ width:32px; height:32px; }      /* 16×16 의 정수 2배 */
[data-skin="pixel"] .like[aria-pressed="true"] .like__egg svg{
  transform:scale(1.5);                                              /* 2배 → 3배, 정수 배율 */
  transition:transform 80ms steps(2,end);
}
/* 스팀 : 부드러운 상승 대신 4칸 점프 */
[data-skin="pixel"] .like__steam i{ width:4px; height:4px; border-radius:0; }
[data-skin="pixel"] .like.is-pop .like__steam i{ animation:puff-px 480ms steps(4,end) forwards; }
@keyframes puff-px{
  0%  { opacity:1; transform:translateY(0)    }
  100%{ opacity:0; transform:translateY(-24px) }   /* steps(4) → 6px씩 4칸 */
}
[data-skin="pixel"] .like.is-pop .like__n b{ animation:roll 160ms steps(2,end); }
```

### 섹션 헤더

```css
[data-skin="pixel"] .sec__ico{ border-radius:0; clip-path:none; border-width:2px; }
[data-skin="pixel"] .sec::after{
  border-top:0;
  height:4px;
  background:repeating-linear-gradient(90deg, var(--grey-mute) 0 4px, transparent 4px 8px);
}
[data-skin="pixel"] .sec__note::before{ content:"> "; }
```

### 빈 상태

```css
[data-skin="pixel"] .empty{
  border-radius:0; clip-path:none;
  border:3px solid var(--grey-mute);
  background:
    repeating-linear-gradient(45deg,
      color-mix(in srgb, var(--ink) 4%, transparent) 0 4px, transparent 4px 8px),
    var(--card-2);
}
[data-skin="pixel"] .empty svg{ width:96px; height:96px; animation:bob-px 1.2s steps(2,end) infinite; }
@keyframes bob-px{ 0%,49%{transform:translateY(0)} 50%,100%{transform:translateY(-4px)} }
```

### 픽셀 디바이더 · 스크롤바

```css
/* 구분선 : 점선이 아니라 도트 */
[data-skin="pixel"] .divider{
  height:4px; border:0;
  background:repeating-linear-gradient(90deg, var(--line) 0 4px, transparent 4px 8px);
}
/* 스크롤바 (WebKit) */
[data-skin="pixel"] ::-webkit-scrollbar{ width:14px; height:14px; }
[data-skin="pixel"] ::-webkit-scrollbar-track{
  background:repeating-conic-gradient(var(--grey-line) 0 25%, var(--card) 0 50%) 0 0 / 6px 6px;
}
[data-skin="pixel"] ::-webkit-scrollbar-thumb{
  background:var(--yolk); border:3px solid var(--line); border-radius:0;
}
[data-skin="pixel"]{ scrollbar-color:var(--yolk) var(--card-2); }  /* Firefox 폴백 */
/* 선택 영역 */
[data-skin="pixel"] ::selection{ background:var(--yolk); color:var(--ink); }
```

---

## B-6. 픽셀 계란 캐릭터 SVG

**규칙**
- **16×16 그리드**, 전부 `<rect ... height="1">`. `shape-rendering="crispEdges"`로 서브픽셀 블러를 끈다.
- 색은 토큰 참조 (`var(--line)` / `var(--egg-w)` / `var(--yolk)`) → **다크모드 자동 반전**.
- 확대는 **정수 배율만**: `width:32/48/64/80px`. 소수 배율을 쓰면 도트가 뭉갠다.
- 가로로 연속된 같은 색 픽셀은 하나의 `<rect>`로 병합돼 있다 (코드량 최소화).
- 스킨 A의 SVG와 **같은 자리에 같은 클래스**로 교체된다. 마크업 구조는 동일.

### ①②③ 계란 3종 (반짝 / 졸림 / 멍)

```html
<!-- spark — 반짝 (좋아요/성공) -->
<svg class="px-egg" viewBox="0 0 16 16" width="64" height="64" shape-rendering="crispEdges" aria-hidden="true">
  <g fill="var(--line)"><rect x="4" y="1" width="6" height="1"/><rect x="2" y="2" width="2" height="1"/><rect x="10" y="2" width="2" height="1"/>
   <rect x="1" y="3" width="1" height="1"/><rect x="12" y="3" width="1" height="1"/><rect x="0" y="4" width="1" height="1"/>
   <rect x="13" y="4" width="1" height="1"/><rect x="0" y="5" width="1" height="1"/><rect x="13" y="5" width="1" height="1"/>
   <rect x="0" y="6" width="1" height="1"/><rect x="5" y="6" width="1" height="1"/><rect x="8" y="6" width="1" height="1"/>
   <rect x="14" y="6" width="1" height="1"/><rect x="0" y="7" width="1" height="1"/><rect x="14" y="7" width="1" height="1"/>
   <rect x="0" y="8" width="1" height="1"/><rect x="6" y="8" width="2" height="1"/><rect x="14" y="8" width="1" height="1"/>
   <rect x="0" y="9" width="1" height="1"/><rect x="13" y="9" width="1" height="1"/><rect x="1" y="10" width="1" height="1"/>
   <rect x="13" y="10" width="1" height="1"/><rect x="1" y="11" width="1" height="1"/><rect x="12" y="11" width="1" height="1"/>
   <rect x="2" y="12" width="1" height="1"/><rect x="11" y="12" width="1" height="1"/><rect x="3" y="13" width="2" height="1"/>
   <rect x="9" y="13" width="2" height="1"/><rect x="5" y="14" width="4" height="1"/></g>
  <g fill="var(--egg-w)"><rect x="4" y="2" width="6" height="1"/><rect x="2" y="3" width="10" height="1"/><rect x="1" y="4" width="12" height="1"/>
   <rect x="1" y="5" width="4" height="1"/><rect x="9" y="5" width="4" height="1"/><rect x="1" y="6" width="3" height="1"/>
   <rect x="10" y="6" width="4" height="1"/><rect x="1" y="7" width="3" height="1"/><rect x="10" y="7" width="4" height="1"/>
   <rect x="1" y="8" width="3" height="1"/><rect x="10" y="8" width="4" height="1"/><rect x="1" y="9" width="4" height="1"/>
   <rect x="9" y="9" width="4" height="1"/><rect x="2" y="10" width="11" height="1"/><rect x="2" y="11" width="10" height="1"/>
   <rect x="3" y="12" width="8" height="1"/><rect x="5" y="13" width="4" height="1"/></g>
  <g fill="var(--yolk)"><rect x="1" y="0" width="1" height="1"/><rect x="14" y="0" width="1" height="1"/><rect x="0" y="1" width="1" height="1"/>
   <rect x="2" y="1" width="1" height="1"/><rect x="13" y="1" width="1" height="1"/><rect x="15" y="1" width="1" height="1"/>
   <rect x="1" y="2" width="1" height="1"/><rect x="14" y="2" width="1" height="1"/><rect x="5" y="5" width="4" height="1"/>
   <rect x="4" y="6" width="1" height="1"/><rect x="6" y="6" width="2" height="1"/><rect x="9" y="6" width="1" height="1"/>
   <rect x="4" y="7" width="6" height="1"/><rect x="4" y="8" width="2" height="1"/><rect x="8" y="8" width="2" height="1"/>
   <rect x="5" y="9" width="4" height="1"/></g>
</svg>

<!-- sleep — 졸림 (로딩/심야) -->
<svg class="px-egg" viewBox="0 0 16 16" width="64" height="64" shape-rendering="crispEdges" aria-hidden="true">
  <g fill="var(--line)"><rect x="12" y="0" width="3" height="1"/><rect x="4" y="1" width="6" height="1"/><rect x="13" y="1" width="1" height="1"/>
   <rect x="2" y="2" width="2" height="1"/><rect x="10" y="2" width="5" height="1"/><rect x="1" y="3" width="1" height="1"/>
   <rect x="12" y="3" width="1" height="1"/><rect x="0" y="4" width="1" height="1"/><rect x="13" y="4" width="1" height="1"/>
   <rect x="0" y="5" width="1" height="1"/><rect x="13" y="5" width="1" height="1"/><rect x="0" y="6" width="1" height="1"/>
   <rect x="4" y="6" width="2" height="1"/><rect x="8" y="6" width="2" height="1"/><rect x="14" y="6" width="1" height="1"/>
   <rect x="0" y="7" width="1" height="1"/><rect x="14" y="7" width="1" height="1"/><rect x="0" y="8" width="1" height="1"/>
   <rect x="7" y="8" width="1" height="1"/><rect x="14" y="8" width="1" height="1"/><rect x="0" y="9" width="1" height="1"/>
   <rect x="13" y="9" width="1" height="1"/><rect x="1" y="10" width="1" height="1"/><rect x="13" y="10" width="1" height="1"/>
   <rect x="1" y="11" width="1" height="1"/><rect x="12" y="11" width="1" height="1"/><rect x="2" y="12" width="1" height="1"/>
   <rect x="11" y="12" width="1" height="1"/><rect x="3" y="13" width="2" height="1"/><rect x="9" y="13" width="2" height="1"/>
   <rect x="5" y="14" width="4" height="1"/></g>
  <g fill="var(--egg-w)"><rect x="4" y="2" width="6" height="1"/><rect x="2" y="3" width="10" height="1"/><rect x="1" y="4" width="12" height="1"/>
   <rect x="1" y="5" width="4" height="1"/><rect x="9" y="5" width="4" height="1"/><rect x="1" y="6" width="3" height="1"/>
   <rect x="10" y="6" width="4" height="1"/><rect x="1" y="7" width="3" height="1"/><rect x="10" y="7" width="4" height="1"/>
   <rect x="1" y="8" width="3" height="1"/><rect x="10" y="8" width="4" height="1"/><rect x="1" y="9" width="4" height="1"/>
   <rect x="9" y="9" width="4" height="1"/><rect x="2" y="10" width="11" height="1"/><rect x="2" y="11" width="10" height="1"/>
   <rect x="3" y="12" width="8" height="1"/><rect x="5" y="13" width="4" height="1"/></g>
  <g fill="var(--yolk)"><rect x="5" y="5" width="4" height="1"/><rect x="6" y="6" width="2" height="1"/><rect x="4" y="7" width="6" height="1"/>
   <rect x="4" y="8" width="3" height="1"/><rect x="8" y="8" width="2" height="1"/><rect x="5" y="9" width="4" height="1"/></g>
</svg>

<!-- blank — 멍 (빈 상태/404) -->
<svg class="px-egg" viewBox="0 0 16 16" width="64" height="64" shape-rendering="crispEdges" aria-hidden="true">
  <g fill="var(--line)"><rect x="13" y="0" width="1" height="1"/><rect x="15" y="0" width="1" height="1"/><rect x="4" y="1" width="6" height="1"/>
   <rect x="12" y="1" width="1" height="1"/><rect x="14" y="1" width="1" height="1"/><rect x="2" y="2" width="2" height="1"/>
   <rect x="10" y="2" width="2" height="1"/><rect x="1" y="3" width="1" height="1"/><rect x="12" y="3" width="1" height="1"/>
   <rect x="0" y="4" width="1" height="1"/><rect x="13" y="4" width="1" height="1"/><rect x="0" y="5" width="1" height="1"/>
   <rect x="13" y="5" width="1" height="1"/><rect x="0" y="6" width="1" height="1"/><rect x="4" y="6" width="1" height="1"/>
   <rect x="9" y="6" width="1" height="1"/><rect x="14" y="6" width="1" height="1"/><rect x="0" y="7" width="1" height="1"/>
   <rect x="14" y="7" width="1" height="1"/><rect x="0" y="8" width="1" height="1"/><rect x="7" y="8" width="1" height="1"/>
   <rect x="14" y="8" width="1" height="1"/><rect x="0" y="9" width="1" height="1"/><rect x="13" y="9" width="1" height="1"/>
   <rect x="1" y="10" width="1" height="1"/><rect x="13" y="10" width="1" height="1"/><rect x="1" y="11" width="1" height="1"/>
   <rect x="12" y="11" width="1" height="1"/><rect x="2" y="12" width="1" height="1"/><rect x="11" y="12" width="1" height="1"/>
   <rect x="3" y="13" width="2" height="1"/><rect x="9" y="13" width="2" height="1"/><rect x="5" y="14" width="4" height="1"/></g>
  <g fill="var(--egg-w)"><rect x="4" y="2" width="6" height="1"/><rect x="2" y="3" width="10" height="1"/><rect x="1" y="4" width="12" height="1"/>
   <rect x="1" y="5" width="4" height="1"/><rect x="9" y="5" width="4" height="1"/><rect x="1" y="6" width="3" height="1"/>
   <rect x="10" y="6" width="4" height="1"/><rect x="1" y="7" width="3" height="1"/><rect x="10" y="7" width="4" height="1"/>
   <rect x="1" y="8" width="3" height="1"/><rect x="10" y="8" width="4" height="1"/><rect x="1" y="9" width="4" height="1"/>
   <rect x="9" y="9" width="4" height="1"/><rect x="2" y="10" width="11" height="1"/><rect x="2" y="11" width="10" height="1"/>
   <rect x="3" y="12" width="8" height="1"/><rect x="5" y="13" width="4" height="1"/></g>
  <g fill="var(--yolk)"><rect x="5" y="5" width="4" height="1"/><rect x="5" y="6" width="4" height="1"/><rect x="4" y="7" width="6" height="1"/>
   <rect x="4" y="8" width="3" height="1"/><rect x="8" y="8" width="2" height="1"/><rect x="5" y="9" width="4" height="1"/></g>
</svg>
```

> 세 스프라이트는 **흰자·노른자 픽셀이 완전히 동일**하고 얼굴 4~7픽셀만 다르다.
> → 같은 자리에서 교체하면 몸은 가만히 있고 **표정만 바뀌는** 스프라이트 애니메이션이 된다.
> 노른자에는 일부러 테두리를 두르지 않았다. 16×16에서 노른자를 검은 선으로 감싸면 안쪽이 3px밖에 안 남아 표정이 안 들어간다.

### ④ 픽셀 스팀 마크 (1획) · ⑤ 픽셀 원형 엠블럼

```html
<!-- 픽셀 스팀 1획 (3개 나란히 = {{{ ) -->
<svg class="px-steam" viewBox="0 0 8 16" width="32" height="64" shape-rendering="crispEdges" aria-hidden="true">
  <g fill="var(--line)"><rect x="2" y="0" width="2" height="1"/><rect x="1" y="1" width="2" height="1"/><rect x="1" y="2" width="2" height="1"/>
   <rect x="2" y="3" width="2" height="1"/><rect x="3" y="4" width="2" height="1"/><rect x="3" y="5" width="2" height="1"/>
   <rect x="2" y="6" width="2" height="1"/><rect x="1" y="7" width="2" height="1"/><rect x="1" y="8" width="2" height="1"/>
   <rect x="2" y="9" width="2" height="1"/><rect x="3" y="10" width="2" height="1"/><rect x="3" y="11" width="2" height="1"/>
   <rect x="2" y="12" width="2" height="1"/><rect x="1" y="13" width="2" height="1"/><rect x="1" y="14" width="2" height="1"/>
   <rect x="2" y="15" width="2" height="1"/></g>
</svg>

<!-- 픽셀 원형 엠블럼 배지 -->
<svg class="px-emblem" viewBox="0 0 16 16" width="80" height="80" shape-rendering="crispEdges" aria-hidden="true">
  <g fill="var(--line)"><rect x="5" y="0" width="6" height="1"/><rect x="3" y="1" width="2" height="1"/><rect x="11" y="1" width="2" height="1"/>
   <rect x="2" y="2" width="1" height="1"/><rect x="13" y="2" width="1" height="1"/><rect x="1" y="3" width="1" height="1"/>
   <rect x="14" y="3" width="1" height="1"/><rect x="1" y="4" width="1" height="1"/><rect x="14" y="4" width="1" height="1"/>
   <rect x="1" y="5" width="1" height="1"/><rect x="14" y="5" width="1" height="1"/><rect x="0" y="6" width="1" height="1"/>
   <rect x="15" y="6" width="1" height="1"/><rect x="0" y="7" width="1" height="1"/><rect x="15" y="7" width="1" height="1"/>
   <rect x="0" y="8" width="1" height="1"/><rect x="15" y="8" width="1" height="1"/><rect x="0" y="9" width="1" height="1"/>
   <rect x="15" y="9" width="1" height="1"/><rect x="1" y="10" width="1" height="1"/><rect x="14" y="10" width="1" height="1"/>
   <rect x="1" y="11" width="1" height="1"/><rect x="14" y="11" width="1" height="1"/><rect x="2" y="12" width="1" height="1"/>
   <rect x="13" y="12" width="1" height="1"/><rect x="3" y="13" width="2" height="1"/><rect x="11" y="13" width="2" height="1"/>
   <rect x="5" y="14" width="6" height="1"/></g>
  <g fill="var(--yolk)"><rect x="5" y="1" width="6" height="1"/><rect x="3" y="2" width="10" height="1"/><rect x="2" y="3" width="3" height="1"/>
   <rect x="6" y="3" width="2" height="1"/><rect x="9" y="3" width="2" height="1"/><rect x="12" y="3" width="2" height="1"/>
   <rect x="2" y="4" width="2" height="1"/><rect x="5" y="4" width="2" height="1"/><rect x="8" y="4" width="2" height="1"/>
   <rect x="11" y="4" width="3" height="1"/><rect x="2" y="5" width="3" height="1"/><rect x="6" y="5" width="2" height="1"/>
   <rect x="9" y="5" width="2" height="1"/><rect x="12" y="5" width="2" height="1"/><rect x="1" y="6" width="3" height="1"/>
   <rect x="5" y="6" width="2" height="1"/><rect x="8" y="6" width="2" height="1"/><rect x="11" y="6" width="4" height="1"/>
   <rect x="1" y="7" width="14" height="1"/><rect x="1" y="8" width="2" height="1"/><rect x="13" y="8" width="2" height="1"/>
   <rect x="1" y="9" width="3" height="1"/><rect x="12" y="9" width="3" height="1"/><rect x="2" y="10" width="3" height="1"/>
   <rect x="11" y="10" width="3" height="1"/><rect x="2" y="11" width="12" height="1"/><rect x="3" y="12" width="10" height="1"/>
   <rect x="5" y="13" width="6" height="1"/></g>
  <g fill="var(--red)"><rect x="5" y="3" width="1" height="1"/><rect x="8" y="3" width="1" height="1"/><rect x="11" y="3" width="1" height="1"/>
   <rect x="4" y="4" width="1" height="1"/><rect x="7" y="4" width="1" height="1"/><rect x="10" y="4" width="1" height="1"/>
   <rect x="5" y="5" width="1" height="1"/><rect x="8" y="5" width="1" height="1"/><rect x="11" y="5" width="1" height="1"/>
   <rect x="4" y="6" width="1" height="1"/><rect x="7" y="6" width="1" height="1"/><rect x="10" y="6" width="1" height="1"/></g>
  <g fill="var(--blue)"><rect x="3" y="8" width="10" height="1"/><rect x="4" y="9" width="8" height="1"/><rect x="5" y="10" width="6" height="1"/></g>
</svg>
```

### 스프라이트 교체 애니메이션 (표정 바꾸기)

3종을 겹쳐 놓고 `opacity`를 `steps`로 토글하면 프레임 애니메이션이 된다.

```html
<span class="sprite">
  <span data-f="1"><!-- spark --></span>
  <span data-f="2"><!-- blank --></span>
</span>
```
```css
.sprite{ position:relative; display:inline-block; width:64px; height:64px; }
.sprite > span{ position:absolute; inset:0; }
.sprite > span[data-f="2"]{ opacity:0; }
/* 3초마다 0.4초 동안 '멍' 표정으로 깜빡 */
[data-skin="pixel"] .sprite > span[data-f="2"]{ animation:blink 3s steps(1,end) infinite; }
@keyframes blink{ 0%,86%{opacity:0} 87%,99%{opacity:1} 100%{opacity:0} }
```

---

## B-7. 픽셀 모션

**원칙: `transition`의 부드러운 보간을 전부 `steps()`로 끊는다.** 8비트 하드웨어는 중간 프레임이 없다.

| 대상 | 애니메이션 | 타이밍 |
|---|---|---|
| 카드 hover | `translate(-4px,-4px)` | `steps(2,end)` 80ms |
| 버튼 active | `translate(4px,4px)` + 그림자 소멸 | `steps(2,end)` 60ms |
| 좋아요 스팀 | 도트가 6px씩 4칸 점프 | `steps(4,end)` 480ms |
| 좋아요 계란 | `scale(1) → scale(1.5)` 2단 | `steps(2,end)` 80ms |
| 캐릭터 대기 | 4px 상하 2프레임 루프 | `steps(2,end)` 1.2s ∞ |
| 표정 깜빡 | 스프라이트 교체 | `steps(1,end)` 3s ∞ |
| 섹션 진입 | opacity 0→1 **2단 페이드** (중간 없음) | `steps(2,end)` 240ms |
| 로딩 | `NOW LOADING` 점이 `.`→`..`→`...` | `steps(3,end)` 900ms ∞ |
| FAB | 4px 상하 진동 | `steps(2,end)` 600ms ∞ |

```css
[data-skin="pixel"] .reveal{
  animation:reveal-px 240ms steps(2,end) forwards;
}
@keyframes reveal-px{ from{opacity:0; transform:translateY(8px)} to{opacity:1; transform:none} }

/* NOW LOADING... */
[data-skin="pixel"] .loading::after{
  content:"."; animation:dots 900ms steps(3,end) infinite;
}
@keyframes dots{ 0%{content:"."} 33%{content:".."} 66%{content:"..."} }

[data-skin="pixel"] .fab{ animation:hover-px 600ms steps(2,end) infinite; }
@keyframes hover-px{ 0%,49%{transform:translateY(0)} 50%,100%{transform:translateY(-4px)} }
```

### `prefers-reduced-motion` 대응 (픽셀)

무한 루프 애니메이션이 A스킨보다 많다. **루프는 전부 정지**, 상태 피드백만 남긴다.

```css
@media (prefers-reduced-motion: reduce){
  [data-skin="pixel"] .empty svg,
  [data-skin="pixel"] .fab,
  [data-skin="pixel"] .sprite > span[data-f="2"],
  [data-skin="pixel"] .loading::after{ animation:none !important; }
  [data-skin="pixel"] .loading::after{ content:"..."; }
  [data-skin="pixel"] .sprite > span[data-f="2"]{ opacity:0; }
  [data-skin="pixel"] .card:hover,
  [data-skin="pixel"] .btn:hover{ transform:none !important; box-shadow:var(--sh); }
  /* 눌림 피드백은 그림자로만 — 위치 이동 없이도 상태가 보인다 */
  [data-skin="pixel"] .btn:active{ transform:none !important; box-shadow:0 0 0 var(--line); }
}
```

---

# 공용 — 레이아웃 · 토글 · 접근성

## C-1. 레이아웃 와이어프레임

**두 스킨이 공유한다.** 섹션 순서·DOM 구조·그리드는 동일하고, 안을 채우는 비주얼만 스킨이 바꾼다.

### 모바일 (360px 기준, 1단, 좌우 gutter 16px → 콘텐츠 328px)

```
┌──────────────────────────────────────────────┐ ← 360px
│ ░░░░ (스킨A: 하늘색 / 스킨B: 타일 체커) ░░░░ │
│                                              │
│ ┌──────────────────────────────────────────┐ │  HEADER  sticky top
│ │ [엠블럼] 금샘탕          [손그림|픽셀] ⚙ │ │  h:56
│ │  32×32   로고 t-logo      스킨 토글       │ │
│ ├──────────────────────────────────────────┤ │
│ │  [반짝계란]  0 0 일째 입덕 ing..         │ │  카운터 카드
│ │    48×48     └t-count┘  └t-hand/meta┘    │ │  h:72
│ │  ─────────────────────────────────────    │ │
│ │  닉네임 · 비번없음   [닉네임 정하기 >]   │ │  h:40
│ └──────────────────────────────────────────┘ │
│                                              │
│   {{{   업 다 운                             │  HERO
│   {{{   팬 클 럽 !          {{{  {{{         │  t-hero 42px
│         └ 노란 글씨 + 검은 아웃라인 ┘        │  2줄 강제
│                                              │
│ ┌──────────────────────────────────────────┐ │
│ │  [📖] 활동규칙 보기            (full-w)  │ │  btn--ghost h:44
│ └──────────────────────────────────────────┘ │
│                                              │
│ ★ 인기글 ─────────────────  > 이번주 TOP3   │  .sec
│ ┌──────────────────────────────────────────┐ │
│ │ [HOT] 사장님 오늘 머리 하셨다           │ │  카드 (rotate -.4deg)
│ │ 카운터에서 뵀는데 진짜…                  │ │  2줄 클램프
│ │ 익명계란 · 3시간 전       [🥚 24] [💬 7] │ │
│ └──────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────┐ │
│ │ [HOT] …                                  │ │  ×3
│ └──────────────────────────────────────────┘ │
│                                              │
│ 💬 최근 주접 ───────────  > 사장님 몰래 씁니다│
│ ┌──────────────────────────────────────────┐ │
│ │ …                                        │ │  ×5 + [더 보기]
│ └──────────────────────────────────────────┘ │
│              [ 더 보기 ▾ ]                   │
│                                              │
│ 👋 인사해요 ─────────────────────────────    │
│ ┌──────────────────────────────────────────┐ │
│ │ ┌────────────────┐ ┌────────────────┐    │ │  가로 스크롤
│ │ │ 처음 왔어요!   │ │ 단골 3년차…    │ →  │ │  카드 w:240
│ │ │ 익명계란       │ │ 노른자킹        │    │ │  snap-x
│ │ └────────────────┘ └────────────────┘    │ │
│ └──────────────────────────────────────────┘ │
│                                              │
│ 🎤 팬미팅 ────────────  > 사장님께 질문하기  │
│ ┌──────────────────────────────────────────┐ │
│ │ Q. 냉탕 온도 왜 그렇게 완벽한가요?       │ │  질문 카드
│ │    └ A. (미답변)              [🥚 12]    │ │  답변시 A 블록
│ └──────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────┐ │
│ │ [textarea] 궁금한 거 적어주세요           │ │  인풋 h:96
│ │                          [질문 남기기]   │ │
│ └──────────────────────────────────────────┘ │
│                                              │
│ 🔗 사장님 활동 ──────────────────────────    │
│ ┌──────────────────────────────────────────┐ │
│ │ [ig] 금샘탕 공식 인스타          ↗       │ │  링크 리스트
│ │ ────────────────────────────────────      │ │  각 행 h:52
│ │ [📍] 네이버 플레이스             ↗       │ │
│ │ ────────────────────────────────────      │ │
│ │ [📰] 동네신문 인터뷰 (2024)      ↗       │ │
│ └──────────────────────────────────────────┘ │
│                                              │
│ ┌──────────────────────────────────────────┐ │  FOOTER
│ │  [멍계란]  비공식 팬페이지예요            │ │
│ │  made by 사우나범                         │ │
│ └──────────────────────────────────────────┘ │
│                                              │
│                              ╔════════════╗  │  FAB (fixed)
│                              ║ ✏ 주접쓰기 ║  │  right:16 bottom:20
│                              ╚════════════╝  │  h:52 + safe-area
└──────────────────────────────────────────────┘
```

**모바일 규칙**
- 좌우 gutter `16px` 고정, **가로 스크롤 절대 금지** (인사해요 캐러셀만 예외, 내부 스크롤)
- 섹션 간 간격 `--s8` (32px), 섹션 헤더 위 `--s8` / 아래 `--s4`
- FAB은 `position:fixed; right:16px; bottom:calc(20px + env(safe-area-inset-bottom))`
- FAB이 마지막 카드를 가리므로 `main{ padding-bottom:96px; }`
- 헤더는 `position:sticky; top:0; z-index:50` — 스크롤 시 하단에 `--line` 2~3px 경계 추가

### 데스크탑 (1024px, max-width 1024 / 2단)

```
┌────────────────────────────────────────────────────────────────────────────┐ ← 1024px
│ ┌────────────────────────────────────────────────────────────────────────┐ │
│ │ [엠블럼] 금샘탕      00일째 입덕 ing..    닉네임: 노른자킹  [A|B] ⚙  │ │ HEADER h:64
│ └────────────────────────────────────────────────────────────────────────┘ │ sticky
│                                                                            │
│      {{{  {{{        업 다 운   팬 클 럽 !          {{{  {{{               │ HERO
│                      └──── t-hero 68px, 1줄 ────┘                          │ py:64
│                        [ 📖 활동규칙 보기 ]                                │
│                                                                            │
│ ┌──────────────────────────────────────────────┐ ┌───────────────────────┐ │
│ │ ★ 인기글 ───────────────── > 이번주 TOP3     │ │ 🔗 사장님 활동        │ │
│ │ ┌────────────────────┐ ┌────────────────────┐│ │ ┌───────────────────┐ │ │
│ │ │ [HOT] 사장님 오늘…  │ │ [HOT] 신발장 12번… ││ │ │ [ig] 공식 인스타↗ │ │ │
│ │ │ 익명계란 · 3시간전  │ │ 노른자킹 · 5시간전 ││ │ │ [📍] 네이버 ↗     │ │ │
│ │ │        [🥚24][💬7] │ │        [🥚18][💬3] ││ │ │ [📰] 인터뷰 ↗     │ │ │
│ │ └────────────────────┘ └────────────────────┘│ │ └───────────────────┘ │ │
│ │  └─ 2col grid, gap 20 ─┘                     │ │                       │ │
│ │                                              │ │ 👋 인사해요           │ │
│ │ 💬 최근 주접 ──────── > 사장님 몰래 씁니다   │ │ ┌───────────────────┐ │ │
│ │ ┌──────────────────────────────────────────┐ │ │ │ 처음 왔어요!      │ │ │
│ │ │ …                                        │ │ │ │ 익명계란          │ │ │
│ │ └──────────────────────────────────────────┘ │ │ ├───────────────────┤ │ │
│ │ ┌──────────────────────────────────────────┐ │ │ │ 단골 3년차…       │ │ │
│ │ │ …                     ×8 (1col, 세로)    │ │ │ │ 노른자킹          │ │ │
│ │ └──────────────────────────────────────────┘ │ │ └───────────────────┘ │ │
│ │              [ 더 보기 ▾ ]                   │ │  (세로 리스트로 변경) │ │
│ │                                              │ │                       │ │
│ │ 🎤 팬미팅 ─────────── > 사장님께 질문하기    │ │ ┌───────────────────┐ │ │
│ │ ┌──────────────────────────────────────────┐ │ │ │  [졸린계란 96px]  │ │ │
│ │ │ Q. …                          [🥚 12]    │ │ │ │  오늘도 영업중..  │ │ │
│ │ └──────────────────────────────────────────┘ │ │ │  06:00 - 20:00    │ │ │
│ │ ┌──────────────────────────────────────────┐ │ │ └───────────────────┘ │ │
│ │ │ [textarea]              [질문 남기기]    │ │ │   sticky top:88       │ │
│ │ └──────────────────────────────────────────┘ │ └───────────────────────┘ │
│ └──────────────────────────────────────────────┘                           │
│  └────────── main  1fr (≈640) ──────────┘  gap 32  └── aside 320 ──┘       │
│                                                                            │
│ ┌────────────────────────────────────────────────────────────────────────┐ │
│ │ [멍계란] 비공식 팬페이지예요 · made by 사우나범           [맨 위로 ↑] │ │ FOOTER
│ └────────────────────────────────────────────────────────────────────────┘ │
│                                                        ╔═══════════════╗   │
│                                                        ║ ✏ 주접쓰기    ║   │ FAB 유지
│                                                        ╚═══════════════╝   │ right:32
└────────────────────────────────────────────────────────────────────────────┘
```

### 그리드 CSS (공용)

```css
.wrap{ width:100%; max-width:var(--wrap); margin-inline:auto;
       padding-inline:var(--gutter); }
main{ padding-bottom:96px; }                     /* FAB 회피 */

/* 모바일 퍼스트 : 1단 */
.layout{ display:grid; gap:var(--s8); }

@media (min-width:900px){
  :root{ --gutter:32px; }
  .layout{ grid-template-columns:1fr 320px; gap:var(--s8); align-items:start; }
  .layout > .col-main{ grid-column:1; }
  .layout > .col-side{ grid-column:2; position:sticky; top:88px; display:grid; gap:var(--s6); }
  .hot-grid{ grid-template-columns:1fr 1fr; }    /* 인기글만 2열 */
  main{ padding-bottom:var(--s16); }
}
.hot-grid{ display:grid; gap:var(--s5); }

/* 인사해요 : 모바일 가로 캐러셀 → 데스크탑 세로 리스트 */
.greet{ display:flex; gap:var(--s4); overflow-x:auto; scroll-snap-type:x mandatory;
        padding-bottom:var(--s2); -webkit-overflow-scrolling:touch; }
.greet > *{ flex:0 0 240px; scroll-snap-align:start; }
.greet::-webkit-scrollbar{ height:8px; }
@media (min-width:900px){
  .greet{ display:grid; overflow:visible; }
  .greet > *{ flex:none; }
}

/* FAB */
.fab{
  position:fixed; right:var(--gutter);
  bottom:calc(20px + env(safe-area-inset-bottom));
  z-index:60; min-height:52px; padding:0 var(--s5);
  display:inline-flex; align-items:center; gap:var(--s2);
  background:var(--yolk); color:var(--ink);
  border:var(--bd-thick); border-radius:var(--r-pill);
  box-shadow:var(--sh-lg); clip-path:var(--clip);
  font:500 var(--t-ui)/1 var(--font-body);
}
```

---

## C-2. 스킨 토글 UI

헤더 우측, 닉네임 옆. **세그먼트 2칸짜리 작은 토글**이다. 드롭다운이나 설정 페이지로 숨기지 않는다 — 두 스킨 다 보여주는 게 이 페이지의 재미다.

### 카피

| 위치 | 카피 |
|---|---|
| 토글 라벨 (a11y) | `화면 스타일 바꾸기` |
| 옵션 1 | `손그림` (보조: `도감`) |
| 옵션 2 | `픽셀` (보조: `8비트`) |
| 전환 토스트 (A→B) | `삐빅- 8비트 모드로 입장합니다` |
| 전환 토스트 (B→A) | `종이랑 볼펜 다시 꺼냈어요` |

### 마크업 + CSS

```html
<div class="skin-toggle" role="radiogroup" aria-label="화면 스타일 바꾸기">
  <button role="radio" aria-checked="true"  data-skin-val="doodle">손그림</button>
  <button role="radio" aria-checked="false" data-skin-val="pixel">픽셀</button>
</div>
```
```css
.skin-toggle{
  display:inline-flex; padding:3px; gap:2px;
  background:var(--card-2); border:var(--bd); border-radius:var(--r-pill);
  clip-path:var(--clip);
}
.skin-toggle button{
  min-height:38px; padding:0 12px;            /* 시각 높이 38, 아래 터치 확장 */
  position:relative;
  font:500 var(--t-meta)/1 var(--font-body);
  color:var(--grey); background:transparent; border:0; cursor:pointer;
  border-radius:var(--r-pill); clip-path:var(--clip);
}
/* 터치 타겟 44px 확보 — 시각 크기는 유지하고 히트영역만 키운다 */
.skin-toggle button::after{
  content:""; position:absolute; inset:-3px -2px; min-height:44px;
}
.skin-toggle button[aria-checked="true"]{
  background:var(--yolk); color:var(--ink);
  box-shadow:var(--sh-sm);
}
.skin-toggle button:focus-visible{ outline:3px solid var(--blue-ink); outline-offset:2px; }
```

### JS (localStorage 저장 · FOUC 방지)

```html
<!-- <head> 최상단, 렌더 전에 실행해야 깜빡임이 없다 -->
<script>
(function(){
  try{
    var s = localStorage.getItem('gs-skin');
    if(s === 'doodle' || s === 'pixel') document.documentElement.dataset.skin = s;
  }catch(e){}            /* 프라이빗 모드 / 차단 시 기본값 doodle 유지 */
})();
</script>
```
```js
document.querySelectorAll('[data-skin-val]').forEach(function(b){
  b.addEventListener('click', function(){
    var v = b.dataset.skinVal;
    document.documentElement.dataset.skin = v;
    document.querySelectorAll('[data-skin-val]').forEach(function(x){
      x.setAttribute('aria-checked', String(x === b));
    });
    try{ localStorage.setItem('gs-skin', v); }catch(e){}
    toast(v === 'pixel' ? '삐빅- 8비트 모드로 입장합니다' : '종이랑 볼펜 다시 꺼냈어요');
  });
  /* ← → 키로도 이동 (radiogroup 규약) */
  b.addEventListener('keydown', function(e){
    if(e.key === 'ArrowRight' || e.key === 'ArrowLeft'){
      e.preventDefault();
      (b.nextElementSibling || b.previousElementSibling).focus();
      (b.nextElementSibling || b.previousElementSibling).click();
    }
  });
});
```

> **localStorage는 실패할 수 있다.** 프라이빗 창, 사이트 데이터 차단, iframe 프리뷰에서
> 읽기·쓰기 모두 throw하거나 빈 값을 준다. 반드시 `try/catch`로 감싸고,
> **없어도 기본 스킨(`doodle`)으로 정상 렌더**되게 둔다.

### 전환 시 주의

- 토글은 **`data-skin` 속성만 바꾼다.** DOM 재생성·클래스 교체 금지 → 스크롤 위치·입력값·모달 상태가 전부 유지된다.
- 폰트는 §A-3 링크 하나로 **두 스킨 것을 이미 다 받아놨다** → 전환 순간 FOUT 없음.
- `transition`을 `*`에 걸어두면 전환 때 모든 요소가 한꺼번에 움직여서 어지럽다. 전환 직후 0.3초만 transition을 끄는 게 안전하다.
  ```js
  document.documentElement.classList.add('no-anim');
  setTimeout(function(){ document.documentElement.classList.remove('no-anim'); }, 300);
  ```
  ```css
  .no-anim *{ transition:none !important; animation:none !important; }
  ```

---

## C-3. 접근성 체크리스트

### 색 대비 (WCAG AA)

- [ ] **본문 텍스트 4.5:1 이상** — 라이트/다크 × 손그림/픽셀 **4가지 조합 전부** 검사
- [ ] 큰 텍스트(24px+/굵은 19px+)는 3:1 이상 — `--t-hero`, `--t-h1`은 여기 해당
- [ ] **`--blue`는 텍스트 색으로 쓰지 않는다** (A: 2.83:1 / B: 3.22:1 모두 불합격). 링크 텍스트는 반드시 `--blue-ink`
- [ ] **`--grey-mute`는 텍스트 금지** (2.49:1). 장식선·비활성 아이콘 전용
- [ ] **`--grey` 텍스트는 카드 위에서만.** `--bg`(하늘색) 위에 올리면 2.86:1로 떨어진다 → 배경 직접 위 텍스트는 `--ink`
- [ ] 뱃지처럼 색으로만 구분되는 요소는 **텍스트 라벨을 반드시 병기** (`HOT`, `NEW`, `내 글`)
- [ ] 픽셀 스킨 체커 배경 위에 텍스트를 직접 올리지 않는다 — 반드시 `--card` 면 위에

### 포커스

- [ ] `:focus-visible`에 **3px 이상 아웃라인 + offset 2px**. `outline:none` 단독 사용 절대 금지
- [ ] 포커스 링 색은 `--blue-ink` (양 스킨 모두 4.5:1 이상 확보한 값)
- [ ] 노란 버튼(`--yolk`) 위 포커스 링이 묻히지 않는지 확인 → 필요시 `outline-color:var(--line)`로 교체
- [ ] 모달 열릴 때 포커스를 모달 안으로, 닫을 때 **열었던 버튼으로 복귀**
- [ ] 모달 안에서 Tab 순환 가둠(focus trap), `Esc`로 닫기
- [ ] `clip-path`를 쓴 요소는 **아웃라인이 잘린다** → 픽셀 스킨 포커스는 `outline-offset:0` 또는 `box-shadow:0 0 0 3px` 방식으로

```css
:focus-visible{ outline:3px solid var(--blue-ink); outline-offset:2px; border-radius:inherit; }
[data-skin="pixel"] :focus-visible{ outline-offset:0; }  /* clip-path 잘림 회피 */
.btn--primary:focus-visible{ outline-color:var(--line); }
```

### 터치 타겟

- [ ] **모든 인터랙티브 요소 44×44px 이상** (WCAG 2.5.5 / iOS HIG)
- [ ] 시각적으로 작아야 하는 토글·아이콘 버튼은 **가상 요소로 히트영역만 확장** (§C-2 방식)
- [ ] 인접 타겟 간 최소 간격 8px — 좋아요/댓글 버튼 나란히 둘 때 주의
- [ ] FAB은 `env(safe-area-inset-bottom)` 반영 (아이폰 홈 인디케이터 겹침 방지)

### 시맨틱 / 스크린리더

- [ ] 섹션마다 `<section aria-labelledby>` + 실제 `<h2>` 연결. 헤딩 레벨 건너뛰지 않기 (h1→h2→h3)
- [ ] 좋아요는 `<button aria-pressed>`. 카운트는 `aria-label="공감 24개"`로 숫자를 읽어주기
- [ ] 글자별 `<span>`으로 쪼갠 대제목에 **`aria-label="업다운 팬클럽!"` 필수** (안 하면 한 글자씩 끊어 읽음)
- [ ] 모든 장식 SVG에 `aria-hidden="true"`. 의미 있는 SVG는 `role="img"` + `<title>`
- [ ] 캐릭터 SVG가 정보를 전달할 때(빈 상태 등)는 옆 텍스트가 같은 내용을 말하고, SVG는 `aria-hidden`
- [ ] 스킨 토글은 `role="radiogroup"` + `aria-checked` + ←→ 키 지원
- [ ] 토스트는 `role="status" aria-live="polite"` (알림이 낭독되되 작업을 끊지 않음)
- [ ] 외부 링크(`사장님 활동`)에 `rel="noopener noreferrer"` + 새 창임을 텍스트로 안내

### 모션 · 기타

- [ ] `prefers-reduced-motion: reduce`에서 **무한 루프 전부 정지**, 상태 피드백은 색/그림자/테두리로 대체 (§A-7, §B-7)
- [ ] `prefers-contrast: more`에서 `--grey` → `--ink-soft`, 테두리 두께 +1px
- [ ] 200% 확대 시 가로 스크롤 없음 (`overflow-x:hidden`으로 감추지 말고 실제로 안 넘치게)
- [ ] `lang="ko"` 선언, `<title>`은 2~4 단어
- [ ] 다크모드에서 `--line`이 밝아지므로 **그림자를 검정으로 하드코딩한 곳이 없는지** 전수 확인

```css
@media (prefers-contrast: more){
  :root{ --grey:var(--ink-soft); --bd:3px solid var(--line); --bd-thick:4px solid var(--line); }
}
```

---

## 부록 — 구현 체크리스트

- [ ] `<html lang="ko" data-skin="doodle">` + `<head>` 최상단 FOUC 방지 스크립트
- [ ] Google Fonts link 1개에 6개 패밀리 (Black Han Sans / Do Hyeon / Gaegu / Noto Sans KR / Press Start 2P / Silkscreen)
- [ ] 공용 구조 토큰 → 스킨 A 라이트 → A 다크 → 스킨 B 라이트 → B 다크 **순서대로** 선언
- [ ] 컴포넌트 CSS에 하드코딩 색·라운드·그림자가 없는지 `grep -n '#[0-9a-fA-F]\{3,6\}'`로 확인 (`[data-skin]` 블록 밖에서 나오면 안 됨)
- [ ] 스킨 전환 후 스크롤 위치·textarea 입력값이 유지되는지 확인
- [ ] 4조합(A라이트/A다크/B라이트/B다크) × 2뷰포트(360/1024) = **8화면 캡처 검수**
