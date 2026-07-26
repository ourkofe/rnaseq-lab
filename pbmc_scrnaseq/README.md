# pbmc_scrnaseq

10x Genomics 공개 PBMC 1k 데이터를 Cell Ranger + Seurat으로 클러스터링하고,
알려진 면역세포 마커 유전자로 세포 타입이 잘 설명되는지 확인하는 실습입니다.

airway_de_rnaseq(bulk)에 이어지는 두 번째 실습이고, RNA-seq에서 "세포 하나하나를
구분해서 본다"는 완전히 다른 축(single-cell)을 다룹니다.

## 왜 이 데이터인가

Zheng et al. 2017 (Nat Commun) - 10x Chromium 플랫폼을 소개한 논문 계열의 표준
튜토리얼 데이터입니다. 특정 논문 수치를 재현하는 게 아니라, 표준 도구(gold standard)로
처리했을 때 알려진 면역세포 마커로 클러스터가 잘 설명되는지 검증하는 방식으로
설계했습니다.

## 워크플로우
raw fastq (barcode+UMI)
│
▼
Cell Ranger count - 정렬 + 세포별 유전자 카운트 매트릭스
│
▼
Seurat 로드 - 카운트 매트릭스를 Seurat object로
│
▼
QC 필터링 - 세포당 유전자 수, 미토콘드리아 비율 확인
│
▼
정규화 + 고변동 유전자 - 세포 간 비교 가능하게 스케일 맞춤
│
▼
PCA 차원축소 - 핵심 축 몇 개로 압축
│
▼
클러스터링 + UMAP - 비슷한 세포끼리 그룹, 2D 시각화
│
▼
마커 유전자 탐색 - 클러스터별 특징 유전자 찾기
│
▼
세포 타입 주석 - 마커로 T세포, B세포 등 이름 붙이기

## 도구

| 단계 | 도구 |
|---|---|
| 정렬+카운트 | Cell Ranger 10.1.0 (10x 공식, gold standard) |
| 다운스트림 | Seurat (`satijalab/seurat` 도커, 역사적 gold standard) |

## 결과 요약

- 세포 1,221개 검출, QC 필터 후 1,135개
- 클러스터 11개로 분류
- 검증 기준으로 세운 8개 PBMC 마커 유전자(IL7R, CD8A, MS4A1, GNLY, CD14, FCGR3A,
  FCER1A, PPBP) 전부 특정 클러스터에서 유의하게 검출됨
- CD4/CD8 T세포, B세포, NK세포, 단핵구 2종, 혈소판까지 알려진 면역세포 타입이
  거의 다 잘 갈라짐

## 폴더
pbmc_scrnaseq/
├── tools/cellranger-10.1.0/ - Cell Ranger 실행파일 (git 제외)
├── ref/refdata-gex-GRCh38-2024-A/ - 레퍼런스 (git 제외)
├── data/pbmc_1k_v3_fastqs/ - 원본 fastq (git 제외)
├── scripts/ - 단계별 스크립트
├── results/
│ ├── pbmc_1k_v3_count/ - Cell Ranger 원본 출력 (git 제외, 무거움)
│ ├── pbmc_1k_v3_count_summary/ - 가벼운 요약본 (git 포함)
│ └── seurat/ - 클러스터링/마커 결과 (git 포함, rds만 제외)
├── logs/
├── docs/
│ ├── analysis_design.md - 설계 + 배경 개념
│ └── commands_index.md - 재실행/확인 명령어 인덱스
└── ANALYSIS_LOG.md - 진행 기록

## 진행 상황

- [x] Cell Ranger 설치
- [x] 레퍼런스/데이터 다운로드
- [x] Cell Ranger count 실행
- [x] Seurat QC/클러스터링/마커 유전자
- [x] 세포 타입 매칭
- [ ] (확장 후보) 조건 비교, sub-clustering, pathway 분석 등

## 참고

bulk(airway_de_rnaseq)와 다르게, Cell Ranger 최신 버전은 자체적으로도
클러스터링/UMAP/Azimuth 기반 세포 타입 주석을 해줍니다
(`results/pbmc_1k_v3_count/outs/analysis/`, `outs/cell_types/Azimuth/`).
이번엔 원래 계획대로 Seurat으로 직접 돌린 결과를 썼는데, 나중에 여유 있으면
두 결과를 비교해보는 것도 좋은 확장이 될 것 같습니다.
