#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

STAR_IMAGE="quay.io/biocontainers/star:2.7.11a--h0033a41_0"
mkdir -p "$REPO_ROOT/align"
log_docker_digest "$STAR_IMAGE"

RUNS="SRR1039508 SRR1039509 SRR1039512 SRR1039513"

for run in $RUNS; do
  log_run "star_align_${run}" "docker run --rm --cpus=8 --memory=32g \
    --user $(id -u):$(id -g) \
    -v '$REPO_ROOT/index':/index -v '$REPO_ROOT/data/trimmed':/data -v '$REPO_ROOT/align':/align \
    $STAR_IMAGE \
    STAR --genomeDir /index \
         --readFilesIn /data/${run}_1.trimmed.fastq.gz /data/${run}_2.trimmed.fastq.gz \
         --readFilesCommand zcat \
         --outSAMtype BAM SortedByCoordinate \
         --outFileNamePrefix /align/${run}_ \
         --runThreadN 8"
done

du -sh "$REPO_ROOT/align"
