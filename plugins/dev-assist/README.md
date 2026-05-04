# dev-assist

개발 워크플로우를 보조하는 Claude Code 플러그인입니다.

## 설치

```bash
/plugin install dev-assist@esseo-plugins
```

## 슬래시 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/dev-assist:commit` | Conventional Commits 형식의 커밋 메시지 생성 |
| `/dev-assist:commit --push` | 커밋 후 push까지 자동 실행 |
| `/dev-assist:pr` | GitHub PR 자동 생성 |
| `/dev-assist:pr --draft` | 드래프트 PR 생성 |
| `/dev-assist:review` | 변경사항 코드 리뷰 |
| `/dev-assist:review --staged` | 스테이징된 변경사항만 리뷰 |

## 서브에이전트

- **code-reviewer**: 심층 코드 리뷰 및 보안 감사 전용 에이전트

## 스킬

- **context-aware**: 커밋/PR/리뷰 요청 시 Git 컨텍스트 자동 수집

## 훅

- **SessionStart**: 세션 시작 시 현재 Git 상태 요약 표시
- **PreToolUse**: main/master 브랜치 force push 자동 차단

## 로컬 테스트

```bash
claude --plugin-dir ./plugins/dev-assist
```
