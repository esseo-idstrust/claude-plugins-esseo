# theme

사용 가능한 테마 목록을 조회하거나 색상 팔레트를 미리봅니다.

## Usage

```
/ppt-maker:theme [--list] [--preview <theme-name>]
```

## Arguments

- `--list`: 사용 가능한 모든 테마 목록과 색상 값 출력
- `--preview <name>`: 지정한 테마의 색상 팔레트를 터미널에서 미리보기

## Instructions

1. `--list` 플래그가 있으면 다음 내장 테마 정보를 표로 출력한다:

   | 테마 이름 | 설명 | 배경 | 주색 | 강조 |
   |-----------|------|------|------|------|
   | daewoong ⭐ | 화이트 + 앰버/오렌지. 상단/하단 오렌지 라인, 기하학 장식 | #FFFFFF | #F09820 | #F5C860 |
   | professional-light | 화이트 + 네이비/코럴. 깔끔한 기업 발표 | #ffffff | #1a2e5a | #4a6fa5 |
   | dark-elegant | 다크 + 골드. 임팩트 있는 발표, 제품 소개 | #1a1a2e | #c9a84c | #e8cc80 |
   | minimal-gray | 라이트 그레이 + 블루. 심플하고 모던한 발표 | #ffffff | #2d3748 | #4a6080 |
   | corporate-blue | 딥블루 + 라이트블루. 격식 있는 기업 발표 | #1e3a5f | #93c5fd | #bfdbfe |

   ⭐ = 기본값

2. `--preview <name>`이 있으면 해당 테마의 색상을 Unicode 블록 문자(█)로 시각화한다:
   ```
   [테마명] 미리보기
   ████████████████████  슬라이드 배경: #XXXXXX
   ████████████          주색 (라인/강조): #XXXXXX
   ██████                보조 강조: #XXXXXX
   ████████████████████  텍스트: #XXXXXX

   적용법: /ppt-maker:create --theme <테마명> <주제>
   ```

3. 인수가 없으면 `--list` 사용을 안내한다.

4. 이 커맨드는 설정을 영구 저장하지 않는다. 테마 적용은 `/ppt-maker:create --theme <name>` 으로 한다.

## Examples

```
/ppt-maker:theme --list
/ppt-maker:theme --preview daewoong
/ppt-maker:theme --preview dark-elegant
```
