# pr

현재 브랜치의 변경사항을 분석하여 GitHub Pull Request를 생성합니다.

## Usage

```
/dev-assist:pr [--draft] [--base <branch>]
```

## Arguments

- `--draft`: 드래프트 PR로 생성
- `--base <branch>`: 베이스 브랜치 지정 (기본값: main)

## Instructions

1. `git log --oneline <base>...HEAD`로 커밋 히스토리를 파악한다.
2. `git diff <base>...HEAD`로 전체 변경사항을 분석한다.
3. 다음 구조로 PR 본문을 작성한다:
   ```markdown
   ## Summary
   - 변경 목적 및 배경
   - 주요 변경사항 (bullet)

   ## Changes
   - 구체적인 변경 내역

   ## Test Plan
   - [ ] 테스트 항목 1
   - [ ] 테스트 항목 2

   ## Notes
   리뷰어를 위한 특이사항 (있을 경우)
   ```
4. `gh pr create` 명령으로 PR을 생성한다.
5. 생성된 PR URL을 반환한다.

## Examples

```
/dev-assist:pr
/dev-assist:pr --draft
/dev-assist:pr --base develop
```
