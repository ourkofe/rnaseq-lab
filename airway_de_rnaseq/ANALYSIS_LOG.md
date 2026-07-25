## 00. 세팅
- 서버: epyc 32core(128), ram 503g, storage 87t (/BiO) - 공용이라 도커 cpus/memory 제한 걸고 쓰기
- 작업 위치 /BiO/kbioman/kbiomanuser20/rnaseq_practice/airway_de_rnaseq (루트 디스크 아니고 /BiO 확인함)

## 01. sra 다운로드
- SRR1039508/509 (dex 페어), SRR1039512/513 (untreated 페어) 4개만
- 처음엔 ftp로 받다가 계속 중간에 끊김 (Data transfer aborted 반복) -> https로 바꿔서 해결
- 최종 용량: 19GB

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
- 진행중
