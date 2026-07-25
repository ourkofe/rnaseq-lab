#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

SUBREAD_IMAGE="quay.io/biocontainers/subread:2.0.6--he4a0461_2"
mkdir -p "$REPO_ROOT/results/counts"
log_docker_digest "$SUBREAD_IMAGE"

BAMS="/align/SRR1039508_Aligned.sortedByCoord.out.bam \
/align/SRR1039509_Aligned.sortedByCoord.out.bam \
/align/SRR1039512_Aligned.sortedByCoord.out.bam \
/align/SRR1039513_Aligned.sortedByCoord.out.bam"

log_run "featurecounts" "docker run --rm --cpus=4 --memory=4g \
  --user $(id -u):$(id -g) \
  -v '$REPO_ROOT/ref':/ref -v '$REPO_ROOT/align':/align -v '$REPO_ROOT/results/counts':/out \
  $SUBREAD_IMAGE \
  featureCounts -T 4 -p --countReadPairs \
    -a /ref/Homo_sapiens.GRCh38.110.gtf \
    -o /out/gene_counts.tsv \
    $BAMS"

echo "results/counts/gene_counts.tsv 생성됨"
