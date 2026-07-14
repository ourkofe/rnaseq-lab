#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

STAR_IMAGE="quay.io/biocontainers/star:2.7.11a--h0033a41_0"
THREADS=16   # 공용 서버 배려 - 128코어 다 안 씀

mkdir -p "$REPO_ROOT/index"
log_docker_digest "$STAR_IMAGE"

log_run "star_index_build" "docker run --rm --cpus=${THREADS} --memory=64g \
  -v '$REPO_ROOT/ref':/ref -v '$REPO_ROOT/index':/index \
  $STAR_IMAGE \
  STAR --runMode genomeGenerate \
       --genomeDir /index \
       --genomeFastaFiles /ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
       --sjdbGTFfile /ref/Homo_sapiens.GRCh38.110.gtf \
       --sjdbOverhang 100 \
       --runThreadN ${THREADS}"

du -sh "$REPO_ROOT/index"
