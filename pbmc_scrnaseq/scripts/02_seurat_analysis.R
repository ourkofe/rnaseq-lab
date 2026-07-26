# Seurat 분석: QC ~ 클러스터링 ~ 마커 유전자
# 실행: bash scripts/02_run_seurat.sh

library(Seurat)

pbmc.data <- Read10X_h5("results/pbmc_1k_v3_count/outs/filtered_feature_bc_matrix.h5")
pbmc <- CreateSeuratObject(counts = pbmc.data, project = "pbmc_1k_v3",
                            min.cells = 3, min.features = 200)

# QC 지표 계산
pbmc[["percent.mt"]] <- PercentageFeatureSet(pbmc, pattern = "^MT-")

dir.create("results/seurat", showWarnings = FALSE)

pdf("results/seurat/qc_violin_plot.pdf")
VlnPlot(pbmc, features = c("nFeature_RNA", "nCount_RNA", "percent.mt"), ncol = 3)
dev.off()

cat("필터링 전 세포 수:", ncol(pbmc), "\n")

# QC 필터링 (일반적인 기준값)
pbmc <- subset(pbmc, subset = nFeature_RNA > 200 & nFeature_RNA < 6000 & percent.mt < 15)
cat("필터링 후 세포 수:", ncol(pbmc), "\n")

# 정규화 + 고변동 유전자
pbmc <- NormalizeData(pbmc)
pbmc <- FindVariableFeatures(pbmc, selection.method = "vst", nfeatures = 2000)

# 스케일링 + PCA
all.genes <- rownames(pbmc)
pbmc <- ScaleData(pbmc, features = all.genes)
pbmc <- RunPCA(pbmc, features = VariableFeatures(pbmc))

# 클러스터링 + UMAP
pbmc <- FindNeighbors(pbmc, dims = 1:10)
pbmc <- FindClusters(pbmc, resolution = 0.5)
pbmc <- RunUMAP(pbmc, dims = 1:10)

pdf("results/seurat/umap_clusters.pdf")
DimPlot(pbmc, reduction = "umap", label = TRUE)
dev.off()

cat("클러스터 개수:", length(unique(Idents(pbmc))), "\n")

# 마커 유전자 탐색
markers <- FindAllMarkers(pbmc, only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25)
write.csv(markers, "results/seurat/marker_genes.csv", row.names = FALSE)

# 알려진 PBMC 마커로 확인
known_markers <- c("IL7R", "CD3D", "CD8A", "MS4A1", "CD79A", "GNLY", "NKG7",
                    "CD14", "LYZ", "FCGR3A", "MS4A7", "FCER1A", "PPBP")
known_markers <- known_markers[known_markers %in% rownames(pbmc)]

pdf("results/seurat/umap_markers.pdf", width = 12, height = 10)
FeaturePlot(pbmc, features = known_markers)
dev.off()

saveRDS(pbmc, "results/seurat/pbmc_seurat_object.rds")

cat("완료. 결과는 results/seurat/ 확인\n")
