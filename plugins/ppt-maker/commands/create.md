# create

텍스트 또는 주제를 입력받아 HTML 프레젠테이션 파일을 생성합니다.

## Usage

```
/ppt-maker:create <topic> [--theme <theme-name>] [--slides <count>] [--lang <ko|en>] [--company <name>]
```

## Arguments

- `<topic>`: 발표 주제 또는 내용 (필수). 짧은 키워드 또는 긴 본문 모두 가능.
- `--theme <name>`: 적용할 테마 이름 (기본값: daewoong). `/ppt-maker:theme --list`로 목록 확인.
- `--slides <count>`: 목표 슬라이드 수 (기본값: 자동, 8-15장).
- `--lang <ko|en>`: 출력 언어 (기본값: ko).
- `--company <name>`: 슬라이드 우측 상단에 표시할 회사/로고 텍스트 (기본값: 없음).

## Instructions

1. 사용자 입력에서 `<topic>`과 옵션 플래그를 파싱한다.

2. `slide-architect` 에이전트를 호출하여 슬라이드 구조 JSON을 받아온다:
   - 원본 콘텐츠 또는 주제
   - 목표 슬라이드 수 (`--slides` 값이 있으면 포함)
   - 출력 언어

3. 에이전트로부터 다음 JSON 형식을 수신한다:
   ```json
   {
     "title": "발표 제목",
     "subtitle": "부제목 또는 날짜/발표자",
     "theme": "daewoong",
     "slides": [
       {
         "layout": "title|section|content|two-column|quote|closing",
         "chapter": "챕터 레이블 (헤더 좌측에 표시, section/closing 제외)",
         "title": "슬라이드 제목",
         "subtitle": "부제목 (title/closing만)",
         "points": ["bullet1", "bullet2"],
         "left_title": "좌측 컬럼 소제목 (two-column만)",
         "left": "좌측 컬럼 본문",
         "right_title": "우측 컬럼 소제목 (two-column만)",
         "right": "우측 컬럼 본문",
         "quote": "인용구 (quote만)",
         "attribution": "출처 (quote만)",
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

7. Write 도구로 `index.html` 생성. 아래 HTML/CSS 사양을 정확히 따른다:

---

### HTML/CSS 생성 사양

**전체 골격:**
```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{발표 제목}</title>
<style>
  /* === 전체 CSS 인라인 (CDN 없음) === */
</style>
</head>
<body>
<button class="btn-pdf" onclick="window.print()">PDF로 저장</button>
<div class="slideshow">
  <!-- 슬라이드들 -->
</div>
<div class="slide-counter"></div>
<script>
  /* === 네비게이션 JS 인라인 === */
</script>
</body>
</html>
```

---

**CSS 변수 — 테마별:**

`daewoong` (기본값):
```css
:root {
  --primary: #F09820;
  --primary-light: #F5C860;
  --primary-pale: #FDE9C0;
  --bg: #EFEFEF;
  --slide-bg: #FFFFFF;
  --text: #3D3D3D;
  --text-body: #595959;
  --text-light: #AAAAAA;
  --font: "Apple SD Gothic Neo", "Malgun Gothic", "Noto Sans KR", sans-serif;
}
```

`professional-light`:
```css
:root {
  --primary: #1a2e5a; --primary-light: #4a6fa5; --primary-pale: #dce8f5;
  --bg: #f5f5f5; --slide-bg: #ffffff; --text: #1a1a1a;
  --text-body: #444444; --text-light: #999999;
  --font: "Apple SD Gothic Neo", "Malgun Gothic", "Noto Sans KR", sans-serif;
}
```

`dark-elegant`:
```css
:root {
  --primary: #c9a84c; --primary-light: #e8cc80; --primary-pale: #3a3018;
  --bg: #111118; --slide-bg: #1a1a2e; --text: #f0f0f0;
  --text-body: #cccccc; --text-light: #888888;
  --font: "Apple SD Gothic Neo", "Malgun Gothic", "Noto Sans KR", sans-serif;
}
```

`minimal-gray`:
```css
:root {
  --primary: #2d3748; --primary-light: #4a6080; --primary-pale: #e8edf5;
  --bg: #f7f7f7; --slide-bg: #ffffff; --text: #2d3748;
  --text-body: #4a5568; --text-light: #a0aec0;
  --font: "Apple SD Gothic Neo", "Malgun Gothic", "Noto Sans KR", sans-serif;
}
```

`corporate-blue`:
```css
:root {
  --primary: #93c5fd; --primary-light: #bfdbfe; --primary-pale: #1e3a5f;
  --bg: #162a45; --slide-bg: #1e3a5f; --text: #f0f8ff;
  --text-body: #c8dff5; --text-light: #7ba8d0;
  --font: "Apple SD Gothic Neo", "Malgun Gothic", "Noto Sans KR", sans-serif;
}
```

---

**기본 레이아웃 CSS:**
```css
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body { background: var(--bg); font-family: var(--font); overflow: hidden; }

