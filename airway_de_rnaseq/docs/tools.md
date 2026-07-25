-# 사용 툴 및 버전

# 쓴 툴

버전은 도커 태그로 고정. 나중에 다시 돌려도 똑같이 나오게.

| 단계 | 툴 | 이미지 |
|---|---|---|
| 다운로드 | wget (ena, https) | - |
| qc | fastqc | biocontainers/fastqc:v0.11.9_cv8 |
| 트리밍 | fastp | quay.io/biocontainers/fastp:0.23.4--h5f740d0_0 |
| 정렬 | star | quay.io/biocontainers/star:2.7.11a--h0033a41_0 |
| 정량 | featurecounts (subread) | quay.io/biocontainers/subread:2.0.6--he4a0461_2 |
| qc 종합 | multiqc | quay.io/biocontainers/multiqc:1.19--pyhdfd78af_0 |
| 통계 (단순/paired 둘 다) | deseq2 | quay.io/biocontainers/bioconductor-deseq2:1.42.0--r43hf17093f_2 |
| gene symbol 매핑 | gawk (GTF 파싱, 도커 없이 서버에 설치된 gawk 4.1.4 사용) | - |

-## 레퍼런스 데이터
-
-| 항목 | 출처 | 버전 |
+| 단계 | 툴 | 이미지 |
 |---|---|---|
-| 게놈 fasta | Ensembl | GRCh38, release (기록) |
-| GTF 어노테이션 | Ensembl/GENCODE | release (기록) |
-
-## 버전 확인 습관
+| 다운로드 | wget (ena) | - |
+| qc | fastqc | biocontainers/fastqc:v0.11.9_cv8 |
+| 트리밍 | fastp | quay.io/biocontainers/fastp:0.23.4--h5f740d0_0 |
+| 정렬 | star | quay.io/biocontainers/star:2.7.11a--h0033a41_0 |
+| 정량 | featurecounts (subread) | quay.io/biocontainers/subread:2.0.6--he4a0461_2 |
+| qc 종합 | multiqc | quay.io/biocontainers/multiqc:1.19--pyhdfd78af_0 |
+| 통계 | deseq2 | bioconductor/bioconductor_docker:RELEASE_3_18 |

+레퍼런스: GRCh38, ensembl release 110

## 삽질 기록 (나중에 참고용)
- bioconductor_docker 이미지는 DESeq2가 기본 설치 안 되어있음, 매번 설치하려니
  Bioconductor 서버 다운로드가 504로 실패 -> quay.io biocontainers 쪽 사전설치 이미지로 교체
- --user 옵션 쓰면 install.packages가 시스템 경로에 쓰기 권한 없어서 실패 -> 결국 이미지 교체로 우회
