# airway_de_rnaseq

airway smooth muscle 세포에 덱사메타손(글루코코르티코이드) 처리했을 때 발현이 어떻게
달라지는지 보는 실습입니다. 원 논문(Himes et al. 2014, PLOS ONE, PMID 24926665)의
GSE52778 / SRP033351 데이터를 가져와서, 지금 표준적으로 많이 쓰이는 STAR + DESeq2
조합으로 다시 분석해보고 있습니다. 원 논문은 2013년 당시 파이프라인인 TopHat2 +
Cufflinks/Cuffdiff를 썼는데, 요즘 도구로 돌리면 같은 결론(DUSP1, KLF15, CRISPLD2 등이
처리군에서 상향 발현)이 나오는지 확인하는 게 목표입니다.

## 워크플로우

원본 리드 → QC → 트리밍 → 정렬 → BAM 후처리/QC → 정량 → QC 통합 리포트 →
발현차이분석 → 결과 해석, 순서로 진행합니다.

```
raw fastq (SRA)
    │
    ▼
QC (FastQC)             - 리드 품질, 어댑터 확인
    │
    ▼
트리밍 (fastp)            - 저품질/어댑터 제거
    │
    ▼
정렬 (STAR)               - GRCh38 레퍼런스에 매핑
    │
    ▼
BAM 후처리/QC (samtools)   - index, flagstat으로 정렬 통계 확인
    │
    ▼
정량 (featureCounts)      - 유전자별 리드 수 계산
    │
    ▼
QC 통합 리포트 (MultiQC)    - 지금까지 전 단계 결과 한번에 모아서 확인
    │
    ▼
발현차이분석 (DESeq2)       - 처리군 vs 대조군 통계 비교
    │
    ▼
결과 해석                 - 유의 유전자가 논문/airway 패키지 결과랑 맞는지 확인
```

samtools, MultiQC은 원래 계획엔 없었는데 도커 실습 겸 QC 습관 들이기 겸 추가했습니다.
스크립트는 미리 다 짜두지 않고, 각 단계 진행하면서 그때그때 만들어서
`scripts/`에 추가하는 방식으로 가고 있습니다.

## 데이터

- 샘플 4개만 사용: SRR1039508, SRR1039509 (덱사메타손 처리 페어), SRR1039512,
  SRR1039513 (대조군 페어) — 자세한 건 `config/samples.tsv` 참고
- ENA에서 fastq.gz 상태로 직접 받음 (fasterq-dump 대신, 용량 아끼려고)
- 레퍼런스: GRCh38 + Ensembl GTF

## 지금까지 진행 상황

- [x] SRA fastq 다운로드 완료
- [ ] 레퍼런스 게놈 다운로드
- [ ] QC (FastQC)
- [ ] 트리밍 (fastp)
- [ ] STAR 인덱스 빌드 + 정렬
- [ ] BAM 후처리/QC (samtools)
- [ ] featureCounts 정량
- [ ] MultiQC 통합 리포트
- [ ] DESeq2 발현차이분석
- [ ] 논문/airway 패키지 결과와 비교

## 폴더

```
airway_de_rnaseq/
├── ANALYSIS_LOG.md    - 진행하면서 남기는 메모
├── docs/tools.md      - 쓴 툴/버전 정리
├── config/samples.tsv - 샘플 정보
├── scripts/           - 단계별로 하나씩 추가되는 스크립트
├── logs/              - 각 실행 로그
├── results/           - 카운트, qc, 플롯 등 가벼운 결과물
└── data/ref/index/align - 무거운 데이터, 로컬에만 두고 git엔 안 올림
```

## 서버 관련

공용 서버라서 도커 실행할 때 `--cpus`, `--memory` 항상 명시하고, STAR도 스레드 8개 정도로 제한해서 사용합니다. 
다 끝나면 무거운 중간 산출물은 지우고 가벼운 결과물이랑 로그만 남겨둘 계획.

## 나중에 여유 있으면

- Salmon으로 같은 데이터 한 번 더 정량해서, STAR+featureCounts(정렬 기반) 결과랑
  얼마나 비슷한지 비교 (정렬 기반 vs pseudo-alignment 방식 차이 체감용)
