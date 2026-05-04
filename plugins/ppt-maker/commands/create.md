# create

텍스트 또는 주제를 입력받아 HTML 프레젠테이션 파일을 생성합니다.

## Usage

```
/ppt-maker:create <topic> [--theme <theme-name>] [--slides <count>] [--lang <ko|en>]
```

## Arguments

- `<topic>`: 발표 주제 또는 내용 (필수). 짧은 키워드 또는 긴 본문 모두 가능.
- `--theme <name>`: 적용할 테마 이름 (기본값: professional-light). `/ppt-maker:theme --list`로 목록 확인.
- `--slides <count>`: 목표 슬라이드 수 (기본값: 자동, 8-15장).
- `--lang <ko|en>`: 출력 언어 (기본값: ko).

## Instructions

1. 사용자 입력에서 `<topic>`과 옵션 플래그를 파싱한다.

2. `slide-architect` 에이전트를 호출하여 슬라이드 구조 JSON을 받아온다. 에이전트에게 다음을 전달한다:
   - 원본 콘텐츠 또는 주제
   - 목표 슬라이드 수 (`--slides` 값이 있으면 포함)
   - 출력 언어 (`--lang` 값)

3. 에이전트로부터 다음 형식의 JSON을 수신한다:
   ```json
   {
     "title": "발표 제목",
     "subtitle": "부제목 (선택)",
     "theme": "professional-light",
     "slides": [
       {
         "layout": "title|section|content|two-column|quote|closing",
         "title": "슬라이드 제목",
         "subtitle": "부제목 (title/closing 레이아웃만)",
         "points": ["bullet1", "bullet2"],
         "left": "좌측 컬럼 (two-column만)",
         "right": "우측 컬럼 (two-column만)",
         "quote": "인용구 (quote 레이아웃만)",
         "attribution": "출처 (quote 레이아웃만)",
         "notes": "발표자 노트"
       }
     ]
   }
   ```

4. `--theme` 값이 지정된 경우 JSON의 theme 값을 override한다.

5. 오늘 날짜를 `date +%Y-%m-%d` 명령으로 가져온다.

6. title-slug를 계산한다:
   - 발표 제목에서 영문/숫자만 추출하여 소문자 kebab-case로 변환 (공백→하이픈)
   - 결과가 3자 미만이면 `slide-$(date +%Y%m%d)` fallback 사용

7. 출력 디렉토리를 생성한다:
   ```
   mkdir -p {plugin-dir}/output/YYYY-MM-DD/{title-slug}/
   ```

