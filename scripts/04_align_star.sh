#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

STAR_IMAGE="quay.io/biocontainers/star:2.7.11a--h0033a41_0"
THREADS=16

mkdir -p "$REPO_ROOT/align"
log_docker_digest "$STAR_IMAGE"

while IFS=$'\t' read -r run cell condition; do
  [ "$run" = "run" ] && continue   # 헤더 skip
  log_run "star_align_${run}" "docker run --rm --cpus=${THREADS} --memory=32g \
    -v '$REPO_ROOT/index':/index -v '$REPO_ROOT/data':/data -v '$REPO_ROOT/align':/align \
    $STAR_IMAGE \
    STAR --genomeDir /index \
         --readFilesIn /data/${run}_1.fastq.gz /data/${run}_2.fastq.gz \
         --readFilesCommand zcat \
         --outSAMtype BAM SortedByCoordinate \
         --outFileNamePrefix /align/${run}_ \
         --runThreadN ${THREADS}"

  # 정렬률 등 핵심 통계를 로그에 남김 (Log.final.out은 텍스트라 가벼움 -> results에 복사)
  cp "$REPO_ROOT/align/${run}_Log.final.out" "$REPO_ROOT/results/qc/${run}_Log.final.out"
done < "$REPO_ROOT/config/samples.tsv"

du -sh "$REPO_ROOT/align"
