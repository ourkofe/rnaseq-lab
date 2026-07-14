#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

ENSEMBL_RELEASE=110
mkdir -p "$REPO_ROOT/ref"
cd "$REPO_ROOT/ref"

log_run "download_genome_fasta" \
  "wget -c https://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"

log_run "download_gtf" \
  "wget -c https://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/gtf/homo_sapiens/Homo_sapiens.GRCh38.${ENSEMBL_RELEASE}.gtf.gz"

log_run "unzip_reference" "gunzip -k *.gz"

echo "레퍼런스 버전: Ensembl release ${ENSEMBL_RELEASE}" >> "$REPO_ROOT/logs/reference_version.txt"
du -sh "$REPO_ROOT/ref"
