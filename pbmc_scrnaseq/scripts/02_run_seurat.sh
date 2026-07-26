#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

SEURAT_IMAGE="satijalab/seurat:latest"
log_docker_digest "$SEURAT_IMAGE"

log_run "seurat_analysis" "docker run --rm --cpus=8 --memory=16g \
  --user $(id -u):$(id -g) \
  -v '$REPO_ROOT':/work -w /work \
  $SEURAT_IMAGE \
  Rscript scripts/02_seurat_analysis.R"
