# create

텍스트 또는 주제를 입력받아 HTML 프레젠테이션 파일을 생성합니다.

## Usage

```
/ppt-maker:create <topic> [--theme <theme-name>] [--slides <count>] [--lang <ko|en>] [--company <name>]
```

## Arguments

- `<topic>`: 발표 주제 또는 내용 (필수). 짧은 키워드 또는 긴 본문 모두 가능.
- `--theme <name>`: 적용할 테마 이름 (기본값: daewoong).
- `--slides <count>`: 목표 슬라이드 수 (기본값: 자동, 8-15장).
- `--lang <ko|en>`: 출력 언어 (기본값: ko).
- `--company <name>`: 슬라이드 헤더에 표시할 회사/발표자 텍스트.

## Instructions

1. 사용자 입력에서 `<topic>`과 옵션 플래그를 파싱한다.

2. `slide-architect` 에이전트를 호출하여 슬라이드 구조 JSON을 받아온다.

3. 에이전트로부터 다음 JSON 형식을 수신한다:
   ```json
   {
     "title": "발표 제목",
     "subtitle": "부제목 또는 날짜/발표자",
     "theme": "daewoong",
     "slides": [
       {
         "layout": "title|section|content|cards|two-column|quote|closing",
         "chapter": "헤더 좌측 챕터 레이블 (상위 › 하위 형태도 가능)",
         "alert_bar": "슬라이드 상단 배너 텍스트 (선택)",
         "title": "슬라이드 제목",
         "subtitle": "부제목 (title/closing만)",
         "points": ["bullet1", "bullet2"],
         "rows": [{"label": "항목명", "value": "내용"}],
         "example": "예시 텍스트나 코드 (선택)",
         "cards": [
           {"icon": "🔑", "title": "카드 제목", "label": "1단계", "card_list": ["불릿1", "불릿2"]}
         ],
         "left_title": "좌측 소제목 (two-column만)",
         "left": "좌측 본문",
         "left_rows": [{"label": "항목", "value": "내용"}],
         "left_example": "좌측 예시",
         "right_title": "우측 소제목 (two-column만)",
         "right": "우측 본문",
         "right_rows": [{"label": "항목", "value": "내용"}],
         "right_example": "우측 예시",
         "quote": "인용구 (quote만)",
         "attribution": "출처 (quote만)",
         "summary_bar": "슬라이드 하단 요약 메시지 (선택)",
         "notes": "발표자 노트"
       }
     ]
   }
   ```

4. `--theme` 값이 지정된 경우 JSON의 theme 값을 override한다. 기본값은 `daewoong`.

5. 오늘 날짜를 `date +%Y-%m-%d` 로 가져온다. title-slug 계산:
   - 제목에서 영문/숫자만 추출 → 소문자 kebab-case
   - 결과가 3자 미만이면 `slide-$(date +%Y%m%d)` fallback

6. `mkdir -p {plugin-dir}/output/YYYY-MM-DD/{title-slug}/` 로 디렉토리 생성.

7. Write 도구로 `index.html` 생성. 아래 HTML/CSS/JS 사양을 정확히 따른다.

---

### HTML 골격

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{발표 제목}</title>
<style>/* 아래 CSS 전체 인라인 */</style>
</head>
<body>
<button class="btn-pdf" onclick="printSlides()" aria-label="PDF로 저장">
  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
    <path d="M12 3v13M7 11l5 5 5-5"/>
    <path d="M3 19h18"/>
  </svg>
</button>
<div class="slideshow">
  <!-- 슬라이드들 (각 .slide 에는 tabindex="0" role="group" aria-label="슬라이드 N") -->
</div>
<nav class="nav-bar" aria-label="슬라이드 네비게이션">
  <button class="nav-btn" id="nav-prev" onclick="show(cur-1)" aria-label="이전 슬라이드">← 이전</button>
  <span class="nav-counter" id="nav-counter" aria-live="polite"></span>
  <button class="nav-btn" id="nav-next" onclick="show(cur+1)" aria-label="다음 슬라이드">다음 →</button>
