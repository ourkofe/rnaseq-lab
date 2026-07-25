# 작업 기록

그때그때 짧게 메모. 날짜 + 뭐 했는지 + 숫자 나온 거 있으면 적기.

---

## 00. 세팅
- 서버: epyc 32core(128), ram 503g, storage 87t (/BiO) - 공용이라 도커 cpus/memory 제한 걸고 쓰기
- 작업 위치 /BiO/kbioman/kbiomanuser20/rnaseq_practice/airway_de_rnaseq (루트 디스크 아니고 /BiO 확인함)

## 01. sra 다운로드
- SRR1039508/509 (dex 페어), SRR1039512/513 (untreated 페어) 4개만
- 처음엔 ftp로 받다가 계속 중간에 끊김 (Data transfer aborted 반복) -> https로 바꿔서 해결
- 최종 용량: 19G

## 02. 레퍼런스
- GRCh38 + ensembl release 110 gtf
- 용량 5.2G (fasta 3.15G + gtf 1.46G, 압축해제 상태)

## 03. qc (fastqc)
- adapter content 깨끗함
- per base quality: read2가 read1보다 살짝 낮음 - illumina에서 흔한 패턴, 문제없다고 판단

## 04. 트리밍 (fastp)
- 기본 옵션으로 가볍게만
- 트리밍 후 용량 9.1G

## 05. star index
- 소요시간 15:00:49 ~ 15:45:30 (약 45분)
- 인덱스 용량 28G

## 06. star 정렬
- 중간에 한번 강제종료 있었음 (메모리 16g로 잡았다가 디스크 스와핑 걸려서 너무 느림) -> 32g로 올려서 재시작
- 4샘플 다 finished successfully, 총 정렬 8.1G
- 정렬률: SRR1039508 94.36%, SRR1039509 93.99%, SRR1039512 95.56%, SRR1039513 95.62% (평균 약 94.9%)
- 논문 보고 평균(83.36%, TopHat2 기준)보다 높게 나옴 - STAR가 더 최신 도구고, fastp 트리밍 거쳤고, 레퍼런스도 GRCh38로 최신이라 그런듯

## 07. featurecounts
- Assigned 비율: SRR1039508 78.8%, SRR1039509 80.2%, SRR1039512 80.8%, SRR1039513 81.8%
- 나머지는 MultiMapping(11~12%), NoFeatures(3~4%), Ambiguity(5~6%) - 전형적인 분포

## 08. deseq2
- 처음에 DESeq2 패키지 설치가 계속 실패 (bioconductor_docker 이미지는 패키지가 안 깔려있어서 매번 설치해야 했는데, 의존 패키지 다운로드 중 504 에러) -> quay.io/biocontainers/bioconductor-deseq2 이미지(패키지 이미 설치됨)로 바꿔서 해결
- 스크립트 버그 2개 있었음: (1) samples 매칭 후 rownames 안 붙여줘서 에러 -> rownames(samples) <- samples$run 추가 (2) R이 컬럼명에 자동으로 X./ . 붙이는 것 때문에 정규식 안 맞음 -> SRR 숫자만 뽑는 정규식으로 수정
- padj < 0.05 유의 유전자 수: 786개 (논문 보고값 316개, 더 많이 나옴 - 정렬률/검정력 높아진 영향으로 추정)

## 09. multiqc
- 완료, results/qc/multiqc/multiqc_report.html 로 전체 qc~정량 결과 통합 확인 가능

## 10-11. 논문 유전자 검증 (gene symbol 매핑)
- GTF에서 gene_id-gene_name 매핑표 직접 추출 (gene_name 없는 유전자 20393개는 gene_id로 대체)
- 논문 핵심 유전자 6개 전부 유의하게 상향발현 확인:

| 유전자 | log2FoldChange | padj |
|---|---|---|
| CRISPLD2 | +2.86 | 9.6e-37 |
| DUSP1 | +2.88 | 1.3e-23 |
| FKBP5 | +4.24 | 5.5e-76 |
| KLF15 | +4.47 | 3.8e-37 |
| PER1 | +3.33 | 2.2e-22 |
| TSC22D3 | +3.54 | 3.9e-62 |


