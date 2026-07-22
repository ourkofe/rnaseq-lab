# rnaseq-practice

airway dex 데이터(GSE52778) STAR로 재분석 해보는 중.
원 논문(Himes 2014, PMID 24926665)은 TopHat2+Cufflinks 썼는데,
STAR+featureCounts+DESeq2로 다시 돌리면 결과 비슷하게 나오나 확인해보는 실습.

## 폴더
rnaseq-practice/airway-rnaseq
├── ANALYSIS_LOG.md   # 하다가 메모, 커밋됨
├── docs/tools.md     # 쓴 툴/버전 기록
├── config/samples.tsv
├── scripts/          # 단계별 스크립트
├── logs/             # 실행 로그 (커밋됨)
├── results/          # 카운트, qc, 플롯 (커밋됨)
└── data / ref / index / align   # 무거운 것들, git 안 올림 (.gitignore)

## 순서

```bash
bash scripts/01_download_sra.sh
bash scripts/02_download_reference.sh
bash scripts/03_build_star_index.sh
bash scripts/04_align_star.sh
bash scripts/05_featurecounts.sh
Rscript scripts/06_deseq2.R
bash scripts/99_cleanup.sh   # 다 끝나고 무거운 것들 정리
```

data/ref/index/align은 서버에만 두고 git엔 안 올림 (용량 때문에).
끝나면 99_cleanup으로 지우되, 지우기 전에 체크섬은 logs에 남게 해둠.
