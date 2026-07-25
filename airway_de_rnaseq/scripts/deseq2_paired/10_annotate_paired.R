# 논문 핵심 유전자 확인 - paired design 결과 기준
# 실행: bash scripts/deseq2_paired/10_run_annotate_paired.sh

mapping <- read.delim("ref/gene_id_to_symbol.tsv", header = FALSE,
                       col.names = c("gene_id", "gene_symbol"))

res <- read.csv("results/deseq2_paired/deseq2_results.csv", row.names = 1)
res$gene_id <- rownames(res)

res_annotated <- merge(res, mapping, by = "gene_id", all.x = TRUE)
res_annotated <- res_annotated[order(res_annotated$padj), ]

write.csv(res_annotated, "results/deseq2_paired/deseq2_results_annotated.csv", row.names = FALSE)

genes_of_interest <- c("CRISPLD2", "DUSP1", "KLF15", "FKBP5", "TSC22D3", "PER1")
check <- res_annotated[res_annotated$gene_symbol %in% genes_of_interest,
                        c("gene_symbol", "log2FoldChange", "padj")]
check <- check[order(check$gene_symbol), ]

cat("=== 논문 핵심 유전자 확인 (paired design) ===\n")
print(check)