</nav>
<script>/* 아래 JS 인라인 */</script>
</body>
</html>
```

> **중요**: PDF 버튼은 절대 `window.print()` 를 직접 호출하지 말고 항상 `printSlides()` 를 사용한다 (인쇄 전 모든 슬라이드를 표시하고 JS 인라인 transform 을 제거하기 위함).

---

### CSS — 테마 변수

`daewoong` (기본값):
```css
:root {
  --primary: #F09820;
  --primary-light: #F5C860;
  --primary-pale: #FDE9C0;
  --primary-strong: #C97A0E; /* summary-bar strong 등 대비 강화용 */
  --bg: #FFFFFF;
  --slide-bg: #FFFFFF;
  --text: #2E2E2E;
  --text-body: #555555;
  --text-light: #AAAAAA;
  --card-bg: #F8F8F8;
  --font: "Apple SD Gothic Neo", "Malgun Gothic", "Noto Sans KR", sans-serif;
}
```

`professional-light`:
```css
:root {
  --primary: #1a2e5a; --primary-light: #4a6fa5; --primary-pale: #dce8f5;
  --primary-strong: #0f1f40;
  --bg: #ffffff; --slide-bg: #fff; --text: #1a1a1a;
  --text-body: #444; --text-light: #999; --card-bg: #f8f9fc;
  --font: "Apple SD Gothic Neo", "Malgun Gothic", "Noto Sans KR", sans-serif;
}
```

`dark-elegant`:
```css
:root {
  --primary: #c9a84c; --primary-light: #e8cc80; --primary-pale: #3a3018;
  --primary-strong: #e8cc80;
  --bg: #111118; --slide-bg: #1a1a2e; --text: #f0f0f0;
  --text-body: #ccc; --text-light: #888; --card-bg: #22223a;
  --font: "Apple SD Gothic Neo", "Malgun Gothic", "Noto Sans KR", sans-serif;
}
```

`minimal-gray`:
```css
:root {
  --primary: #2d3748; --primary-light: #4a6080; --primary-pale: #e8edf5;
  --primary-strong: #1a202c;
  --bg: #f7f7f7; --slide-bg: #fff; --text: #2d3748;
  --text-body: #4a5568; --text-light: #a0aec0; --card-bg: #f4f6f8;
  --font: "Apple SD Gothic Neo", "Malgun Gothic", "Noto Sans KR", sans-serif;
}
```

`corporate-blue`:
```css
:root {
  --primary: #93c5fd; --primary-light: #bfdbfe; --primary-pale: #1e3a5f;
  --primary-strong: #ffffff;
  --bg: #162a45; --slide-bg: #1e3a5f; --text: #f0f8ff;
  --text-body: #c8dff5; --text-light: #7ba8d0; --card-bg: #254a70;
  --font: "Apple SD Gothic Neo", "Malgun Gothic", "Noto Sans KR", sans-serif;
}
```

---

### CSS — 기본 레이아웃 (1280×720 고정 캔버스)

```css
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body { background: var(--bg); font-family: var(--font); overflow: hidden; }

/* 슬라이드쇼 컨테이너 — 네비 높이(56px) 제외 */
.slideshow {
  width: 100vw;
  height: calc(100vh - 56px);
  display: flex; align-items: center; justify-content: center;
}

/* 슬라이드 고정 캔버스 1280×720 (JS 가 scale 로 뷰포트에 맞춤) */
.slide {
  display: none;
  position: relative;
  width: 1280px; height: 720px;
  flex-shrink: 0;
  background: var(--slide-bg);
  overflow: hidden;
  flex-direction: column;
  transform-origin: center center;
  outline: none;
}
.slide.active { display: flex; }
.slide:focus-visible { outline: none; }

/* 슬라이드 상단 오렌지 그라데이션 스트립 (title 레이아웃 제외) */
.slide::before {
  content: '';
  position: absolute; top: 0; left: 0; right: 0;
  height: 5px;
  background: linear-gradient(90deg, var(--primary) 70%, var(--primary-light));
  z-index: 10;
  pointer-events: none;
}

/* 슬라이드 헤더 (title 레이아웃 제외) */
.slide-header {
  display: flex; justify-content: space-between; align-items: center;
  padding: 14px 60px 13px;
  background: rgba(240,152,32,0.04);
  border-bottom: 1px solid rgba(0,0,0,0.06);
  flex-shrink: 0;
}
.chapter-label { color: var(--primary); font-size: 14px; font-weight: 800; letter-spacing: 0.05em; }
.chapter-label .crumb-sep { color: var(--text-light); margin: 0 8px; font-weight: 600; }
.chapter-label .crumb-current { color: var(--text); }
.logo-text { color: var(--text-light); font-size: 13px; font-weight: 700; letter-spacing: 0.1em; }

