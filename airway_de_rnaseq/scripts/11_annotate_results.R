mapping <- read.delim("ref/gene_id_to_symbol.tsv", header = FALSE,
                       col.names = c("gene_id", "gene_symbol"))

res <- read.csv("results/counts/deseq2_results.csv", row.names = 1)
res$gene_id <- rownames(res)

res_annotated <- merge(res, mapping, by = "gene_id", all.x = TRUE)
res_annotated <- res_annotated[order(res_annotated$padj), ]

write.csv(res_annotated, "results/counts/deseq2_results_annotated.csv", row.names = FALSE)

genes_of_interest <- c("CRISPLD2", "DUSP1", "KLF15", "FKBP5", "TSC22D3", "PER1")
check <- res_annotated[res_annotated$gene_symbol %in% genes_of_interest,
                        c("gene_symbol", "log2FoldChange", "padj")]
check <- check[order(check$gene_symbol), ]

cat("=== 논문 핵심 유전자 확인 ===\n")
print(check)