8. 다음 사양으로 `index.html`을 Write 도구로 생성한다:

   **전체 HTML 구조:**
   - `<!DOCTYPE html>`, `lang="ko"` (--lang en이면 "en")
   - `<meta charset="UTF-8">`, viewport
   - `<style>` 블록에 모든 CSS 인라인 (외부 CDN 없음)
   - `<script>` 블록에 슬라이드 네비게이션 JS 인라인

   **CSS 테마 변수 (선택된 테마에 맞게 값 설정):**
   ```css
   :root {
     --primary: #1a2e5a;    /* 주색 */
     --accent:  #e8614d;    /* 강조색 */
     --bg:      #f5f5f5;    /* 페이지 배경 */
     --text:    #1a1a1a;    /* 본문 텍스트 */
     --slide-bg: #ffffff;  /* 슬라이드 배경 */
     --font: "Apple SD Gothic Neo", "Malgun Gothic", "Noto Sans KR", sans-serif;
   }
   ```

   테마별 변수값:
   - `professional-light`: primary #1a2e5a, accent #e8614d, bg #f5f5f5, slide-bg #ffffff, text #1a1a1a
   - `dark-elegant`: primary #c9a84c, accent #ffffff, bg #1a1a2e, slide-bg #16213e, text #e8e8e8
   - `minimal-gray`: primary #2d3748, accent #4299e1, bg #f7f7f7, slide-bg #ffffff, text #2d3748
   - `warm-sunrise`: primary #d4570a, accent #8b5e3c, bg #fdf8f0, slide-bg #fffdf8, text #2c1810
   - `corporate-blue`: primary #ffffff, accent #93c5fd, bg #1e3a5f, slide-bg #1e3a5f, text #e8f4fd

   **슬라이드 컨테이너 CSS:**
   ```css
   body { margin: 0; background: var(--bg); font-family: var(--font); }
   .slideshow { width: 100vw; height: 100vh; display: flex; align-items: center; justify-content: center; }
   .slide {
     display: none;
     width: 1280px; max-width: 96vw;
     aspect-ratio: 16/9;
     background: var(--slide-bg);
     color: var(--text);
     box-sizing: border-box;
     padding: 60px 80px;
     position: relative;
     box-shadow: 0 8px 40px rgba(0,0,0,0.15);
   }
   .slide.active { display: flex; flex-direction: column; justify-content: center; }
   ```

   **레이아웃별 CSS:**
   - `.layout-title`: 중앙 정렬, h1 폰트 크기 56px, 상단 네이비 바 (4px)
   - `.layout-section`: 배경색 var(--primary), 텍스트 흰색(또는 var(--slide-bg)), 중앙 정렬, h2 48px
   - `.layout-content`: h2 36px (--primary 색), ul 스타일 (accent 색 bullet, 줄간격 1.8)
   - `.layout-two-column`: CSS Grid 2열, 좌우 동일 비율
   - `.layout-quote`: 큰 따옴표 장식 (font-size: 120px, --accent 색), 인용 텍스트 32px 중앙
   - `.layout-closing`: layout-title과 동일하되 하단 accent 바

   **PDF 저장 버튼:**
   ```css
   .btn-pdf {
     position: fixed; top: 1rem; right: 1rem; z-index: 9999;
     background: var(--primary); color: #fff;
     border: none; border-radius: 6px; padding: 10px 20px;
     font-size: 14px; cursor: pointer; font-family: var(--font);
     box-shadow: 0 2px 8px rgba(0,0,0,0.2);
   }
   .btn-pdf:hover { opacity: 0.85; }
   ```

   **슬라이드 번호 표시:**
   ```css
   .slide-counter {
     position: fixed; bottom: 1rem; right: 1.5rem;
     font-size: 13px; color: var(--text); opacity: 0.5;
   }
   ```

   **@media print:**
   ```css
   @media print {
     .btn-pdf, .slide-counter { display: none !important; }
     .slideshow { display: block; width: auto; height: auto; }
     .slide { display: block !important; box-shadow: none;
       page-break-before: always; page-break-inside: avoid;
       width: 100%; max-width: 100%; }
     .slide:first-of-type { page-break-before: auto; }
     @page { margin: 0; size: landscape; }
   }
   ```

   **슬라이드 네비게이션 JS:**
   ```javascript
   const slides = document.querySelectorAll('.slide');
   let current = 0;
   const counter = document.querySelector('.slide-counter');

   function show(n) {
     slides[current].classList.remove('active');
     current = (n + slides.length) % slides.length;
     slides[current].classList.add('active');
     counter.textContent = (current + 1) + ' / ' + slides.length;
   }

   document.addEventListener('keydown', e => {
     if (e.key === 'ArrowRight' || e.key === 'ArrowDown') show(current + 1);
     if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') show(current - 1);
   });

   slides[0].classList.add('active');
   counter.textContent = '1 / ' + slides.length;
   ```

   **슬라이드 HTML 생성 규칙:**
   - 각 슬라이드: `<div class="slide layout-{layout}">`
   - `notes` 값이 있으면 슬라이드 안에 `<!-- NOTES: {notes} -->` 주석 추가
   - `title` 레이아웃: `<h1>{title}</h1><p class="subtitle">{subtitle}</p>`
   - `section` 레이아웃: `<h2>{title}</h2>`
   - `content` 레이아웃: `<h2>{title}</h2><ul>{points를 <li>로 변환}</ul>`
   - `two-column` 레이아웃: `<h2>{title}</h2><div class="columns"><div class="col">{left}</div><div class="col">{right}</div></div>`
   - `quote` 레이아웃: `<div class="quote-mark">"</div><blockquote>{quote}</blockquote><cite>{attribution}</cite>`
   - `closing` 레이아웃: `<h1>{title}</h1><p class="subtitle">{subtitle}</p>`

9. 생성 완료 후 사용자에게 다음을 알린다:
   - 생성된 파일 절대 경로
   - 슬라이드 수 및 사용된 테마
   - `open {경로}` 명령으로 브라우저에서 열기 안내
   - 화살표키로 슬라이드 이동, "PDF로 저장" 버튼으로 PDF 내보내기 안내

## Examples

```
/ppt-maker:create 인공지능의 미래
/ppt-maker:create "Q1 성과 보고: 매출 120% 달성, 신규 고객 확보 전략"
/ppt-maker:create --theme dark-elegant --slides 10 "마이크로서비스 아키텍처 전환 계획"
/ppt-maker:create --lang en "Introduction to Machine Learning"
```
