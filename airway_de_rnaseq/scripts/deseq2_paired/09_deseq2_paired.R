# scripts/deseq2_paired/09_deseq2_paired.R
library(DESeq2)

counts_raw <- read.delim("results/counts/gene_counts.tsv", comment.char = "#")
gene_ids <- counts_raw$Geneid
count_cols <- grep("Aligned.sortedByCoord.out.bam$", colnames(counts_raw))
counts_mat <- as.matrix(counts_raw[, count_cols])
rownames(counts_mat) <- gene_ids
colnames(counts_mat) <- sub(".*(SRR[0-9]+).*", "\\1", colnames(counts_mat))

samples <- read.delim("config/samples.tsv")
samples <- samples[match(colnames(counts_mat), samples$run), ]
rownames(samples) <- samples$run
stopifnot(all(rownames(samples) == colnames(counts_mat)))

samples$condition <- factor(samples$condition, levels = c("untreated", "dex"))
samples$cell_line <- factor(samples$cell_line)

dds <- DESeqDataSetFromMatrix(
  countData = counts_mat,
  colData = samples,
  design = ~cell_line + condition
)

dds <- DESeq(dds)
res <- results(dds, contrast = c("condition", "dex", "untreated"))
res_ordered <- res[order(res$padj), ]

dir.create("results/deseq2_paired", showWarnings = FALSE)
write.csv(as.data.frame(res_ordered), "results/deseq2_paired/deseq2_results.csv")

cat("=== paired design (~cell_line + condition) 결과 ===\n")
cat("padj < 0.05 유의 유전자 수:", sum(res$padj < 0.05, na.rm = TRUE), "\n")
cat("(논문 보고값: 316개, 단순 design 결과는 results/deseq2_simple/ 참고)\n")

pdf("results/deseq2_paired/MA_plot.pdf")
plotMA(res, main = "Dex vs Untreated (paired) - STAR/DESeq2 재분석")
dev.off()

vsd <- vst(dds, blind = FALSE)
pdf("results/deseq2_paired/PCA_plot.pdf")
print(plotPCA(vsd, intgroup = c("condition", "cell_line")))
dev.off()

print(warnings())
