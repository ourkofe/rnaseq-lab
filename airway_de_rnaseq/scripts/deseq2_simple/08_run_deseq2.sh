#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../_lib_log.sh"

DESEQ_IMAGE="quay.io/biocontainers/bioconductor-deseq2:1.42.0--r43hf17093f_2"
log_docker_digest "$DESEQ_IMAGE"

log_run "deseq2_simple" "docker run --rm --cpus=4 --memory=8g \
  --user $(id -u):$(id -g) \
  -v '$REPO_ROOT':/work -w /work \
  $DESEQ_IMAGE \
  Rscript scripts/deseq2_simple/08_deseq2.R"
