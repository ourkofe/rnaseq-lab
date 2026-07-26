# PBMC scRNA-seq 분석 설계

## 목표

PBMC 1k 데이터를 Cell Ranger + Seurat으로 처리해서, 세포들이 실제 면역세포
타입별로 클러스터링되는지, 각 클러스터가 알려진 마커 유전자로 설명되는지 확인.

bulk 때(Himes 2014 논문 재현)와 달리, 이 데이터(`pbmc_1k_v3`)는 특정 논문의
데이터가 아니라 10x Chromium 플랫폼(Zheng 2017 계열)의 표준 튜토리얼 데이터라서,
"논문 수치 재현"이 아니라 "알려진 면역세포 마커로 클러스터가 잘 설명되는지"를
검증하는 방식으로 감.

## 데이터 개요

- 10x Genomics 공개 데이터셋: `pbmc_1k_v3`
- 세포 약 1,222개, 세포당 평균 약 54,000 리드
- Illumina NovaSeq, 28bp R1(16bp barcode + 12bp UMI), 91bp R2(transcript)
- 라이선스: CC BY 4.0

## 워크플로우

```
raw fastq (barcode+UMI)
    │
    ▼
Cell Ranger count          - 정렬 + 세포별 유전자 카운트 매트릭스
    │
    ▼
Seurat 로드                 - 카운트 매트릭스를 Seurat object로
    │
    ▼
QC 필터링                   - 세포당 유전자 수, 미토콘드리아 비율 확인
    │
    ▼
정규화 + 고변동 유전자 선택   - 세포 간 비교 가능하게 스케일 맞춤
    │
    ▼
PCA 차원축소                - 수천 유전자를 핵심 축 몇 개로 압축
    │
    ▼
클러스터링 + UMAP            - 비슷한 세포끼리 그룹, 2D로 시각화
    │
    ▼
클러스터별 마커 유전자 탐색   - 각 클러스터를 특징짓는 유전자 찾기
    │
    ▼
세포 타입 주석               - 마커로 T세포, B세포 등 이름 붙이기
```

## 도구/버전

| 단계 | 도구 | 비고 |
|---|---|---|
| 정렬+카운트 | Cell Ranger 10.1.0 | gold standard, 10x 공식 |
| 다운스트림 | Seurat (`satijalab/seurat` 도커) | 이 분야 역사적 gold standard |
| 시각화 | Seurat 내장 (UMAP, FeaturePlot 등) | 별도 도구 불필요 |

## 리소스 계획

| 단계 | cpus | memory | 예상 시간 |
|---|---|---|---|
| Cell Ranger count | 16 | 64g | 20~40분 |
| Seurat 분석 | 4~8 | 16g | 몇 분 (세포 수 적어서 가벼움) |

## 검증 기준: PBMC 마커 유전자

| 세포 타입 | 마커 유전자 |
|---|---|
| CD4 T세포 | IL7R, CD3D |
| CD8 T세포 | CD8A, CD3D |
| B세포 | MS4A1, CD79A |
| NK세포 | GNLY, NKG7 |
| 단핵구 (CD14+) | CD14, LYZ |
| 단핵구 (FCGR3A+) | FCGR3A, MS4A7 |
| 수지상세포 | FCER1A |
| 혈소판 | PPBP |

## 폴더 구조

```
pbmc_scrnaseq/
├── tools/cellranger-10.1.0/
├── ref/refdata-gex-GRCh38-2024-A/
├── data/pbmc_1k_v3_fastqs/
├── scripts/
│   ├── _lib_log.sh
│   ├── 01_cellranger_count.sh
│   └── 02_seurat_analysis.R + 02_run_seurat.sh
├── results/
│   ├── pbmc_1k_v3_count/     (Cell Ranger 출력, 무거움 - git 제외)
│   └── seurat/               (플롯, 마커 유전자 표 - git 포함)
├── logs/
├── docs/
└── ANALYSIS_LOG.md
```

---

# 기반 개념 정리

bulk 때와 겹치지 않는, single-cell 특유의 새로운 개념들.

## 1. Barcode와 UMI

- **Barcode**: 세포 하나하나에 붙는 고유 이름표. "이 mRNA가 몇 번 세포에서
  왔는지" 구분하는 용도.
