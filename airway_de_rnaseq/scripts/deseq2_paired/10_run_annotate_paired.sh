#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../_lib_log.sh"

DESEQ_IMAGE="quay.io/biocontainers/bioconductor-deseq2:1.42.0--r43hf17093f_2"
log_docker_digest "$DESEQ_IMAGE"

log_run "annotate_paired" "docker run --rm --cpus=2 --memory=4g \
  --user $(id -u):$(id -g) \
  -v '$REPO_ROOT':/work -w /work \
  $DESEQ_IMAGE \
  Rscript scripts/deseq2_paired/10_annotate_paired.R"