.slideshow {
  width: 100vw; height: 100vh;
  display: flex; align-items: center; justify-content: center;
}

.slide {
  display: none;
  position: relative;
  width: 1280px; max-width: 96vw;
  aspect-ratio: 16/9;
  background: var(--slide-bg);
  box-shadow: 0 6px 32px rgba(0,0,0,0.18);
  overflow: hidden;
  flex-direction: column;
}
.slide.active { display: flex; }

/* 헤더 (title 레이아웃 제외 모든 슬라이드) */
.slide-header {
  display: flex; justify-content: space-between; align-items: center;
  padding: 14px 52px 13px;
  border-top: 2.5px solid var(--primary);
  flex-shrink: 0;
}
.chapter-label { color: var(--primary); font-size: 13px; font-weight: 700; }
.logo-text { color: var(--text); font-size: 13px; font-weight: 800; letter-spacing: 0.12em; }

/* 바디 */
.slide-body {
  flex: 1; overflow: hidden;
  display: flex; flex-direction: column; justify-content: center;
  padding: 28px 80px 24px;
}

/* 푸터 라인 */
.slide-footer { border-top: 2.5px solid var(--primary); flex-shrink: 0; }
```

---

**타이틀 슬라이드 CSS 및 HTML:**

CSS:
```css
/* 우상단 기하학 장식 */
.deco-wrap {
  position: absolute; top: 0; right: 0;
  width: 38%; height: 100%;
  pointer-events: none; overflow: hidden;
}
.deco-a {
  position: absolute; top: -30%; right: -18%;
  width: 110%; height: 90%;
  background: var(--primary-pale);
  transform: rotate(20deg); border-radius: 6px;
}
.deco-b {
  position: absolute; top: -35%; right: -10%;
  width: 78%; height: 80%;
  background: var(--primary-light);
  transform: rotate(20deg); border-radius: 6px;
}
.deco-c {
  position: absolute; top: -28%; right: 8%;
  width: 50%; height: 65%;
  background: var(--primary);
  transform: rotate(20deg); border-radius: 6px;
}
/* 타이틀 로고 (우상단 고정) */
.title-logo {
  position: absolute; top: 22px; right: 36px;
  font-size: 13px; font-weight: 800;
  color: var(--text); letter-spacing: 0.12em; z-index: 10;
}
.layout-title .slide-body {
  padding: 0 80px; justify-content: center; align-items: flex-start; z-index: 1;
}
.layout-title .slide-category {
  font-size: 14px; color: var(--text-light);
  margin-bottom: 20px; font-weight: 400;
}
.layout-title h1 {
  font-size: 54px; font-weight: 800;
  color: var(--text); line-height: 1.25; margin-bottom: 16px;
}
.layout-title .slide-subtitle {
  font-size: 17px; color: var(--text-body);
}
```

HTML:
```html
<div class="slide layout-title active">
  <div class="deco-wrap">
    <div class="deco-a"></div>
    <div class="deco-b"></div>
    <div class="deco-c"></div>
  </div>
  <div class="title-logo">{--company 값 또는 빈 문자열}</div>
  <div class="slide-body">
    <p class="slide-category">{subtitle (날짜/발표자 등)}</p>
    <h1>{title}</h1>
  </div>
  <!-- NOTES: {notes} -->
