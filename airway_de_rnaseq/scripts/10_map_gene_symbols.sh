#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib_log.sh"

GTF="$REPO_ROOT/ref/Homo_sapiens.GRCh38.110.gtf"
OUT="$REPO_ROOT/ref/gene_id_to_symbol.tsv"

log_run "extract_gene_symbols" "awk -F'\t' '\$3==\"gene\"' '$GTF' | \
  awk -F'\t' '{
    match(\$9, /gene_id \"([^\"]+)\"/, gid);
    match(\$9, /gene_name \"([^\"]+)\"/, gname);
    id = gid[1];
    name = (gname[1] != \"\") ? gname[1] : gid[1];
    print id \"\t\" name;
  }' > '$OUT'"

wc -l "$OUT"
awk -F'\t' '{print NF}' "$OUT" | sort | uniq -c
