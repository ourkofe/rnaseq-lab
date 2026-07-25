# 명령어 / 파일 인덱스

각 단계마다 (1) 다시 실행하는 명령어 (2) 결과 확인하는 명령어 (3) 핵심 파일 경로를 모아둠.
나중에 "이거 어떻게 다시 봤더라" 싶을 때 여기만 보면 되게.

---

## 01. SRA 다운로드

**재실행**
```bash
bash scripts/01_download_sra.sh
```
**확인**
```bash
ls -la data/
du -sh data/
for f in data/*.fastq.gz; do gzip -t "$f" && echo "$f OK" || echo "$f BROKEN"; done
```
**파일**: `data/*.fastq.gz`

---

## 02. 레퍼런스 게놈

**재실행**
```bash
bash scripts/02_download_reference.sh
```
**확인**
```bash
ls -la ref/
grep -c "^>" ref/*.fa
```
**파일**: `ref/Homo_sapiens.GRCh38.dna.primary_assembly.fa`, `ref/Homo_sapiens.GRCh38.110.gtf`

---

## 03. QC (FastQC)

**재실행**
```bash
bash scripts/03_qc_fastqc.sh
```
**확인**: html 직접 열기
**파일**: `results/qc/fastqc/*_fastqc.html`

---

## 04. 트리밍 (fastp)

**재실행**
```bash
bash scripts/04_trim_fastp.sh
```
**확인**
```bash
du -sh data/trimmed/
```
**파일**: `data/trimmed/*.trimmed.fastq.gz`, `results/qc/fastp/*_fastp.html`

---

## 05. STAR 인덱스 빌드

**재실행**
```bash
bash scripts/05_build_star_index.sh
```
**확인**
```bash
ls -la index/
du -sh index/
grep "finished successfully" logs/star_index_build.log
```
**파일**: `index/` (Genome, SA, SAindex 등)

---

## 06. STAR 정렬

**재실행**
```bash
bash scripts/06_align_star.sh
```
**확인**
```bash
grep "Uniquely mapped reads %" align/*_Log.final.out
cat align/SRR1039508_Log.final.out   # 전체 통계
```
**파일**: `align/*.bam`, `align/*_Log.final.out`

---

## 07. 정량 (featureCounts)

**재실행**
```bash
bash scripts/07_featurecounts.sh
```
**확인**
```bash
head -5 results/counts/gene_counts.tsv
cat results/counts/gene_counts.tsv.summary
```
**파일**: `results/counts/gene_counts.tsv(.summary)`

---

## 08. 발현차이분석 - 단순 design (`~condition`)

**재실행**
```bash
bash scripts/deseq2_simple/08_run_deseq2.sh
```
**확인**
```bash
head -20 results/deseq2_simple/deseq2_results.csv   # padj 순 정렬됨
```
**파일**: `results/deseq2_simple/deseq2_results.csv`, `results/deseq2_simple/MA_plot.pdf`

**결과**: 유의 유전자(padj<0.05) **786개**

---

## 09. 발현차이분석 - paired design (`~cell_line + condition`)

**재실행**
```bash
bash scripts/deseq2_paired/09_run_deseq2_paired.sh
```
**확인**
```bash
head -20 results/deseq2_paired/deseq2_results.csv
```
**파일**: `results/deseq2_paired/deseq2_results.csv`, `results/deseq2_paired/MA_plot.pdf`, `results/deseq2_paired/PCA_plot.pdf`

**결과**: 유의 유전자(padj<0.05) **1379개** (단순 design보다 많음, 세포주 효과 통제 덕분)

---

## 10. QC 통합 (MultiQC)

**재실행**
```bash
bash scripts/09_multiqc.sh
```
**확인**: html 직접 열기
**파일**: `results/qc/multiqc/multiqc_report.html`

---

## 11. 유전자 심볼 매핑

**재실행**
```bash
bash scripts/10_map_gene_symbols.sh
```
**확인**
```bash
wc -l ref/gene_id_to_symbol.tsv
awk -F'\t' '{print NF}' ref/gene_id_to_symbol.tsv | sort | uniq -c   # 전부 2로 나와야 정상
```
**파일**: `ref/gene_id_to_symbol.tsv`

---

## 12. 논문 유전자 검증

**재실행 (단순 design 기준)**
```bash
bash scripts/11_run_annotate.sh
```
**재실행 (paired design 기준)**
```bash
bash scripts/deseq2_paired/10_run_annotate_paired.sh
```
**확인**
```bash
grep -E "CRISPLD2|DUSP1|KLF15|FKBP5|TSC22D3|PER1" results/deseq2_paired/deseq2_results_annotated.csv
```
**파일**: `results/counts/deseq2_results_annotated.csv`(단순), `results/deseq2_paired/deseq2_results_annotated.csv`(paired)

---

## 전체 파일 트리 요약
airway_de_rnaseq/
├── data/.fastq.gz, data/trimmed/.fastq.gz [git 제외]
├── ref/*.fa, .gtf, gene_id_to_symbol.tsv [git 제외 - fa/gtf만, 매핑표는 작아서 커밋 가능]
├── index/ [git 제외]
├── align/.bam, _Log.final.out [git 제외 - bam만, 로그는 작음]
├── results/
│ ├── qc/{fastqc,fastp,multiqc}/.html [git 포함]
│ ├── counts/gene_counts.tsv(.summary) [git 포함]
│ ├── deseq2_simple/ [git 포함]
│ └── deseq2_paired/ [git 포함]
├── scripts/ [git 포함]
├── logs/ [git 포함]
├── config/samples.tsv [git 포함]
├── docs/{tools.md, commands_index.md} [git 포함]
├── ANALYSIS_LOG.md [git 포함]
└── README.md [git 포함]
## 핵심 수치 요약 (한눈에)

| 항목 | 값 |
|---|---|
| 샘플 수 | 4 (dex 2, untreated 2) |
| 원본 데이터 용량 | 19G |
| STAR 인덱스 용량 | 28G |
| 평균 정렬률 | 94.9% (논문 83.4%) |
| featureCounts Assigned 비율 | 78~82% |
| 유의 유전자 (단순 design) | 786개 |
| 유의 유전자 (paired design) | 1379개 |
| 논문 보고 유의 유전자 | 316개 |
| 논문 핵심 유전자 6개 재현 여부 | 전부 재현 (방향/유의성 일치) |
