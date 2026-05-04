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
- `--company <name>`: 슬라이드 우측 상단에 표시할 회사/로고 텍스트.

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
<button class="btn-pdf" onclick="printSlides()" aria-label="PDF로 저장">PDF로 저장</button>
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
  --bg: #E8E8E8;
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
  --bg: #f5f5f5; --slide-bg: #fff; --text: #1a1a1a;
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

/* 슬라이드쇼 */
.slideshow {
  width: 100vw;
  height: calc(100vh - 48px); /* 하단 네비 공간 */
  display: flex; align-items: center; justify-content: center;
}

/* 슬라이드 ─ 1280×720 고정 캔버스 (JS 가 scale 로 뷰포트에 맞춤) */
.slide {
  display: none;
  position: relative;
  width: 1280px; height: 720px;
  flex-shrink: 0;
  background: var(--slide-bg);
  box-shadow: 0 8px 40px rgba(0,0,0,0.22);
  overflow: hidden;
  flex-direction: column;
  transform-origin: center center;
  outline: none;
}
.slide.active { display: flex; }
.slide:focus-visible { box-shadow: 0 8px 40px rgba(0,0,0,0.22), 0 0 0 4px rgba(240,152,32,0.55); }

/* 슬라이드 헤더 (title 레이아웃 제외) */
.slide-header {
  display: flex; justify-content: space-between; align-items: center;
  padding: 16px 60px 15px;
  border-top: 3px solid var(--primary);
  flex-shrink: 0;
}
.chapter-label { color: var(--primary); font-size: 14px; font-weight: 800; letter-spacing: 0.05em; }
.chapter-label .crumb-sep { color: var(--text-light); margin: 0 8px; font-weight: 600; }
.chapter-label .crumb-current { color: var(--text); }
.logo-text { color: var(--text); font-size: 13px; font-weight: 800; letter-spacing: 0.12em; }

/* 슬라이드 바디 (클릭 시 다음 슬라이드로) */
.slide-body {
  flex: 1; overflow: hidden;
  display: flex; flex-direction: column; justify-content: center;
  padding: 24px 72px 20px;
  cursor: pointer;
}

/* 슬라이드 푸터 라인 — 모든 레이아웃에서 일관된 하단 보더 */
.slide-footer { border-top: 3px solid var(--primary); flex-shrink: 0; height: 0; }
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

> 텍스트가 2줄로 줄바꿈되어도 아이콘이 첫 줄 상단에 정렬되어 정렬이 깨지지 않는다.

---

### CSS — 타이틀 슬라이드 (footer 보더 일관 적용)

