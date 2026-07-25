#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

FASTQC_IMAGE="biocontainers/fastqc:v0.11.9_cv8"
mkdir -p "$REPO_ROOT/results/qc/fastqc"

log_docker_digest "$FASTQC_IMAGE"

log_run "fastqc" "docker run --rm --cpus=4 --memory=4g \
  -v '$REPO_ROOT/data':/data -v '$REPO_ROOT/results/qc/fastqc':/out \
  $FASTQC_IMAGE \
  sh -c 'fastqc /data/*.fastq.gz -o /out'"

echo "results/qc/fastqc/ 에 샘플당 html+zip 생김"
