#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

FASTP_IMAGE="quay.io/biocontainers/fastp:0.23.4--h5f740d0_0"
mkdir -p "$REPO_ROOT/data/trimmed" "$REPO_ROOT/results/qc/fastp"

log_docker_digest "$FASTP_IMAGE"

RUNS="SRR1039508 SRR1039509 SRR1039512 SRR1039513"

for run in $RUNS; do
  log_run "fastp_${run}" "docker run --rm --cpus=4 --memory=4g \
    -v '$REPO_ROOT/data':/data -v '$REPO_ROOT/results/qc/fastp':/qc \
    $FASTP_IMAGE \
    fastp -i /data/${run}_1.fastq.gz -I /data/${run}_2.fastq.gz \
          -o /data/trimmed/${run}_1.trimmed.fastq.gz -O /data/trimmed/${run}_2.trimmed.fastq.gz \
          -h /qc/${run}_fastp.html -j /qc/${run}_fastp.json"
done

du -sh "$REPO_ROOT/data/trimmed"
