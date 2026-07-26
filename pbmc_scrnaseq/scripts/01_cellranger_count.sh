#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

CELLRANGER="$REPO_ROOT/tools/cellranger-10.1.0/cellranger"
REF="$REPO_ROOT/ref/refdata-gex-GRCh38-2024-A"
FASTQS="$REPO_ROOT/data/pbmc_1k_v3_fastqs"
SAMPLE="pbmc_1k_v3"

cd "$REPO_ROOT/results"

log_run "cellranger_count" "$CELLRANGER count \
  --id=${SAMPLE}_count \
  --transcriptome='$REF' \
  --fastqs='$FASTQS' \
  --sample=$SAMPLE \
  --create-bam=true \
  --localcores=16 \
  --localmem=64"
