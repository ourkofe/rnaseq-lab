-# 사용 툴 및 버전
+# 쓴 툴

-Docker 이미지 태그로 버전을 고정하기 때문에, 여기 적힌 태그 그대로 다시 받으면
-몇 달/몇 년 뒤에도 완전히 동일한 실행 환경을 재현할 수 있음.
+버전은 도커 태그로 고정. 나중에 다시 돌려도 똑같이 나오게.

-| 단계 | 툴 | 버전 / Docker 이미지 | 용도 |
-|---|---|---|---|
-| 다운로드 | (wget / ENA) | - | SRA fastq.gz 직접 다운로드 |
-| QC | FastQC | `biocontainers/fastqc:v0.11.9_cv8` | 원본 리드 품질 확인 |
-| 트리밍 | fastp | `quay.io/biocontainers/fastp:0.23.4--h5f740d0_0` | 어댑터/저품질 트리밍 |
-| 정렬 | STAR | `quay.io/biocontainers/star:2.7.11a--h0033a41_0` | 스플라이스 인지 정렬 |
-| 정량 | Subread (featureCounts) | `quay.io/biocontainers/subread:2.0.6--he4a0461_2` | 유전자별 리드 카운트 |
-| QC 종합 | MultiQC | `quay.io/biocontainers/multiqc:1.19--pyhdfd78af_0` | 전체 단계 리포트 종합 |
-| 통계분석 | R + DESeq2 | `bioconductor/bioconductor_docker:RELEASE_3_18` | 발현차이분석 |
-
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

+이미지 다이제스트 남기고 싶으면:
```bash
-docker inspect --format='{{index .RepoDigests 0}}' quay.io/biocontainers/star:2.7.11a--h0033a41_0 \
-  >> ../logs/image_digests.txt
+docker inspect --format='{{index .RepoDigests 0}}' <image> >> ../logs/image_digests.txt
```
