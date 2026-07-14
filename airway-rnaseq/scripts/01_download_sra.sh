#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

mkdir -p "$REPO_ROOT/data"
cd "$REPO_ROOT/data"

# ENA에서 gzip 압축 상태로 직접 다운로드 (fasterq-dump 대신 - 훨씬 적은 용량)
# 4개 샘플: dex 처리 2 + untreated 2 (config/samples.tsv 참고)
# ENA 경로 규칙: accession 숫자부(7자리)의 마지막 한 자리를 "00X"로 붙임
declare -A RUN_PATH=(
  [SRR1039508]="SRR103/008/SRR1039508"
  [SRR1039509]="SRR103/009/SRR1039509"
  [SRR1039512]="SRR103/002/SRR1039512"
  [SRR1039513]="SRR103/003/SRR1039513"
)

for run in "${!RUN_PATH[@]}"; do
  path="${RUN_PATH[$run]}"
  for mate in 1 2; do
    url="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/${path}/${run}_${mate}.fastq.gz"
    log_run "download_${run}_${mate}" "wget -c '$url'"
  done
done

echo "다운로드 완료. 용량 확인:"
du -sh "$REPO_ROOT/data"
