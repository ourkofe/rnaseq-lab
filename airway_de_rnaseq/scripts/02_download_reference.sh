#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

RELEASE=110
mkdir -p "$REPO_ROOT/ref"
cd "$REPO_ROOT/ref"

log_run "download_genome_fasta" \
  "wget -c https://ftp.ensembl.org/pub/release-${RELEASE}/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"

log_run "download_gtf" \
  "wget -c https://ftp.ensembl.org/pub/release-${RELEASE}/gtf/homo_sapiens/Homo_sapiens.GRCh38.${RELEASE}.gtf.gz"

gunzip -k *.gz

du -sh "$REPO_ROOT/ref"
