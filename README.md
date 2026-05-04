# claude-plugins-esseo

esseo-idstrust의 개인 Claude Code 플러그인 마켓플레이스입니다.

## 마켓플레이스 등록

```bash
/plugin marketplace add esseo-idstrust/claude-plugins-esseo
```

## 플러그인 설치

```bash
/plugin install {plugin-name}@esseo-plugins
```

## 플러그인 목록

| 플러그인 | 설명 | 버전 |
|---------|------|------|
| [dev-assist](./plugins/dev-assist) | 개발 워크플로우 보조 - 코드리뷰, 커밋, PR 작성 | 1.0.0 |

## 로컬 개발

```bash
# 특정 플러그인 로컬 테스트
claude --plugin-dir ./plugins/{plugin-name}

# 변경사항 반영
/reload-plugins
```

## 구조

```
claude-plugins-esseo/
├── .claude-plugin/
│   └── marketplace.json       # 마켓플레이스 카탈로그
├── plugins/
│   └── {plugin-name}/
│       ├── .claude-plugin/plugin.json
│       ├── commands/          # 슬래시 커맨드 (.md)
│       ├── agents/            # 서브에이전트 정의 (.md)
│       ├── skills/            # 자동 활성화 스킬
│       ├── hooks/             # 이벤트 핸들러
│       └── README.md
└── README.md
```
