# DESeq2 발현차이분석 - 단순 design (condition만)
# paired 버전은 scripts/deseq2_paired/09_deseq2_paired.R 참고
# 실행: bash scripts/deseq2_simple/08_run_deseq2.sh

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

dds <- DESeqDataSetFromMatrix(
  countData = counts_mat,
  colData = samples,
  design = ~condition
)

dds <- DESeq(dds)
res <- results(dds, contrast = c("condition", "dex", "untreated"))
res_ordered <- res[order(res$padj), ]

dir.create("results/deseq2_simple", showWarnings = FALSE)
write.csv(as.data.frame(res_ordered), "results/deseq2_simple/deseq2_results.csv")

cat("padj < 0.05 유의 유전자 수:", sum(res$padj < 0.05, na.rm = TRUE), "\n")
cat("(논문 보고값: 316개)\n")

pdf("results/deseq2_simple/MA_plot.pdf")
plotMA(res, main = "Dex vs Untreated - STAR/DESeq2 재분석")
dev.off()
