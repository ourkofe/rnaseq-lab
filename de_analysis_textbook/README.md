# de_analysis_textbook

RNA-seq 발현차이분석(DE)에서 분석가가 확인해야 할 모든 진단/시각화/해석
단계를 빠짐없이 훑는 교본용 실습.

`airway_de_rnaseq`가 "실제 논문 재현"이 목표였다면, 이번엔 **"이 결과를
믿어도 되는지 스스로 검증하는 모든 방법"**을 익히는 게 목표입니다. 다음
실무 프로젝트에서 어떤 요청을 받아도 당황하지 않을 체크리스트를 몸에
익히는 것이 최종 목적입니다.

## 데이터: Pasilla (Brooks et al. 2011, Genome Research)

- 초파리(Drosophila melanogaster) 세포에서 pasilla 유전자(splicing factor,
  사람의 NOVA1/NOVA2 상동유전자)를 RNAi로 억제한 실험
- GEO accession: **GSE18508**
- 7개 샘플: 대조군 4개(GSM461176-178, 461182), 처리군 3개(GSM461179-181)
- **의도적으로 지저분한 실무형 데이터**: single-end 3개, paired-end 4개가
  섞여있고 읽은 길이도 샘플마다 다름 — 실무에서 자주 마주치는 "완벽하지
  않은 실험 디자인"을 다뤄보는 연습이 됨
- DESeq2 공식 vignette이 이 데이터로 모든 기능을 설명하므로, 결과가
  이상하면 공식 문서와 바로 대조 가능 (검증 체크포인트로 활용)
- 초파리 게놈이 사람의 약 1/17 크기라 정렬/인덱스가 훨씬 가벼움 →
  파이프라인은 빠르게 넘기고 다운스트림에 집중 가능

## 핵심 설계 포인트: Multi-factor design

`airway_de_rnaseq`에서 세포주(cell_line)를 design에 반영해서
(`~cell_line + condition`) 통계 검정력이 크게 개선됐던 것 기억하시면,
이번 데이터도 똑같은 원리가 적용됩니다.

이 데이터는 single-end/paired-end 시퀀싱이 섞여 있는데, 이게 생물학적
차이가 아니라 **기술적 차이(batch)**입니다. 이걸 무시하고 `~condition`만
쓰면 이 기술적 변동이 노이즈로 섞여 들어가고, `~type + condition`으로
명시하면 이 변동을 먼저 통제한 뒤 처리 효과만 순수하게 볼 수 있습니다.
이번 실습에서는 두 방식을 모두 돌려서 실제로 얼마나 차이 나는지 직접
비교합니다.

## 전체 워크플로우

### 1단계: 기초 파이프라인 (빠르게 진행)
1. GEO/SRA에서 fastq 다운로드 (7개 샘플, single-end/paired-end 혼재)
2. FastQC + MultiQC로 QC (샘플별 read length 차이도 여기서 확인됨)
3. fastp 트리밍
4. STAR 정렬 (BDGP6 레퍼런스, Ensembl)
5. featureCounts 정량

### 2단계: 탐색적 데이터 분석 (EDA) — 통계 검정 전 항상 먼저 볼 것들
6. Raw count 분포 확인 (샘플 간 library size 차이)
7. Size factor(정규화 계수) 계산 및 정규화 전후 비교
8. VST/rlog 변환 — 왜 하는지, 그냥 log2 쓰면 안 되는 이유
9. Sample-to-sample distance heatmap
10. PCA (PC1/PC2뿐 아니라 PC3까지, 분산 설명 비율 확인 — type과 condition
    중 어느 게 더 큰 변동 요인인지 확인)
11. Hierarchical clustering dendrogram

### 3단계: 통계 모델 진단 — "이 결과를 믿어도 되는가"
12. Dispersion 추정 plot (raw → fitted → shrunk, DESeq2 핵심 원리 시각화)
13. p-value histogram (모델이 잘 맞으면 특정 분포 모양 — 이상하면 모델
    문제 의심)
14. Independent filtering이 뭔지, mean count 기준 어떻게 걸러지는지
15. Cook's distance로 이상치(outlier) 샘플/유전자 확인

### 4단계: design 비교 (핵심 설계 포인트 검증)
16. `~condition`(단순) vs `~type + condition`(multi-factor) 결과 비교
17. 유의 유전자 개수, PCA에서 batch 제거 효과 시각적 확인

