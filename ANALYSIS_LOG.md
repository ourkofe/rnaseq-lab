# 분석 일지

형식: `## [날짜] 단계명` 아래에 무엇을 했는지, 어떤 이슈가 있었는지,
주요 수치(정렬률, 리드 수 등)를 짧게 남긴다. 매 단계 끝날 때마다 커밋.

---

## [YYYY-MM-DD] 00. 환경 세팅
- 서버 스펙: AMD EPYC 7452 32-core / 128 core, RAM 503G, storage 87.3T (공용 서버)
- 리소스 배려: 도커 실행 시 `--cpus`, `--memory` 항상 명시. STAR `--runThreadN`은
  16~24로 제한 (128 다 안 씀).
- Docker 확인: `docker --version` → (기록)

## [YYYY-MM-DD] 01. SRA 데이터 다운로드
- 대상 샘플: SRR1039508, SRR1039509 (dex 처리 페어), SRR1039512, SRR1039513 (대조군 페어)
- 다운로드 방식: ENA gzip 직접 다운로드 (fasterq-dump 대신, 압축 상태 유지)
- 실제 다운로드 용량: (기록)
- 이슈: (있으면 기록)

## [YYYY-MM-DD] 02. 레퍼런스 준비
- GRCh38 primary assembly + GENCODE/Ensembl GTF 버전: (release 번호 기록)
- 용량: (기록)

## [YYYY-MM-DD] 03. STAR 인덱스 빌드
- STAR 버전: (docs/tools.md 참조)
- 소요 시간: (기록)
- 인덱스 용량: (기록, 예상 ~30GB)
- RAM peak 사용량: (기록, `/usr/bin/time -v` 등으로 확인 가능)

## [YYYY-MM-DD] 04. STAR 정렬
- 샘플별 정렬률(Uniquely mapped %): (기록 - Log.final.out 파일 참고)
- 논문 보고 정렬률(83.36% 평균)과 비교: (기록)

## [YYYY-MM-DD] 05. featureCounts 정량
- 사용한 GTF, strand 옵션: (기록)
- 할당률(assigned reads %): (기록)

## [YYYY-MM-DD] 06. DESeq2 분석
- 유의 유전자 수 (padj < 0.05): (기록, 논문은 316개)
- 논문 top 유전자 재현 여부 (DUSP1, KLF15, CRISPLD2, FKBP5, TSC22D3 등): (기록)

## [YYYY-MM-DD] 99. 정리
- 삭제한 항목: data/, index/, align/ (체크섬은 logs/checksums_*.txt에 보관)
- 남긴 것: results/ 전체, logs/ 전체