</div>
```

---

**섹션 슬라이드 CSS 및 HTML:**

CSS:
```css
.layout-section .slide-body { justify-content: center; align-items: flex-start; }
.layout-section h2 {
  font-size: 48px; font-weight: 800; color: var(--text);
  line-height: 1.3;
  border-left: 7px solid var(--primary);
  padding-left: 28px;
}
```

HTML:
```html
<div class="slide layout-section">
  <div class="slide-header">
    <span class="chapter-label">{chapter}</span>
    <span class="logo-text">{company}</span>
  </div>
  <div class="slide-body">
    <h2>{title}</h2>
  </div>
  <div class="slide-footer"></div>
  <!-- NOTES: {notes} -->
</div>
```

---

**콘텐츠 슬라이드 CSS 및 HTML:**

CSS:
```css
.layout-content .slide-body { justify-content: flex-start; padding-top: 24px; }
.layout-content h2 {
  font-size: 34px; font-weight: 800; color: var(--text);
  margin-bottom: 18px; line-height: 1.3;
}
.layout-content .sub-label {
  font-size: 16px; font-weight: 700; color: var(--primary);
  margin: 16px 0 8px;
}
.layout-content ul { list-style: none; }
.layout-content ul li {
  position: relative; padding-left: 22px;
  font-size: 18px; color: var(--text-body); line-height: 1.9;
}
.layout-content ul li::before {
  content: '▶'; position: absolute; left: 0;
  color: var(--primary); font-size: 10px; top: 7px;
}
.layout-content p.body-text {
  font-size: 18px; color: var(--text-body); line-height: 1.9; margin-bottom: 12px;
}
```

HTML:
```html
<div class="slide layout-content">
  <div class="slide-header">
    <span class="chapter-label">{chapter}</span>
    <span class="logo-text">{company}</span>
  </div>
  <div class="slide-body">
    <h2>{title}</h2>
    <ul>
      <li>{point1}</li>
      <li>{point2}</li>
      <!-- ... -->
    </ul>
  </div>
  <div class="slide-footer"></div>
  <!-- NOTES: {notes} -->
</div>
```

points 배열 대신 단락 본문이 적절한 경우 `<p class="body-text">`를 사용할 수 있다.

---

**2단 슬라이드 CSS 및 HTML:**

CSS:
```css
.layout-two-column .slide-body { justify-content: flex-start; padding-top: 20px; }
.layout-two-column h2 {
  font-size: 30px; font-weight: 800; color: var(--text); margin-bottom: 16px;
}
.columns { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; }
.col-title {
  font-size: 15px; font-weight: 700; color: var(--primary);
  padding-bottom: 8px; margin-bottom: 10px;
  border-bottom: 2px solid var(--primary-light);
}
.col { font-size: 16px; color: var(--text-body); line-height: 1.85; }
```

HTML:
```html
<div class="slide layout-two-column">
  <div class="slide-header">
    <span class="chapter-label">{chapter}</span>
    <span class="logo-text">{company}</span>
  </div>
  <div class="slide-body">
    <h2>{title}</h2>
    <div class="columns">
      <div class="col">
        <div class="col-title">{left_title}</div>
        {left}
      </div>
      <div class="col">
        <div class="col-title">{right_title}</div>
        {right}
      </div>
    </div>
  </div>
  <div class="slide-footer"></div>
  <!-- NOTES: {notes} -->
</div>
```

---

**인용/강조 슬라이드 CSS 및 HTML:**

CSS:
```css
.layout-quote .slide-body { align-items: center; justify-content: center; text-align: center; }
.layout-quote .quote-mark {
  font-size: 100px; color: var(--primary);
  line-height: 0.7; font-family: Georgia, serif; margin-bottom: 16px;
}
.layout-quote blockquote {
  font-size: 28px; font-weight: 700; color: var(--text);
  line-height: 1.65; max-width: 78%; margin-bottom: 20px;
}
.layout-quote cite {
  font-size: 16px; color: var(--primary); font-weight: 600; font-style: normal;
}
```

HTML:
```html
<div class="slide layout-quote">
  <div class="slide-header">
    <span class="chapter-label">{chapter}</span>
    <span class="logo-text">{company}</span>
  </div>
  <div class="slide-body">
    <div class="quote-mark">"</div>
    <blockquote>{quote}</blockquote>
    <cite>— {attribution}</cite>
  </div>
  <div class="slide-footer"></div>
  <!-- NOTES: {notes} -->
