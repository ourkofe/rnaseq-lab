# DESeq2 발현차이분석
# 실행: docker run --rm -v $(pwd):/work -w /work bioconductor/bioconductor_docker:RELEASE_3_18 \
#         Rscript scripts/06_deseq2.R

library(DESeq2)

counts_raw <- read.delim("results/counts/gene_counts.tsv", comment.char = "#")
gene_ids <- counts_raw$Geneid
count_cols <- grep("Aligned.sortedByCoord.out.bam$", colnames(counts_raw))
counts_mat <- as.matrix(counts_raw[, count_cols])
rownames(counts_mat) <- gene_ids
colnames(counts_mat) <- sub("_Aligned.*", "", basename(colnames(counts_mat)))

samples <- read.delim("config/samples.tsv")
samples <- samples[match(colnames(counts_mat), samples$run), ]
samples$condition <- factor(samples$condition, levels = c("untreated", "dex"))

dds <- DESeqDataSetFromMatrix(
  countData = counts_mat,
  colData = samples,
  design = ~condition
)

dds <- DESeq(dds)
res <- results(dds, contrast = c("condition", "dex", "untreated"))
res_ordered <- res[order(res$padj), ]

dir.create("results/plots", showWarnings = FALSE)
write.csv(as.data.frame(res_ordered), "results/counts/deseq2_results.csv")

# 논문에서 보고된 주요 유전자들이 여기서도 유의한지 확인
genes_of_interest <- c("CRISPLD2", "DUSP1", "KLF15", "FKBP5", "TSC22D3", "PER1")
# 참고: featureCounts 결과는 Ensembl gene ID 기준이므로, 실제 확인 시
# biomaRt 등으로 gene symbol <-> Ensembl ID 매핑이 필요함 (다음 단계 TODO)

cat("padj < 0.05 유의 유전자 수:", sum(res$padj < 0.05, na.rm = TRUE), "\n")
cat("(논문 보고값: 316개)\n")

pdf("results/plots/MA_plot.pdf")
plotMA(res, main = "Dex vs Untreated - STAR/DESeq2 재분석")
dev.off()
