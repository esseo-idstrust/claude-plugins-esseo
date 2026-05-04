# commit

스테이징된 변경사항을 분석하여 Conventional Commits 형식의 커밋 메시지를 생성합니다.

## Usage

```
/dev-assist:commit [--push]
```

## Arguments

- `--push`: 커밋 후 즉시 `git push`까지 실행

## Instructions

1. `git diff --staged`로 스테이징된 변경사항을 분석한다.
2. 변경 유형을 파악한다: feat / fix / refactor / docs / test / chore / style
3. 변경된 스코프(모듈, 파일명)를 식별한다.
4. 다음 형식으로 커밋 메시지를 작성한다:
   ```
   <type>(<scope>): <한국어 요약>

   <변경 이유 또는 컨텍스트 (필요시)>
   ```
5. 사용자에게 메시지를 보여주고 확인 후 커밋을 실행한다.
6. `--push` 플래그가 있으면 커밋 후 `git push`를 실행한다.

## Examples

```
/dev-assist:commit
/dev-assist:commit --push
```
