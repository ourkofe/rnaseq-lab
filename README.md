# RNA-seq 실습: Airway Dexamethasone 데이터셋 (STAR + Docker)

Himes et al. 2014 (PLOS ONE, PMID 24926665) 논문 데이터(GEO GSE52778 / SRA SRP033351)를
STAR 기반 현대적 파이프라인으로 재분석하는 실습 레포.

원 논문은 TopHat2 + Cufflinks/Cuffdiff를 사용했음(2013년 파이프라인).
이 실습은 STAR + featureCounts + DESeq2로 재현했을 때 같은 결론(DUSP1, KLF15,
CRISPLD2 등 dex 처리 시 상향발현)이 나오는지 확인하는 것이 목표.

## 폴더 구조

```
rnaseq-practice/
├── README.md            # 이 파일
├── ANALYSIS_LOG.md       # 실행 일지 (날짜별 기록, git에 커밋됨)
├── docs/
│   └── tools.md          # 사용 툴/버전/도커 이미지 정리
├── config/
│   └── samples.tsv       # 샘플 메타데이터 (SRR, 처리군/대조군, 셀라인)
├── scripts/               # 파이프라인 스크립트 (git에 커밋됨)
├── logs/                  # 각 실행의 텍스트 로그 (가벼움, git에 커밋됨)
├── results/                # 가벼운 최종 결과만 (git에 커밋됨)
│   ├── qc/                # MultiQC 리포트 등 (html, 수 MB)
│   ├── counts/             # featureCounts 카운트 매트릭스 (텍스트, 수 MB)
│   └── plots/              # DESeq2 결과 플롯 (png/pdf)
└── (git에 안 올라가는 것들 - .gitignore 처리)
    ├── data/         # 원본 fastq (수 GB~수십 GB)
    ├── ref/          # 레퍼런스 게놈/GTF
    ├── index/        # STAR 인덱스 (~30GB)
    └── align/        # BAM 파일들 (수십 GB)
```

## 핵심 원칙

1. **무거운 데이터는 로컬 서버에만, git에는 스크립트/로그/가벼운 결과만.**
2. **모든 도구는 Docker 이미지 태그로 버전 고정** → `docs/tools.md`에 기록.
3. **각 스크립트는 실행할 때마다 `logs/`에 타임스탬프+명령어+도구 버전을 자동 기록.**
4. 작업 끝나면 `scripts/99_cleanup.sh`로 무거운 중간산출물 삭제.
   (삭제 전 체크섬은 로그에 남겨서 "무엇이 있었는지"는 영구 기록.)

## 실행 순서

```bash
bash scripts/01_download_sra.sh
bash scripts/02_download_reference.sh
bash scripts/03_build_star_index.sh
bash scripts/04_align_star.sh
bash scripts/05_featurecounts.sh
Rscript scripts/06_deseq2.R
bash scripts/99_cleanup.sh   # 결과 확인 후 실행
```

각 단계 진행하면서 `ANALYSIS_LOG.md`에 한두 줄씩 추가하고 커밋하는 걸 추천.