### 5단계: 결과 시각화 "정석 세트"
18. MA plot
19. Volcano plot (유의 유전자 라벨링)
20. 상위 유의 유전자 heatmap (z-score 정규화)
21. 개별 유전자 발현량 boxplot (top hit 몇 개)

### 6단계: 도구 간 교차검증
22. DESeq2 vs edgeR vs limma-voom 세 도구로 각각 분석
23. 세 결과의 유의 유전자 겹치는 정도 (Venn/UpSet plot)

### 7단계: 생물학적 해석
24. GO/KEGG enrichment 분석 (clusterProfiler, 초파리 주석 DB 사용)
25. GSEA (fgsea, permutation 기반이라 seed 고정 필수)

### 8단계: 검증 및 재현성
26. 우리 결과(유의 유전자 개수 등)를 DESeq2 공식 vignette/원 논문
    보고치와 대조
27. `sessionInfo()`로 전체 R 환경(패키지 버전 등) 기록

### 9단계: 최종 산출물
28. 모든 과정을 하나로 묶은 종합 리포트 (R Markdown)

## 도구

| 단계 | 도구 |
|---|---|
| QC/트리밍 | FastQC, MultiQC, fastp |
| 정렬 | STAR |
| 정량 | featureCounts |
| 통계 (메인) | DESeq2 |
| 통계 (교차검증) | edgeR, limma-voom |
| 기능 해석 | clusterProfiler, fgsea |
| 초파리 유전자 주석 | org.Dm.eg.db (GO), KEGG organism code `dme` |
| 리포트 | R Markdown (knitr) |

## 리소스 계획

초파리 게놈이라 사람 대비 훨씬 가벼움:

| 단계 | cpus | memory | 비고 |
|---|---|---|---|
| STAR 인덱스 빌드 | 8 | 8g | 게놈 작아서 요구 메모리도 훨씬 적음 |
| STAR 정렬 (샘플당) | 8 | 8g | |
| DESeq2/edgeR/limma 분석 | 4 | 8g | 유전자 수 적어서 가벼움 |
| GSEA | 4 | 4g | |

## 도커 사용 시 참고 (wgs-wes-lab에서 얻은 교훈 적용)

대용량은 아니지만, 습관 유지 차원에서 모든 `docker run`에 기본 적용:
- `-v "$REPO_ROOT/tmp":/tmp`, `-e TMPDIR=/tmp`
- `--log-driver=none`
- GATK류는 아니지만, R/Java 기반 도구도 동일하게 tmp 마운트 적용

## 폴더 구조
'''
de_analysis_textbook/
├── README.md - 이 문서
├── ANALYSIS_LOG.md
├── docs/
│ └── checklist.md - "확인할 것" 체크리스트 (실무에서 재사용 목적)
├── config/
│ └── samples.tsv - 7개 샘플 메타데이터 (condition, type 포함)
├── scripts/
├── data/ (git 제외)
├── ref/ (git 제외)
├── results/
│ ├── qc/
│ ├── counts/
│ ├── deseq2/ - EDA, 진단, 시각화, design 비교
│ ├── tool_comparison/ - edgeR, limma-voom 결과 + 비교
│ ├── enrichment/ - GO/KEGG/GSEA
│ └── report/ - 최종 R Markdown 리포트
└── logs/
'''
## 진행 상황

- [ ] 데이터/레퍼런스 다운로드
- [ ] QC + 트리밍
- [ ] STAR 정렬 (single-end/paired-end 혼재 처리)
- [ ] featureCounts 정량
- [ ] EDA (정규화, PCA, heatmap, dendrogram)
- [ ] DESeq2 통계 진단 (dispersion, p-value histogram, independent filtering, Cook's distance)
- [ ] design 비교 (단순 vs multi-factor)
- [ ] 결과 시각화 (MA/volcano/heatmap/boxplot)
- [ ] 도구 교차검증 (DESeq2 vs edgeR vs limma-voom)
- [ ] 기능적 해석 (GO/KEGG/GSEA)
- [ ] 검증 (vignette/논문과 대조) + 재현성 기록
- [ ] 종합 리포트 작성

## 참고

`rnaseq-lab`의 다른 실습들과 마찬가지로:
- 실제 공개 데이터로 진행, 무거운 원본/중간산출물은 git 제외
- 표준 도구 우선 사용, 이번엔 특히 "여러 도구로 교차검증"하는 습관에 집중
