# review

현재 스테이징되거나 변경된 코드를 리뷰합니다.

## Usage

```
/dev-assist:review [--staged] [<file>]
```

## Arguments

- `--staged`: 스테이징된 변경사항만 리뷰
- `<file>`: 특정 파일 경로 지정

## Instructions

1. `--staged` 플래그가 있으면 `git diff --staged`를, 없으면 `git diff`를 사용한다.
2. `<file>`이 지정된 경우 해당 파일만 리뷰한다.
3. 다음 항목을 검토한다:
   - **버그/로직 오류**: 잘못된 조건문, 경계값 오류, null 처리 누락
   - **보안 취약점**: OWASP Top 10, SQL 인젝션, XSS, 민감 정보 노출
   - **성능**: 불필요한 루프, N+1 쿼리, 메모리 누수
   - **코드 품질**: 중복 코드, 복잡도, 네이밍
4. 발견사항을 심각도별로 정리한다: 🔴 Critical / 🟡 Warning / 🟢 Suggestion
5. 수정 제안 코드를 포함한다.

## Examples

```
/dev-assist:review
/dev-assist:review --staged
/dev-assist:review src/auth/login.ts
```