- **UMI (Unique Molecular Identifier)**: mRNA 분자 하나하나에 붙는 개별 번호표.
  PCR 증폭 과정에서 생기는 중복을 제거하기 위한 것 — 같은 UMI를 가진 리드는
  원래 분자 하나였다고 판단해서, 진짜 발현량만 세게 해줌.

## 2. 카운트 매트릭스

bulk는 "유전자 x 샘플" 표였다면, single-cell은 **"유전자 x 세포"** 표.
세포 하나가 가진 mRNA 양이 적어서 대부분의 칸이 0인 sparse matrix(희소행렬)
형태로 저장됨.

## 3. QC 지표

- **nFeature (검출된 유전자 수)**: 너무 적으면 빈 방울 의심, 너무 많으면
  doublet(세포 2개가 한 방울에 들어간 경우) 의심
- **nCount (총 UMI 수)**: mRNA가 충분히 검출됐는지
- **미토콘드리아 유전자 비율**: 세포가 죽어가면 핵 mRNA는 빠져나가고
  미토콘드리아 mRNA만 상대적으로 많이 남는 경향 → 비율 높으면 손상 세포 의심

## 4. 정규화 (Normalization)

세포마다 시퀀싱된 총량(UMI 수)이 다 다름. 이 차이를 안 맞추면 "많이 읽힌
세포가 원래 발현량도 높다"는 착각을 하게 됨. 각 세포의 총 발현량 기준으로
비율을 맞추고 로그 변환해서 세포 간 공정한 비교가 가능하게 만드는 과정.

## 5. 고변동 유전자 (HVG) 선택

유전자 대부분은 모든 세포에서 비슷하게 발현됨(하우스키핑 유전자 등).
세포 타입 구분에 실제로 도움 되는 건 세포마다 발현량 차이가 큰 유전자들이라,
분산이 큰 상위 2,000개 정도만 골라서 이후 분석에 사용.

## 6. PCA (주성분분석)

수천 개 유전자 정보를 "가장 큰 변동을 설명하는 축(주성분) 몇십 개"로 압축.
bulk 때 PCA(PC1=세포주, PC2=처리군)와 원리는 같은데, 여기선 유전자가 아니라
세포 하나하나가 점이 됨.

## 7. 클러스터링

PCA로 압축된 좌표를 가지고 "가까이 있는 세포들끼리는 비슷한 세포"라는
가정으로 그룹을 나눔. Seurat은 보통 그래프 기반 클러스터링(Louvain 알고리즘)
사용 — 각 세포를 가장 가까운 이웃들과 연결한 그래프에서 촘촘하게 뭉친
커뮤니티를 찾는 방식. 이 단계에서는 아직 "무슨 세포인지" 모름, 그룹만 나뉨.

## 8. UMAP

고차원(PCA) 구조를 최대한 보존하면서 2차원 평면에 펼쳐주는 시각화 기법.
가까웠던 세포는 2D에서도 가깝게, 멀었던 세포는 멀게 그려줘서 클러스터가
지도 위의 섬처럼 보이게 됨.

## 9. 마커 유전자 탐색

각 클러스터가 다른 클러스터들에 비해 유난히 많이 발현하는 유전자를 찾는 작업.
원리는 bulk의 발현차이분석과 비슷 — "이 그룹 vs 나머지 전부"를 비교해서
유의하게 차이 나는 유전자를 찾음.

## 10. 세포 타입 주석

찾은 마커 유전자를 기존 면역학 지식과 대조해서 생물학적 이름을 붙이는 작업
(예: CD14+LYZ 강하게 발현 → 단핵구).

---

# scRNA-seq 확장 방향 (다음 실습 후보)

지금 하는 것(클러스터링 + 타입 주석)이 기초이고, 여기서 여러 방향으로 확장 가능.

```
지금 하는 것: 세포 클러스터링 + 타입 주석 (기초)
        │
        ├── 더 세밀하게 (sub-clustering, rare cell type 발견)
        ├── 시간 축 추가 (trajectory analysis, RNA velocity)
        ├── 조건 비교 (세포 타입별 그룹 간 DE, 세포 비율 변화)
        ├── 세포 간 관계 (cell-cell communication, regulatory network)
        ├── 여러 샘플 통합 (batch integration, multi-sample atlas)
        └── 다른 정보 결합 (CITE-seq, multiome, spatial transcriptomics)
```

이번 실습 끝나면 자연스러운 다음 확장은 조건 비교(처리군/대조군 PBMC로
세포 타입별 반응 차이 보기) 또는 trajectory analysis.
