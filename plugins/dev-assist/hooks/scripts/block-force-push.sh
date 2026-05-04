#!/bin/bash
# main/master 브랜치로의 force push를 차단

branch=$(git branch --show-current 2>/dev/null)

if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  echo "[dev-assist] 경고: main/master 브랜치에 force push는 허용되지 않습니다." >&2
  exit 1
fi
