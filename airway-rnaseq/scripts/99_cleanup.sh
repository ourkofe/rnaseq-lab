#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

echo "다음 항목들을 삭제합니다 (git에는 안 올라가 있던 무거운 데이터):"
du -sh "$REPO_ROOT"/{data,ref,index,align} 2>/dev/null || true

read -p "정말 삭제할까요? results/와 logs/는 남습니다. (yes 입력): " confirm
if [ "$confirm" != "yes" ]; then
  echo "취소됨."
  exit 0
fi

CHECKSUM_FILE="$REPO_ROOT/logs/checksums_$(date +%Y%m%d_%H%M%S).txt"
echo "삭제 전 체크섬 기록 -> $CHECKSUM_FILE"
find "$REPO_ROOT"/{data,ref,index,align} -type f -exec sha256sum {} \; > "$CHECKSUM_FILE" 2>/dev/null || true

log_run "cleanup" "rm -rf '$REPO_ROOT/data' '$REPO_ROOT/ref' '$REPO_ROOT/index' '$REPO_ROOT/align'"

echo "정리 완료. 남은 것: results/, logs/, scripts/, docs/, ANALYSIS_LOG.md"
du -sh "$REPO_ROOT"