```css
.deco-wrap {
  position: absolute; top: 0; right: 0;
  width: 38%; height: 100%;
  pointer-events: none; overflow: hidden;
}
.deco-a {
  position: absolute; top: -28%; right: -20%; width: 108%; height: 92%;
  background: var(--primary-pale); transform: rotate(20deg); border-radius: 10px;
}
.deco-b {
  position: absolute; top: -32%; right: -8%; width: 76%; height: 78%;
  background: var(--primary-light); transform: rotate(20deg); border-radius: 10px;
}
.deco-c {
  position: absolute; top: -22%; right: 10%; width: 46%; height: 60%;
  background: var(--primary); transform: rotate(20deg); border-radius: 10px;
}
.title-logo {
  position: absolute; top: 20px; right: 36px;
  font-size: 13px; font-weight: 800; color: var(--text);
  letter-spacing: 0.12em; z-index: 10;
}

/* title 도 다른 슬라이드와 마찬가지로 상/하단 보더를 갖는다 */
.layout-title { border-top: 3px solid var(--primary); }
.layout-title .slide-body {
  padding: 0 88px; justify-content: center; align-items: flex-start; z-index: 1;
}
.slide-category {
  font-size: 16px; color: var(--text-light);
  font-weight: 500; letter-spacing: 0.12em; text-transform: uppercase;
  margin-bottom: 22px;
}
.layout-title h1 {
  font-size: 60px; font-weight: 900; color: var(--text);
  line-height: 1.18; margin-bottom: 26px; word-break: keep-all;
}
.layout-title h1 em { font-style: normal; color: var(--primary); }
.title-bullets { list-style: none; display: flex; flex-direction: column; gap: 10px; }
.title-bullets li {
  font-size: 19px; color: var(--text-body); font-weight: 500;
  display: flex; align-items: center; gap: 12px;
}
.title-bullets li::before {
  content: ''; width: 7px; height: 7px;
  background: var(--primary); border-radius: 50%; flex-shrink: 0;
}
.layout-title .slide-subtitle { font-size: 18px; color: var(--text-body); line-height: 1.6; }
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

/* 레이블:값 행 테이블 (zebra-stripe 로 가독성 향상) */
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

### CSS — cards 슬라이드 (2~4장 카드, 견고한 flex 분배)

```css
.layout-cards .slide-body { justify-content: flex-start; padding-top: 22px; }
.layout-cards h2 {
  font-size: 34px; font-weight: 800; color: var(--text);
  margin-bottom: 18px; flex-shrink: 0; line-height: 1.25;
}
.cards-row {
  display: flex; align-items: stretch; gap: 14px;
  flex: 1; min-height: 0;
}
.card-item {
  flex: 1 1 0;          /* 카드 수가 2개여도 균등 분배 */
  min-width: 0;          /* flex 아이템 overflow 방지 */
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
.card-label {
  font-size: 12px; font-weight: 800; letter-spacing: 0.1em;
  color: var(--text-light); text-transform: uppercase; margin-bottom: 6px;
}
.card-title {
  font-size: 22px; font-weight: 900; color: var(--primary);
  margin-bottom: 16px;
  display: flex; align-items: center; gap: 8px;
  padding-bottom: 12px;
  border-bottom: 1.5px solid rgba(240,152,32,0.2);
}
/* card_list (개조식 불릿) — body 보다 우선 사용 */
.card-list { list-style: none; display: flex; flex-direction: column; gap: 9px; flex: 1; }
.card-list li {
  font-size: 17px; color: var(--text-body); font-weight: 600;
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
  font-size: 17px; color: var(--text-body); line-height: 1.65;
  flex-shrink: 0; word-break: keep-all;
}
/* 대비 강화: --primary-strong (어두운 변형) 사용 */
.summary-bar strong { color: var(--primary-strong); font-weight: 900; }
```

---

### CSS — PDF 버튼, 네비게이션, 인쇄

```css
/* PDF 버튼 */
.btn-pdf {
  position: fixed; top: 14px; right: 20px; z-index: 9999;
  background: var(--primary); color: #fff; border: none;
  border-radius: 7px; padding: 10px 22px;
  font-size: 14px; font-weight: 800; cursor: pointer;
  font-family: var(--font); box-shadow: 0 3px 12px rgba(240,152,32,0.35);
  transition: opacity 0.15s, transform 0.1s;
  letter-spacing: 0.02em;
}
.btn-pdf:hover { opacity: 0.85; transform: translateY(-1px); }
.btn-pdf:active { transform: translateY(0); }
.btn-pdf:focus-visible { outline: 3px solid #fff; outline-offset: 2px; }

/* 하단 네비게이션 바 */
.nav-bar {
  position: fixed; bottom: 0; left: 0; right: 0; height: 48px;
  display: flex; align-items: center; justify-content: space-between;
  padding: 0 56px; background: var(--bg);
}
.nav-btn {
  background: none; border: none; cursor: pointer;
  color: var(--text-light); font-size: 14px; font-weight: 700;
  font-family: var(--font); padding: 8px 16px; border-radius: 5px;
  transition: color 0.15s, background 0.15s; letter-spacing: 0.02em;
}
.nav-btn:hover { color: var(--primary); background: rgba(240,152,32,0.1); }
.nav-btn:focus-visible { outline: 2px solid var(--primary); outline-offset: 2px; }

/* 페이지 카운터: zero-padded 01 / 02 */
.nav-counter {
  font-size: 14px; color: var(--text-light);
  font-weight: 700; font-family: var(--font);
  letter-spacing: 0.08em; font-variant-numeric: tabular-nums;
}
.nav-counter .nav-current { color: var(--primary); }

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
    transform: none !important;        /* ★ JS 인라인 transform 덮어쓰기 */
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
  <span class="alert-text">{alert_bar 텍스트. **굵게** 표시할 부분은 <strong>으로 감쌈}</span>
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
구분자가 없으면 단순 텍스트로 렌더한다.

**example 박스 렌더링**:
```html
<div class="example-box">{example 텍스트}</div>
```

---

**title 슬라이드** (footer 도 다른 슬라이드와 동일한 보더 유지):
```html
<div class="slide layout-title" tabindex="0" role="group" aria-label="슬라이드 1">
  <div class="deco-wrap"><div class="deco-a"></div><div class="deco-b"></div><div class="deco-c"></div></div>
  <div class="title-logo">{company 또는 빈문자열}</div>
  <div class="slide-body">
    <p class="slide-category">{subtitle}</p>
    <h1>{title}</h1>
    {points 있으면: <ul class="title-bullets"><li>...</li></ul>}
  </div>
  <div class="slide-footer"></div>
</div>
```

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

**cards 슬라이드** (2-4개 카드, 화살표 연결 — `card_list` 우선, 없으면 `body`):
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
        <div class="card-title">{icon} {card.title}</div>
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

> **`card_list` vs `body` 가이드**:
> - **`card_list` (배열) — 권장 기본**: 카드가 2~4개의 짧은 개념(특징, 단계, 행동)을 담을 때. 시각적으로 스캔이 빠르고 슬라이드 일관성이 높다.
> - **`body` (문자열) — 예외**: 카드 내용이 한두 문장의 서술형 정의이거나, 자연어 설명이 더 적합한 경우. 한 슬라이드 내 모든 카드가 같은 형식(전부 `card_list` 또는 전부 `body`)이어야 한다.

**two-column 슬라이드** (rows + example 지원, rows 는 zebra-stripe 적용됨):
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
  <div class="deco-wrap"><div class="deco-a"></div><div class="deco-b"></div><div class="deco-c"></div></div>
  <div class="slide-header" style="border-top-color:transparent;">
    <span></span><span class="logo-text">{company}</span>
  </div>
  <div class="slide-body">
    <div class="closing-bar"></div>
    <h1>{title}</h1>
    <p class="slide-subtitle">{subtitle}</p>
  </div>
  <div class="slide-footer" style="border-top-color:transparent;"></div>
</div>
```

---

### JavaScript — 네비게이션 / 인쇄 / 클릭 진행 / 접근성

> **반드시 `printSlides()` 패턴을 사용한다** — `window.print()` 직접 호출 시 인쇄에 활성 슬라이드 1장만 포함된다.
> `afterprint` 핸들러는 모든 인라인 `transform` 과 `display` 를 비우고 `scaleSlides()` → `show(cur)` 로 정확히 원상 복귀시킨다.

```javascript
const slides   = document.querySelectorAll('.slide');
const counter  = document.getElementById('nav-counter');
const totalStr = String(slides.length).padStart(2, '0');
let cur = 0;

/* 뷰포트에 맞게 1280×720 캔버스를 scale */
function scaleSlides() {
  const vw = window.innerWidth;
  const vh = window.innerHeight - 48;
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
   - PDF 버튼 안내 (`printSlides()` 가 모든 슬라이드를 인쇄에 포함시킴)

## Examples

```
/ppt-maker:create 인공지능의 미래
/ppt-maker:create --company "Daewoong" "Q1 성과 보고"
/ppt-maker:create --theme dark-elegant --slides 10 "마이크로서비스 전환 계획"
/ppt-maker:create --company "ESSEO" --lang en "Introduction to Machine Learning"
```
