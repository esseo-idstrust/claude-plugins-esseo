# ppt-maker

텍스트 또는 주제를 입력하면 HTML 프레젠테이션을 자동으로 생성하는 Claude Code 플러그인입니다.
PDF 저장 버튼이 내장되어 있으며, 외부 의존성 없이 단일 HTML 파일로 배포됩니다.

## 설치

```bash
/plugin install ppt-maker@esseo-plugins
```

## 슬래시 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/ppt-maker:create <topic>` | 주제 또는 내용으로 HTML 슬라이드 생성 |
| `/ppt-maker:create --theme <name>` | 특정 테마 적용하여 생성 |
| `/ppt-maker:create --slides <n>` | 목표 슬라이드 수 지정 |
| `/ppt-maker:create --lang en` | 영어 발표자료 생성 |
| `/ppt-maker:theme --list` | 사용 가능한 테마 목록 조회 |
| `/ppt-maker:theme --preview <name>` | 테마 색상 미리보기 |

## 서브에이전트

- **slide-architect**: 콘텐츠 분석 및 슬라이드 구조 JSON 설계 전담

## 스킬

- **presentation-trigger**: "PPT 만들어줘", "발표자료" 등 자연어 요청 시 자동 활성화

## 훅

- **PostToolUse**: HTML 파일 생성 완료 시 사용 안내 메시지 출력

## 내장 테마

| 테마 | 설명 |
|------|------|
| `professional-light` ⭐ | 화이트 + 네이비/코럴 (기본값) |
| `dark-elegant` | 다크 + 골드 |
| `minimal-gray` | 라이트 그레이 + 블루 |
| `warm-sunrise` | 크림 + 오렌지 |
| `corporate-blue` | 딥블루 + 화이트 |

## 출력 구조

```
output/
  YYYY-MM-DD/
    {title-slug}/
      index.html
```

## 기술 사양

- 슬라이드 비율: 16:9 (1280×720px 기준)
- 폰트: Apple SD Gothic Neo / Malgun Gothic / Noto Sans KR (시스템 폰트, CDN 없음)
- PDF 출력: `window.print()` + `@media print` CSS
- 슬라이드 이동: 키보드 화살표키 (←→↑↓)
- 외부 의존성: 없음 (완전 자립형 HTML)

## 로컬 테스트

```bash
claude --plugin-dir ./plugins/ppt-maker
```
