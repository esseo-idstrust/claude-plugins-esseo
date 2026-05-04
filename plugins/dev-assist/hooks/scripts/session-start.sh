#!/bin/bash
# Git 레포지토리인 경우 현재 상태를 요약하여 세션 시작 시 컨텍스트 제공

if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  branch=$(git branch --show-current 2>/dev/null)
  staged=$(git diff --staged --name-only 2>/dev/null | wc -l | tr -d ' ')
  modified=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')

  if [ "$staged" -gt 0 ] || [ "$modified" -gt 0 ]; then
    echo "[dev-assist] 브랜치: $branch | 스테이징: ${staged}개 | 변경: ${modified}개 파일"
  fi
fi
