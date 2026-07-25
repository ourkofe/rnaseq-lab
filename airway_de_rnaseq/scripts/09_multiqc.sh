#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

MULTIQC_IMAGE="quay.io/biocontainers/multiqc:1.19--pyhdfd78af_0"
mkdir -p "$REPO_ROOT/results/qc/multiqc"
log_docker_digest "$MULTIQC_IMAGE"

log_run "multiqc" "docker run --rm --cpus=2 --memory=2g \
  --user $(id -u):$(id -g) \
  -v '$REPO_ROOT':/work -w /work \
  $MULTIQC_IMAGE \
  multiqc results/ align/ -o results/qc/multiqc"

echo "results/qc/multiqc/multiqc_report.html 생성"
