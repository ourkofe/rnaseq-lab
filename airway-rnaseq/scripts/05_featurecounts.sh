#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

SUBREAD_IMAGE="quay.io/biocontainers/subread:2.0.6--he4a0461_2"
THREADS=8

log_docker_digest "$SUBREAD_IMAGE"

BAMS=$(tail -n +2 "$REPO_ROOT/config/samples.tsv" | awk -F'\t' '{print "/align/"$1"_Aligned.sortedByCoord.out.bam"}' | tr '\n' ' ')

log_run "featurecounts" "docker run --rm --cpus=${THREADS} --memory=8g \
  -v '$REPO_ROOT/ref':/ref -v '$REPO_ROOT/align':/align -v '$REPO_ROOT/results/counts':/out \
  $SUBREAD_IMAGE \
  featureCounts -T ${THREADS} -p --countReadPairs \
    -a /ref/Homo_sapiens.GRCh38.110.gtf \
    -o /out/gene_counts.tsv \
    ${BAMS}"

echo "카운트 매트릭스 생성 완료: results/counts/gene_counts.tsv (git에 커밋 대상, 가벼움)"