</div>
```

attribution이 없으면 `<cite>` 생략.

---

**클로징 슬라이드 CSS 및 HTML:**

CSS:
```css
.layout-closing .slide-body { align-items: center; justify-content: center; text-align: center; z-index: 1; }
.layout-closing h1 { font-size: 48px; font-weight: 800; color: var(--text); margin-bottom: 16px; }
.layout-closing .closing-bar {
  width: 72px; height: 4px; background: var(--primary); margin: 0 auto 20px;
}
.layout-closing .slide-subtitle { font-size: 18px; color: var(--primary); font-weight: 600; }
```

HTML:
```html
<div class="slide layout-closing">
  <div class="deco-wrap">
    <div class="deco-a"></div>
    <div class="deco-b"></div>
    <div class="deco-c"></div>
  </div>
  <div class="slide-header" style="border-top-color: transparent;">
    <span class="chapter-label"></span>
    <span class="logo-text">{company}</span>
  </div>
  <div class="slide-body">
    <div class="closing-bar"></div>
    <h1>{title}</h1>
    <p class="slide-subtitle">{subtitle}</p>
  </div>
  <div class="slide-footer" style="border-top-color: transparent;"></div>
  <!-- NOTES: {notes} -->
</div>
```

---

**PDF 저장 버튼 및 슬라이드 카운터 CSS:**
```css
.btn-pdf {
  position: fixed; top: 1rem; right: 1rem; z-index: 9999;
  background: var(--primary); color: #fff;
  border: none; border-radius: 6px; padding: 10px 20px;
  font-size: 14px; font-weight: 700; cursor: pointer;
  font-family: var(--font); box-shadow: 0 2px 10px rgba(0,0,0,0.2);
  transition: opacity 0.15s;
}
.btn-pdf:hover { opacity: 0.85; }
.slide-counter {
  position: fixed; bottom: 1rem; right: 1.5rem;
  font-size: 13px; color: #888; font-family: var(--font);
}
```

**@media print:**
```css
@media print {
  body { overflow: visible; background: white; }
  .btn-pdf, .slide-counter { display: none !important; }
  .slideshow { display: block; width: 100%; height: auto; }
  .slide {
    display: flex !important;
    box-shadow: none; max-width: 100%; width: 100%;
    page-break-before: always; page-break-inside: avoid;
    aspect-ratio: 16/9;
  }
  .slide:first-child { page-break-before: auto; }
  @page { margin: 0; size: landscape; }
}
```

**네비게이션 JS:**
```javascript
const slides = document.querySelectorAll('.slide');
const counter = document.querySelector('.slide-counter');
let cur = 0;

function show(n) {
  slides[cur].classList.remove('active');
  cur = (n + slides.length) % slides.length;
  slides[cur].classList.add('active');
  counter.textContent = (cur + 1) + ' / ' + slides.length;
}

document.addEventListener('keydown', e => {
  if (e.key === 'ArrowRight' || e.key === 'ArrowDown' || e.key === ' ') show(cur + 1);
  if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') show(cur - 1);
  if (e.key === 'Home') show(0);
  if (e.key === 'End') show(slides.length - 1);
});

slides[cur].classList.add('active');
counter.textContent = '1 / ' + slides.length;
```

---

8. 생성 완료 후 사용자에게 알린다:
   - 생성된 파일 절대 경로
   - 슬라이드 수, 테마명
   - `open {경로}` 로 브라우저에서 열기 안내
   - 화살표키/스페이스바로 이동, "PDF로 저장" 버튼으로 PDF 내보내기 안내

## Examples

```
/ppt-maker:create 인공지능의 미래
/ppt-maker:create --company "Daewoong" "Q1 성과 보고"
/ppt-maker:create --theme dark-elegant --slides 10 "마이크로서비스 전환 계획"
/ppt-maker:create --company "ESSEO" --lang en "Introduction to Machine Learning"
```
