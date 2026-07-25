#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

mkdir -p "$REPO_ROOT/data"
cd "$REPO_ROOT/data"

# dex 처리 페어: SRR1039508, SRR1039509
# untreated 페어: SRR1039512, SRR1039513
declare -A RUN_PATH=(
  [SRR1039508]="SRR103/008/SRR1039508"
  [SRR1039509]="SRR103/009/SRR1039509"
  [SRR1039512]="SRR103/002/SRR1039512"
  [SRR1039513]="SRR103/003/SRR1039513"
)

for run in "${!RUN_PATH[@]}"; do
  path="${RUN_PATH[$run]}"
  for mate in 1 2; do
    url="https://ftp.sra.ebi.ac.uk/vol1/fastq/${path}/${run}_${mate}.fastq.gz"
    log_run "download_${run}_${mate}" "wget -c --tries=0 --waitretry=5 --timeout=60 '$url'"
  done
done

du -sh "$REPO_ROOT/data"
