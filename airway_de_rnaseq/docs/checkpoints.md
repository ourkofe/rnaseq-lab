# 단계별 확인 가이드

각 단계 끝나면 뭘 봐야 하는지, 어느 파일/경로에서 확인하는지 정리.

---

## 01. SRA 다운로드

**경로**: `data/*.fastq.gz`

**확인할 것**
```bash
ls -la data/
du -sh data/
for f in data/*.fastq.gz; do gzip -t "$f" && echo "$f OK" || echo "$f BROKEN"; done
```
- 파일 개수 (샘플 수 × mate 2개)
- 용량이 예상 범위인지
- gzip 무결성 (중간에 끊긴 파일 없는지)

---

## 02. 레퍼런스 게놈

**경로**: `ref/*.fa`, `ref/*.gtf`

**확인할 것**
```bash
ls -la ref/
du -sh ref/
grep -c "^>" ref/*.fa   # fasta 안 시퀀스(염색체) 개수
```

---

## 03. QC (FastQC)

**경로**: `results/qc/fastqc/*_fastqc.html`

**확인할 것 (html 열어서)**
| 항목 | 정상 기준 |
|---|---|
| Per base sequence quality | 그래프가 green 영역 유지. read2가 read1보다 살짝 낮은 건 illumina 특성상 정상 |
| Adapter Content | 리드 후반부에서 확 튀어오르지 않으면 정상 |
| Per sequence GC content | 예상 분포에서 크게 안 벗어나면 정상 (사람이면 대략 40% 근처) |
| Sequence Duplication Levels | 너무 높으면 라이브러리 복잡도 낮음 의심 |

---

## 04. 트리밍 (fastp)

**경로**: `results/qc/fastp/*_fastp.html`, `data/trimmed/*.trimmed.fastq.gz`

**확인할 것**
```bash
du -sh data/trimmed/
```
- html 리포트에서 트리밍 전후 리드 수/품질 비교
- 트리밍으로 리드가 너무 많이 날아갔으면(원본 대비 20%+ 손실) 옵션 재검토 필요

---

## 05. STAR 인덱스 빌드

**경로**: `index/`, `logs/star_index_build.log`

**확인할 것**
```bash
ls -la index/          # Genome, SA, SAindex 등 핵심 파일 있는지
du -sh index/
grep "finished successfully" logs/star_index_build.log
```
- 사람 게놈 기준 인덱스 용량 28~32GB가 정상 범위

---

## 06. STAR 정렬

**경로**: `align/*_Log.final.out` (텍스트, 핵심), `align/*.bam` (결과 파일)

**확인할 것**
```bash
grep "Uniquely mapped reads %" align/*_Log.final.out
cat align/SRR1039508_Log.final.out   # 전체 통계 다 보고 싶을 때
```
| 지표 | 정상 기준 |
|---|---|
| Uniquely mapped reads % | 80% 이상이면 양호, 90%대면 아주 좋음 |
| % of reads mapped to multiple loci | 너무 높으면(20%+) 어노테이션/반복서열 문제 의심 |
| Mismatch rate per base | 너무 높으면 트리밍/품질 문제 의심 |

BAM 파일 자체를 더 자세히 보고 싶으면 samtools 사용:
```bash
docker run --rm -v $(pwd)/align:/align biocontainers/samtools samtools flagstat /align/SRR1039508_Aligned.sortedByCoord.out.bam
```

---

## 07. 정량 (featureCounts)

**경로**: `results/counts/gene_counts.tsv` (카운트 매트릭스), `results/counts/gene_counts.tsv.summary` (통계)

**확인할 것**
```bash
head -5 results/counts/gene_counts.tsv
cat results/counts/gene_counts.tsv.summary
```
| 지표 | 정상 기준 |
|---|---|
| Assigned 비율 | 60~80%대면 정상 |
| Unassigned_MultiMapping | 어느 정도는 정상 (10~15%대) |
| Unassigned_NoFeatures | 유전자 영역 밖에 떨어진 리드, 많으면 GTF 버전/strand 옵션 재검토 |

---

## 08. 발현차이분석 (DESeq2)

**경로**: `results/counts/deseq2_results.csv` (전체 결과), `results/plots/MA_plot.pdf` (시각화)

**확인할 것**
```bash
head -20 results/counts/deseq2_results.csv   # padj 기준 정렬되어 있음
```
| 컬럼 | 의미 | 봐야 할 것 |
|---|---|---|
| baseMean | 평균 발현량 | 너무 낮으면(한 자릿수) 통계적으로 불안정할 수 있음 |
| log2FoldChange | 발현 변화 배수(log2) | 양수=상향, 음수=하향. 절대값 클수록 변화 큼 |
| padj | 다중검정보정된 유의확률 | **0.05 미만이면 유의**. raw p-value 말고 반드시 이걸로 판단 |

MA plot(`MA_plot.pdf`)에서는 전체적으로 낮은 발현 유전자일수록 분산이 큰 깔때기 모양 패턴이 정상.

---

## 09. QC 통합 (MultiQC)

**경로**: `results/qc/multiqc/multiqc_report.html`

한 파일에 FastQC + fastp + STAR + featureCounts 결과가 다 모여있어서, 샘플 4개를 나란히 비교하기 제일 좋은 곳. 여기서 특정 샘플만 유독 튀는 수치가 있는지 한눈에 확인 가능.

---

## 10-11. 유전자 심볼 매핑 / 논문 비교

**경로**: `ref/gene_id_to_symbol.tsv` (매핑표), `results/counts/deseq2_results_annotated.csv` (심볼 붙인 최종 결과)

**확인할 것**
```bash
grep -E "CRISPLD2|DUSP1|KLF15|FKBP5|TSC22D3|PER1" results/counts/deseq2_results_annotated.csv
```
관심 유전자들의 log2FoldChange 방향(+/-)과 padj가 논문/기존 지식과 맞는지 비교.

---

## 전체 요약: 결과 파일 한눈에

| 단계 | 핵심 파일 |
|---|---|
| 다운로드 | `data/*.fastq.gz` |
| 레퍼런스 | `ref/*.fa`, `ref/*.gtf` |
| QC | `results/qc/fastqc/*.html` |
| 트리밍 | `data/trimmed/*.fastq.gz`, `results/qc/fastp/*.html` |
| 인덱스 | `index/` |
| 정렬 | `align/*.bam`, `align/*_Log.final.out` |
| 정량 | `results/counts/gene_counts.tsv(.summary)` |
| 통계분석 | `results/counts/deseq2_results.csv`, `results/plots/MA_plot.pdf` |
| 통합 QC | `results/qc/multiqc/multiqc_report.html` |
| 최종 해석 | `results/counts/deseq2_results_annotated.csv` |

## 공통 체크리스트 (모든 단계 공통)

- 파일 크기 0바이트거나 비정상적으로 작지 않은지
- 로그 안에 `finished successfully` / `Error` / `Warning` 키워드
- 예상 범위(용량, 시간, 비율)에서 크게 벗어나면 일단 의심하고 원인부터 확인