## 12. 실험 디자인 개선 (paired design)
- 원래 design = ~condition 만 썼는데, samples.tsv에 cell_line 정보가 있는 걸 활용 안 하고 있었음
- design = ~cell_line + condition 으로 바꿔서 재실행 (scripts/deseq2_paired/)
- 유의 유전자 786개 -> 1379개로 증가 (세포주 효과를 모델에서 통제하니 처리 효과가 더 선명하게 드러남)
- 논문 핵심 6개 유전자 padj 자릿수가 전부 몇십~몇백 배 더 작아짐 (예: FKBP5 5.5e-76 -> 1.2e-138)

## 13. PCA 확인
- results/deseq2_paired/PCA_plot.pdf
- PC1(67% 분산) = 세포주(N61311 vs N052611) 차이로 분리
- PC2(30% 분산) = 처리 여부(dex vs untreated) 차이로 분리
- PC1이 세포주로 갈라진다는 게, 왜 paired design이 필요했는지를 시각적으로 뒷받침함
  (세포주 간 변동이 가장 큰 변동 요인이었는데 단순 design은 이걸 노이즈로 방치했던 것)

## 결론
- 2014년 논문(TopHat2+Cufflinks) 결과가 STAR+DESeq2로 독립 재분석해도 재현됨
- 실험 디자인(paired structure)을 통계 모델에 반영하는 것만으로도 결과 품질이 크게 개선됨을 직접 확인
- 이번 실습 목표(논문 재현 + 최신 도구 검증) 달성, 여기서 마무리

---

# 각 단계에서 봐야 할 것 (다음에 참고용)

## fastqc (03단계)
- **Per base sequence quality**: 그래프가 green 영역 유지하는지. read2가 read1보다 살짝 낮은 건 illumina 특성상 정상, 크게 처지지만 않으면 됨
- **Adapter content**: 오른쪽 끝에서 확 튀어오르면 트리밍 강하게 필요, 평평하면 괜찮음
- **Per sequence GC content**: 예상 GC 분포에서 크게 벗어나면 오염(contamination) 의심

## star 정렬 로그 (Log.final.out, 06단계)
- **Uniquely mapped reads %**: 이게 제일 중요한 지표. 사람 RNA-seq이면 보통 80% 이상이면 양호, 90%대면 아주 좋은 편
- **% of reads mapped to multiple loci**: 너무 높으면(20%+) 레퍼런스/어노테이션 문제이거나 반복서열 많은 라이브러리일 수 있음
- **Mismatch rate per base**: 너무 높으면 트리밍/품질 문제 의심

## featurecounts summary (07단계)
- **Assigned 비율**: 60~80%대면 정상. 이보다 낮으면 GTF 버전 안 맞거나 strand 옵션 잘못 준 경우 의심
- **Unassigned_MultiMapping**: 여러 위치에 매핑된 리드 비율, 어느 정도는 정상
- **Unassigned_NoFeatures**: 유전자 영역 밖에 떨어진 리드, intergenic 영역 많으면 올라감

## deseq2 결과 (08단계)
- **log2FoldChange**: 양수면 처리군에서 상향, 음수면 하향. 절대값이 클수록 변화 폭 큼
- **padj (adjusted p-value)**: 다중검정보정된 유의확률, 0.05 미만이면 통계적으로 유의하다고 판단. raw p-value 말고 꼭 padj로 봐야 함
- **baseMean**: 평균 발현량. 너무 낮은 유전자(baseMean이 몇 안 되는)는 통계적으로 불안정할 수 있어서 해석 주의
- **dispersion plot / MA plot**: 전체적인 분산-평균 관계가 예상 패턴(낮은 발현 유전자일수록 분산 큼)을 따르는지 육안 확인
- **유의 유전자 개수**: 논문/이전 분석과 비교할 때 참고치, 그 자체로 절대적인 "좋다/나쁘다" 기준은 아님 (검정력, 샘플 수, 도구 차이로 얼마든지 달라질 수 있음)

## 공통으로 항상 확인할 것
- 파일 크기가 0바이트거나 비정상적으로 작은지 (중간에 끊긴 신호)
- 로그 안에 "finished successfully" / "Error" / "Warning" 키워드
- 예상 범위(용량, 시간, 비율)에서 크게 벗어나면 일단 의심하고 원인 찾기