/* 슬라이드 바디 (클릭 시 다음 슬라이드로) */
.slide-body {
  flex: 1; overflow: hidden;
  display: flex; flex-direction: column; justify-content: center;
  padding: 24px 72px 20px;
  cursor: pointer;
}

/* 슬라이드 푸터 — 테두리 없음, 높이 0 */
.slide-footer { flex-shrink: 0; height: 0; }
```

---

### CSS — 알림 바 (alert_bar)

```css
.alert-bar {
  background: rgba(240,152,32,0.09);
  border: 1.5px solid rgba(240,152,32,0.28);
  border-radius: 8px;
  padding: 13px 22px;
  margin-bottom: 18px;
  font-size: 16px; color: var(--text-body);
  display: flex; align-items: flex-start; gap: 12px;
  flex-shrink: 0; line-height: 1.55;
  word-break: keep-all;
}
.alert-bar .alert-icon { font-size: 18px; flex-shrink: 0; margin-top: 1px; line-height: 1.5; }
.alert-bar .alert-text { flex: 1; }
.alert-bar strong { color: var(--primary); font-weight: 800; }
```

> 텍스트가 2줄로 줄바꿈되어도 아이콘이 첫 줄 상단에 정렬된다 (`align-items: flex-start` + `.alert-text { flex: 1 }`).

---

### CSS — 타이틀 슬라이드 (전체 오렌지 배경)

타이틀 슬라이드는 흰 배경 대신 **브랜드 오렌지 그라데이션 전체 배경**을 사용한다.
상단 스트립(`::before`)은 타이틀에서 숨기고, 유기적 blob 도형으로 깊이감을 연출한다.

```css
/* 타이틀 레이아웃 — 전체 오렌지 그라데이션 배경 */
.layout-title {
  background: linear-gradient(145deg, #F8B020 0%, #F09820 45%, #D97B0C 100%);
}
/* 상단 스트립 숨김 (배경색과 겹침) */
.layout-title::before { display: none; }

/* 유기적 원형 blob 도형 (배경 깊이감) */
.blob-bottom {
  position: absolute;
  bottom: -40%; left: -14%;
  width: 80%; height: 84%;
  background: rgba(175, 100, 0, 0.36);
  border-radius: 50%;
  pointer-events: none;
}
.blob-right {
  position: absolute;
  top: -58%; right: -24%;
  width: 64%; height: 136%;
  background: rgba(190, 112, 0, 0.26);
  border-radius: 50%;
  pointer-events: none;
}

.layout-title .slide-body {
  padding: 58px 84px 50px;
  justify-content: space-between;
  align-items: flex-start;
  flex-direction: column;
  z-index: 1;
}

/* 회사명/발표 컨텍스트 레이블 */
.slide-category {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  font-weight: 800;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  background: rgba(255,255,255,0.18);
  color: rgba(255,255,255,0.96);
  border: 1.5px solid rgba(255,255,255,0.38);
  border-radius: 100px;
  padding: 7px 22px;
  margin-bottom: 26px;
}

/* 메인 타이틀 — 흰색 대형 */
.layout-title h1 {
  font-size: 90px;
  font-weight: 900;
  color: #FFFFFF;
  line-height: 1.04;
  word-break: keep-all;
  letter-spacing: -0.025em;
  text-shadow: 0 4px 36px rgba(0,0,0,0.22);
  margin-bottom: 18px;
}
.layout-title h1 em { font-style: normal; color: rgba(255,255,255,0.88); }

/* 부제목 */
.title-subtitle {
  font-size: 18px;
  font-weight: 600;
  color: rgba(255,255,255,0.78);
  letter-spacing: 0.05em;
}
.title-subtitle strong { color: #fff; font-weight: 800; }

/* 하단 통계/키포인트 바 */
.title-stats-bar {
  width: 100%;
  display: flex;
  border-top: 1px solid rgba(255,255,255,0.32);
  padding-top: 22px;
}
.title-stat {
  flex: 1;
  display: flex; flex-direction: column; gap: 7px;
  padding-right: 32px;
}
.title-stat + .title-stat {
  padding-left: 32px;
  border-left: 1px solid rgba(255,255,255,0.22);
}
.title-stat-num {
  font-size: 28px; font-weight: 900; color: #fff;
  line-height: 1; letter-spacing: -0.01em;
}
.title-stat-label {
  font-size: 13px; font-weight: 600;
  color: rgba(255,255,255,0.68); letter-spacing: 0.04em;
}
```

---

### CSS — 섹션 슬라이드

```css
.layout-section .slide-body { justify-content: center; align-items: flex-start; }
.layout-section h2 {
  font-size: 48px; font-weight: 800; color: var(--text);
  line-height: 1.3;
  border-left: 7px solid var(--primary); padding-left: 28px;
}
```

---

### CSS — 콘텐츠 슬라이드

```css
.layout-content .slide-body { justify-content: flex-start; padding-top: 22px; }
.layout-content h2 {
  font-size: 34px; font-weight: 800; color: var(--text);
  margin-bottom: 16px; line-height: 1.3; flex-shrink: 0;
}
.layout-content ul { list-style: none; }
.layout-content ul li {
  position: relative; padding-left: 22px;
  font-size: 18px; color: var(--text-body); line-height: 1.85;
  word-break: keep-all;
}
.layout-content ul li::before {
  content: '\203A'; /* › chevron */
  position: absolute; left: 0; top: 0;
  color: var(--primary); font-size: 20px; font-weight: 900;
}

/* 레이블:값 행 테이블 (zebra-stripe) */
.rows-table { width: 100%; margin-top: 12px; border-collapse: collapse; }
.rows-table tr:nth-child(even) td { background: rgba(240,152,32,0.04); }
.rows-table td {
  padding: 9px 12px; vertical-align: top;
  border-bottom: 1px solid rgba(0,0,0,0.04);
}
.rows-table td:first-child {
  width: 28%; font-size: 14px; color: var(--text-light); font-weight: 700;
  letter-spacing: 0.02em;
}
.rows-table td:last-child { font-size: 17px; color: var(--text); font-weight: 700; }

/* 예시 박스 */
.example-box {
  background: var(--card-bg);
  border: 1px solid rgba(0,0,0,0.07);
  border-radius: 7px; padding: 12px 18px; margin-top: 14px;
  font-size: 14px; color: var(--text-body); line-height: 1.65;
  font-style: italic; flex-shrink: 0;
}
```

---

### CSS — cards 슬라이드

```css
.layout-cards .slide-body { justify-content: flex-start; padding-top: 20px; }
.layout-cards h2 {
  font-size: 38px; font-weight: 900; color: var(--text);
  margin-bottom: 20px; flex-shrink: 0; line-height: 1.2;
}
.cards-row {
  display: flex; align-items: stretch; gap: 14px;
  flex: 1; min-height: 0;
}
.card-item {
  flex: 1 1 0; min-width: 0;
  background: var(--card-bg);
  border: 1.5px solid rgba(240,152,32,0.18);
  border-left: 5px solid var(--primary);
  border-radius: 10px; padding: 22px 24px;
  display: flex; flex-direction: column;
}
.card-connector {
  display: flex; align-items: center; justify-content: center;
  width: 28px; color: var(--primary); font-size: 26px;
  flex-shrink: 0; opacity: 0.55;
}

/* 카드 단계/카테고리 레이블 — 오렌지 필 배지 */
.card-label {
  display: inline-block;
  font-size: 11px; font-weight: 800; letter-spacing: 0.12em;
  color: var(--primary); text-transform: uppercase;
  background: var(--primary-pale);
  border-radius: 100px; padding: 3px 12px;
  margin-bottom: 12px;
}

/* 카드 아이콘 배지 — 이모지를 오렌지 박스에 담음 */
.card-icon-badge {
  display: inline-flex; align-items: center; justify-content: center;
  width: 40px; height: 40px;
  background: var(--primary-pale);
  border-radius: 10px; font-size: 20px;
  flex-shrink: 0;
}

.card-title {
  font-size: 21px; font-weight: 900; color: var(--text);
  margin-bottom: 16px;
  display: flex; align-items: center; gap: 10px;
  padding-bottom: 12px;
  border-bottom: 1.5px solid rgba(240,152,32,0.2);
}

/* card_list (개조식 불릿) — body 보다 우선 사용 */
.card-list { list-style: none; display: flex; flex-direction: column; gap: 9px; flex: 1; }
.card-list li {
  font-size: 18px; color: var(--text-body); font-weight: 600;
  line-height: 1.5; display: flex; align-items: flex-start; gap: 10px;
  word-break: keep-all;
}
.card-list li::before {
  content: '\203A'; /* › chevron — 모든 OS 에서 안정적으로 렌더 */
  color: var(--primary); font-size: 22px; font-weight: 900; line-height: 1.2;
  flex-shrink: 0;
}
/* 폴백: card_list 가 없을 때 body 텍스트 */
.card-body { font-size: 15px; color: var(--text-body); line-height: 1.75; flex: 1; }
```

> **`card_list` vs `body`**:
> - **`card_list` (배열) — 기본**: 짧은 개념·단계·특징을 나열할 때. 한 슬라이드 내 모든 카드가 동일 형식이어야 한다.
> - **`body` (문자열) — 예외**: 한두 문장의 서술형 정의일 때만 사용.

---

### CSS — two-column 슬라이드

```css
.layout-two-column .slide-body { justify-content: flex-start; padding-top: 22px; }
.layout-two-column > .slide-body > h2 {
  font-size: 32px; font-weight: 800; color: var(--text);
  margin-bottom: 16px; flex-shrink: 0;
}
.columns { display: grid; grid-template-columns: 1fr 1fr; gap: 28px; flex: 1; min-height: 0; }
.col {
  background: var(--card-bg);
  border: 1.5px solid rgba(240,152,32,0.18);
  border-radius: 10px; padding: 22px 24px;
  display: flex; flex-direction: column;
}
.col-header {
  display: flex; align-items: center; gap: 10px;
  font-size: 19px; font-weight: 800; color: var(--primary);
  margin-bottom: 14px; padding-bottom: 10px;
  border-bottom: 1.5px solid rgba(240,152,32,0.2);
  flex-shrink: 0;
}
.col-header .col-icon { font-size: 22px; }
.col-body { font-size: 16px; color: var(--text-body); line-height: 1.75; margin-bottom: 8px; }
```

---

### CSS — quote 슬라이드

```css
.layout-quote .slide-body { align-items: center; justify-content: center; text-align: center; }
.layout-quote .quote-mark {
  font-size: 96px; color: var(--primary); line-height: 0.7;
  font-family: Georgia, serif; margin-bottom: 16px;
}
.layout-quote blockquote {
  font-size: 30px; font-weight: 700; color: var(--text);
  line-height: 1.55; max-width: 78%; margin-bottom: 22px;
  word-break: keep-all;
}
.layout-quote cite {
  font-size: 16px; color: var(--primary); font-weight: 600; font-style: normal;
}
```

---

### CSS — closing 슬라이드

```css
.layout-closing .slide-body { align-items: center; justify-content: center; text-align: center; z-index: 1; }
.layout-closing h1 { font-size: 52px; font-weight: 800; color: var(--text); margin-bottom: 18px; }
.closing-bar { width: 80px; height: 4px; background: var(--primary); margin: 0 auto 22px; border-radius: 2px; }
.layout-closing .slide-subtitle { font-size: 19px; color: var(--primary); font-weight: 600; }
```

---

### CSS — 요약 바 (summary_bar)

```css
.summary-bar {
  background: rgba(240,152,32,0.07);
  border: 1.5px solid rgba(240,152,32,0.22);
  border-radius: 9px; padding: 14px 24px;
  margin-top: 18px;
  font-size: 18px; color: var(--text-body); line-height: 1.6;
  flex-shrink: 0; font-weight: 500; word-break: keep-all;
}
/* 대비 강화: --primary-strong 사용 */
.summary-bar strong { color: var(--primary-strong); font-weight: 900; }
```

---

### CSS — PDF 버튼, 네비게이션, 인쇄

```css
/* PDF 다운로드 아이콘 버튼 */
.btn-pdf {
  position: fixed; top: 12px; right: 18px; z-index: 9999;
  background: var(--primary); color: #fff; border: none;
  border-radius: 8px;
  width: 40px; height: 40px;
  display: flex; align-items: center; justify-content: center;
  cursor: pointer;
  box-shadow: 0 3px 12px rgba(240,152,32,0.38);
  transition: opacity 0.15s, transform 0.1s;
}
.btn-pdf:hover { opacity: 0.85; transform: translateY(-1px); }
.btn-pdf:active { transform: translateY(0); }
.btn-pdf:focus-visible { outline: 3px solid #fff; outline-offset: 2px; }

/* 하단 네비게이션 바 — 높이 56px, 흰 배경, 상단 오렌지 구분선 */
.nav-bar {
  position: fixed; bottom: 0; left: 0; right: 0; height: 56px;
  display: flex; align-items: center; justify-content: space-between;
  padding: 0 48px;
  background: #FFFFFF;
  border-top: 2px solid var(--primary);
  box-shadow: 0 -2px 12px rgba(0,0,0,0.08);
}
.nav-btn {
  background: none; border: 2px solid transparent; cursor: pointer;
  color: var(--text-body); font-size: 15px; font-weight: 800;
  font-family: var(--font); padding: 8px 20px; border-radius: 0;
  transition: color 0.15s, background 0.15s, border-color 0.15s;
  letter-spacing: 0.03em;
}
.nav-btn:hover { color: var(--primary); background: rgba(240,152,32,0.08); border-color: rgba(240,152,32,0.35); }
.nav-btn:focus-visible { outline: 2px solid var(--primary); outline-offset: 2px; }

/* 페이지 카운터: zero-padded 01 / 02, 현재 페이지는 오렌지 대형 */
.nav-counter {
  font-size: 17px; color: var(--text);
  font-weight: 800; font-family: var(--font);
  letter-spacing: 0.1em; font-variant-numeric: tabular-nums;
}
.nav-counter .nav-current { color: var(--primary); font-size: 20px; }

/* 인쇄 (16:9 비율 297×167mm) — JS 인라인 transform 을 !important 로 무력화 */
@media print {
  html, body {
    overflow: visible !important;
    width: 297mm !important;
    height: auto !important;
    background: white !important;
  }
  .btn-pdf, .nav-bar { display: none !important; }
  .slideshow {
    display: block !important;
    width: 100% !important;
    height: auto !important;
  }
  .slide {
    display: flex !important;
    width: 297mm !important;
    height: 167mm !important;
    max-width: none !important;
    transform: none !important;
    box-shadow: none !important;
    page-break-before: always;
    page-break-inside: avoid;
    break-before: page;
    break-inside: avoid;
  }
  .slide:first-child { page-break-before: auto; break-before: auto; }
  @page { margin: 0; size: 297mm 167mm; }
}
```

---

### 슬라이드 HTML 생성 규칙

**모든 `.slide`** 에는 접근성을 위해 `tabindex="0" role="group" aria-label="슬라이드 N"` 을 부여한다.

**`alert_bar` 렌더링** (선택적, 모든 레이아웃에서 `.slide-body` 최상단에 삽입):
```html
<div class="alert-bar">
  <span class="alert-icon">⚡</span>
  <span class="alert-text">{alert_bar 텍스트. 강조 부분은 <strong>으로 감쌈}</span>
</div>
```

**`summary_bar` 렌더링** (선택적, `.slide-body` 최하단에 삽입):
```html
<div class="summary-bar">{summary_bar 텍스트. 강조 단어는 <strong>으로 감쌈}</div>
```

**rows 테이블 렌더링** (zebra-stripe 자동 적용):
```html
<table class="rows-table">
  <tr><td>항목1</td><td>내용1</td></tr>
  <tr><td>항목2</td><td>내용2</td></tr>
</table>
```

**chapter 의 breadcrumb** (`chapter` 값에 ` - ` 또는 ` › ` 가 포함되면 분리하여 렌더):
```html
<span class="chapter-label">
  상위챕터<span class="crumb-sep">›</span><span class="crumb-current">하위챕터</span>
</span>
```

**example 박스 렌더링**:
```html
<div class="example-box">{example 텍스트}</div>
```

---

**title 슬라이드** — 전체 오렌지 배경 + 원형 blob + 하단 통계 바:
```html
<div class="slide layout-title" tabindex="0" role="group" aria-label="슬라이드 1">
  <div class="blob-bottom"></div>
  <div class="blob-right"></div>
  <div class="slide-body">
    <div>
      <!-- subtitle → 상단 필 레이블 (회사명·컨텍스트 태그) -->
      <p class="slide-category">{subtitle}</p>
      <h1>{title}</h1>
      <!-- example → h1 아래 부제목 한 줄 (날짜·발표자·맥락) -->
      {example 있으면: <p class="title-subtitle">{example (강조는 <strong>으로)}</p>}
    </div>
    <!-- points → 하단 통계 바 (없으면 전체 블록 생략)
         각 point 는 "수치|레이블" 형식. "|" 기준으로 분리하여 num/label 에 할당 -->
    {points 배열이 비어있지 않으면:
    <div class="title-stats-bar">
      <div class="title-stat">
        <span class="title-stat-num">{point.split("|")[0]}</span>
        <span class="title-stat-label">{point.split("|")[1]}</span>
      </div>
      <!-- 각 point 마다 반복 -->
    </div>
    }
  </div>
  <div class="slide-footer"></div>
</div>
```

> **title 슬라이드 필드 요약**:
> - `subtitle` → `.slide-category` 필 레이블 (회사명 또는 컨텍스트)
> - `title` → 대형 흰색 h1
> - `example` → h1 아래 부제목 줄 (날짜·발표자)
> - `points` → 하단 통계 바. 각 항목 `"수치|레이블"` 형식. 3~4개 권장. 없으면 생략.

**section 슬라이드:**
```html
<div class="slide layout-section" tabindex="0" role="group" aria-label="슬라이드 N">
  <div class="slide-header">
    <span class="chapter-label">{chapter}</span>
    <span class="logo-text">{company}</span>
  </div>
  <div class="slide-body"><h2>{title}</h2></div>
  <div class="slide-footer"></div>
</div>
```

**content 슬라이드** (points, rows, example 조합):
```html
<div class="slide layout-content" tabindex="0" role="group" aria-label="슬라이드 N">
  <div class="slide-header">
    <span class="chapter-label">{chapter (필요시 breadcrumb)}</span>
    <span class="logo-text">{company}</span>
  </div>
  <div class="slide-body">
    {alert_bar 있으면 삽입}
    <h2>{title}</h2>
    {points 있으면: <ul><li>...</li></ul>}
    {rows 있으면: rows-table}
    {example 있으면: example-box}
    {summary_bar 있으면 삽입}
  </div>
  <div class="slide-footer"></div>
  <!-- NOTES: {notes} -->
</div>
```

**cards 슬라이드** (2-4개 카드, `card_list` 우선):
```html
<div class="slide layout-cards" tabindex="0" role="group" aria-label="슬라이드 N">
  <div class="slide-header">
    <span class="chapter-label">{chapter}</span>
    <span class="logo-text">{company}</span>
  </div>
  <div class="slide-body">
    {alert_bar 있으면 삽입}
    <h2>{title}</h2>
    <div class="cards-row">
      <div class="card-item">
        {card.label 있으면: <div class="card-label">{label}</div>}
        <div class="card-title">
          {card.icon 있으면: <span class="card-icon-badge">{icon}</span>}
          {card.title}
        </div>
        {card.card_list 있으면:
          <ul class="card-list"><li>...</li></ul>
         else card.body 있으면:
          <div class="card-body">{body}</div>}
      </div>
      <div class="card-connector" aria-hidden="true">→</div>
      <div class="card-item">...</div>
      <!-- 카드 수에 맞게 반복, 마지막 카드 뒤에는 connector 없음 -->
    </div>
    {summary_bar 있으면 삽입}
  </div>
  <div class="slide-footer"></div>
  <!-- NOTES: {notes} -->
</div>
```

**two-column 슬라이드** (rows + example 지원):
```html
<div class="slide layout-two-column" tabindex="0" role="group" aria-label="슬라이드 N">
  <div class="slide-header">
    <span class="chapter-label">{chapter}</span>
    <span class="logo-text">{company}</span>
  </div>
  <div class="slide-body">
    {alert_bar 있으면 삽입}
    <h2>{title}</h2>
    <div class="columns">
      <div class="col">
        <div class="col-header"><span class="col-icon">{아이콘 없으면 생략}</span>{left_title}</div>
        {left 있으면: <p class="col-body">{left}</p>}
        {left_rows 있으면: rows-table}
        {left_example 있으면: example-box}
      </div>
      <div class="col">
        <div class="col-header">{right_title}</div>
        {right 있으면: <p class="col-body">{right}</p>}
        {right_rows 있으면: rows-table}
        {right_example 있으면: example-box}
      </div>
    </div>
    {summary_bar 있으면 삽입}
  </div>
  <div class="slide-footer"></div>
  <!-- NOTES: {notes} -->
</div>
```

**quote 슬라이드:**
```html
<div class="slide layout-quote" tabindex="0" role="group" aria-label="슬라이드 N">
  <div class="slide-header">
    <span class="chapter-label">{chapter}</span>
    <span class="logo-text">{company}</span>
  </div>
  <div class="slide-body">
    <div class="quote-mark">"</div>
    <blockquote>{quote}</blockquote>
    {attribution 있으면: <cite>— {attribution}</cite>}
  </div>
  <div class="slide-footer"></div>
</div>
```

**closing 슬라이드:**
```html
<div class="slide layout-closing" tabindex="0" role="group" aria-label="슬라이드 N">
  <div class="slide-header">
    <span></span>
    <span class="logo-text">{company}</span>
  </div>
  <div class="slide-body">
    <div class="closing-bar"></div>
    <h1>{title}</h1>
    <p class="slide-subtitle">{subtitle}</p>
  </div>
  <div class="slide-footer"></div>
</div>
```

---

### JavaScript — 네비게이션 / 인쇄 / 클릭 진행 / 접근성

> **반드시 `printSlides()` 패턴을 사용한다** — `window.print()` 직접 호출 시 인쇄에 활성 슬라이드 1장만 포함된다.
> 네비게이션 높이는 **56px** 이다 (`scaleSlides` 의 `vh - 56` 과 `.slideshow { height: calc(100vh - 56px) }` 일치).

```javascript
const slides   = document.querySelectorAll('.slide');
const counter  = document.getElementById('nav-counter');
const totalStr = String(slides.length).padStart(2, '0');
let cur = 0;

/* 뷰포트에 맞게 1280×720 캔버스를 scale — 네비 높이 56px 제외 */
function scaleSlides() {
  const vw = window.innerWidth;
  const vh = window.innerHeight - 56;
  const scale = Math.min(vw / 1280, vh / 720) * 0.96;
  slides.forEach(s => { s.style.transform = `scale(${scale})`; });
}

/* 슬라이드 전환 + zero-padded 카운터 + 활성 슬라이드 포커스 */
function show(n) {
  slides[cur].classList.remove('active');
  cur = (n + slides.length) % slides.length;
  const slide = slides[cur];
  slide.classList.add('active');

  const curStr = String(cur + 1).padStart(2, '0');
  counter.innerHTML = '<span class="nav-current">' + curStr + '</span> / ' + totalStr;

  document.getElementById('nav-prev').style.visibility = cur === 0 ? 'hidden' : 'visible';
  document.getElementById('nav-next').style.visibility = cur === slides.length - 1 ? 'hidden' : 'visible';

  if (slide.focus) {
    try { slide.focus({ preventScroll: true }); } catch (_) { slide.focus(); }
  }
}

/* PDF: 인쇄 전 모든 슬라이드 표시 + 인라인 transform 제거 */
function printSlides() {
  slides.forEach(s => {
    s.style.display   = 'flex';
    s.style.transform = 'none';
  });
  window.print();
}

/* 인쇄 후 원상 복귀 */
window.addEventListener('afterprint', () => {
  slides.forEach((s, i) => {
    s.style.display   = '';
    s.style.transform = '';
    if (i !== cur) s.classList.remove('active');
  });
  scaleSlides();
  show(cur);
});

/* 슬라이드 본문 클릭 → 다음 슬라이드 (버튼/링크 등은 제외) */
document.querySelectorAll('.slide .slide-body').forEach(body => {
  body.addEventListener('click', e => {
    if (e.target.closest('a, button, input, textarea, select')) return;
    show(cur + 1);
  });
});

/* 키보드 단축키 */
document.addEventListener('keydown', e => {
  if (e.key === 'ArrowRight' || e.key === 'ArrowDown' || e.key === ' ' || e.key === 'PageDown') {
    e.preventDefault(); show(cur + 1);
  }
  if (e.key === 'ArrowLeft' || e.key === 'ArrowUp' || e.key === 'PageUp') {
    e.preventDefault(); show(cur - 1);
  }
  if (e.key === 'Home') { e.preventDefault(); show(0); }
  if (e.key === 'End')  { e.preventDefault(); show(slides.length - 1); }
});

window.addEventListener('resize', scaleSlides);

scaleSlides();
show(0);
```

---

8. 생성 완료 후 사용자에게 알린다:
   - 생성된 파일 절대 경로 + `open {경로}` 명령
   - 슬라이드 수, 테마명
   - 키 안내: 화살표키/스페이스/PageUp·PageDown 이동, 슬라이드 본문 클릭 시 다음, 하단 ← 이전 / 다음 → 버튼
   - 우측 상단 다운로드 아이콘 클릭 시 PDF 저장

## Examples

```
/ppt-maker:create 인공지능의 미래
/ppt-maker:create --company "대웅제약" "2026 상반기 AI 혁신 전략"
/ppt-maker:create --theme dark-elegant --slides 10 "마이크로서비스 전환 계획"
/ppt-maker:create --company "ESSEO" --lang en "Introduction to Machine Learning"
```
