# 작업 기록

그때그때 짧게 메모. 날짜 + 뭐 했는지 + 숫자 나온 거 있으면 적기.

---

## 00. 세팅
- 서버: epyc 32core(128), ram 503g, storage 87t (/BiO) - 공용, 도커 cpus/memory 제한
- 작업 위치 /BiO/kbioman/kbiomanuser20/rnaseq_practice/pbmc_scrnaseq
- bulk(airway_de_rnaseq) 다음 실습으로 single-cell 시작

## 01. 도구/데이터 선정
- gold standard 조합으로 가기로 함: Cell Ranger(정렬+카운트) + Seurat(다운스트림)
- 데이터: 10x Genomics 공개 pbmc_1k_v3 (1,222 cells, v3 chemistry)
- Zheng et al. 2017 (Nat Commun) - 10x Chromium 플랫폼 소개 논문 계열 데이터, 특정 논문 재현이 아니라
  "알려진 PBMC 마커 유전자로 클러스터가 잘 설명되는지" 검증하는 방식으로 설계

## 02. Cell Ranger 설치
- 10x Genomics 사이트에서 등록 없이 바로 다운로드 가능했음 (이전엔 EULA 폼 있었는데 간소화된 듯)
- cellranger-10.1.0.tar.gz (932MB), md5sum 확인 후 압축해제
- tools/cellranger-10.1.0/ 에 설치, root 권한 불필요, 완전 무료 (로컬 실행 기준)

## 03. 레퍼런스 다운로드
- refdata-gex-GRCh38-2024-A.tar.gz (11.5GB) - Cell Ranger 공식 사전빌드 레퍼런스
- 압축해제 후 16G (fasta, genes, star, reference.json 구조)
- star/ 안에 STAR 인덱스 이미 포함되어 있어서 별도 인덱스 빌드 불필요

## 04. PBMC fastq 다운로드
- 처음 URL에 버전 경로(3.0.0) 빠져서 AccessDenied 에러 -> 정확한 URL로 재시도
  (https://cf.10xgenomics.com/samples/cell-exp/3.0.0/pbmc_1k_v3/pbmc_1k_v3_fastqs.tar)
- 5.17GB, lane 2개(L001/L002) x read type 3개(R1/R2/I1) = 6개 파일

## 05. 분석 설계
- 워크플로우: Cell Ranger count -> Seurat 로드 -> QC필터 -> 정규화/HVG -> PCA ->
  클러스터링/UMAP -> 마커유전자 -> 세포타입 주석
- 리소스: cellranger count(cpus16/mem64g), seurat(cpus4~8/mem16g)
- 검증 기준: PBMC 마커 유전자 표 정리 (CD4 T=IL7R, B=MS4A1, NK=GNLY, Mono=CD14 등)
- docs/analysis_design.md 로 설계+개념 정리해서 저장

## 06. Cell Ranger count 실행
- cellranger count --localcores=16 --localmem=64 --create-bam=true
- 소요시간 12:32~13:00 (약 30분), 예상 범위(20~40분) 안에 들어옴
- Pipestance completed successfully

### 결과 (metrics_summary.csv)
| 지표 | 값 |
|---|---|
| Estimated Number of Cells | 1,221 (예상 1,222와 거의 일치) |
| Mean Reads per Cell | 54,547 |
| Median Genes per Cell | 3,290 |
| Median UMI Counts per Cell | 10,029 |
| Total Genes Detected | 25,863 |
| Valid Barcodes | 97.4% |
| Reads Mapped Confidently to Genome | 93.7% |
| Reads Mapped Confidently to Transcriptome | 81.4% |
| Sequencing Saturation | 70.8% |

전반적으로 정상 범위 넘어서는 우수한 품질. 다음 단계 진행에 문제없음.

### 참고: 최신 Cell Ranger는 클러스터링+주석까지 자동 실행
- RUN_GRAPH_CLUSTERING, RUN_UMAP, RUN_DIFFERENTIAL_EXPRESSION, Azimuth 기반
  cell type annotation까지 파이프라인 안에 이미 포함되어 있었음
  (원래 계획은 이걸 Seurat으로 직접 하려 했는데, Cell Ranger가 이미 상당 부분 해줌)
- 10x_Cloud 주석은 토큰 없어서 스킵됨 (로컬 Azimuth는 정상 실행)
- 결과 경로: results/pbmc_1k_v3_count/outs/
  - web_summary.html, metrics_summary.csv
  - filtered_feature_bc_matrix.h5 (Seurat 입력용)
  - analysis/ (Cell Ranger 자체 클러스터링/UMAP/DE)
  - cell_types/Azimuth/cell_types.csv (자동 세포타입 주석)
  - cloupe.cloupe (Loupe Browser용)

## 07. Seurat 분석 (QC ~ 클러스터링 ~ 마커 유전자)
- 입력: results/pbmc_1k_v3_count/outs/filtered_feature_bc_matrix.h5
- QC 필터링: nFeature_RNA 200~6000, percent.mt < 15
  - 필터링 전 1,195 세포 (Cell Ranger의 1,221과 살짝 다름, Seurat min.cells/min.features
    기본 필터가 먼저 적용된 영향으로 추정)
  - 필터링 후 1,135 세포
- PCA dims 1:10, FindClusters resolution 0.5 -> 클러스터 11개

### 클러스터별 마커 유전자 + 세포 타입 매칭

| 클러스터 | 검출된 마커 | 추정 세포 타입 |
|---|---|---|
| 0 | IL7R, CD3D, CD3E, CD3G, TRAC, CD2, CD28 | CD4 T세포 |
| 1 | CD14 (매우 강함, p=6.8e-109) | CD14+ 단핵구 |
| 2 | IL7R | T세포 (서브타입) |
| 3 | MS4A1 (log2FC 4.0) | B세포 |
| 4 | CD14 | CD14+ 단핵구 (서브그룹) |
| 5 | FCGR3A, FCER1A, MS4A14 | FCGR3A+ 단핵구/수지상세포 |
| 6 | IL7R, CD8A | CD8 T세포 |
| 7 | MS4A1 | B세포 (서브타입) |
| 8 | GNLY (log2FC 6.5), FCGR3A | NK세포 |
| 9 | GNLY, CD8A | NK/CD8 T세포 경계 |
| 10 | PPBP (log2FC 12.1, 극단적으로 강함) | 혈소판 |

- 검증 기준으로 세웠던 8개 세포 타입(CD4T, CD8T, B, NK, 단핵구 2종, 수지상세포, 혈소판)
  전부 특정 클러스터 마커로 확인됨. 일부는 세부 서브클러스터로 더 쪼개짐.
- PBMC 특성(다양한 면역세포 혼합)상 이상적인 결과로 판단.

### 결과 파일
- results/seurat/qc_violin_plot.pdf
- results/seurat/umap_clusters.pdf
- results/seurat/umap_markers.pdf
- results/seurat/marker_genes.csv
- results/seurat/pbmc_seurat_object.rds (203MB, git 제외 대상)

## 결론
- Cell Ranger + Seurat 조합(gold standard)으로 PBMC 1k 데이터 처리
- 클러스터링 결과가 알려진 PBMC 면역세포 마커 유전자로 잘 설명됨
- 이번 실습 목표(세포 타입별 클러스터링 + 마커 검증) 달성
