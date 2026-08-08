# DE 분석 체크리스트 (실무 재사용용)

분석 진행하면서 여기 하나씩 채워나가기.

## 파이프라인
- [ ] QC 확인 (FastQC, MultiQC)
- [ ] 정렬률 확인 (STAR)
- [ ] featureCounts assigned 비율 확인

## EDA
- [ ] Library size 편차 확인
- [ ] PCA에서 주요 변동 요인 확인
- [ ] Sample distance heatmap으로 이상 샘플 확인

## 통계 모델 진단
- [ ] Dispersion plot 정상 패턴인지
- [ ] p-value histogram 모양 확인
- [ ] Cook's distance로 이상치 확인

## 결과 해석
- [ ] MA/Volcano plot으로 전체 패턴 확인
- [ ] 상위 유의 유전자 개별 확인
- [ ] 여러 도구(DESeq2/edgeR/limma) 결과 겹침 확인
- [ ] GO/KEGG/GSEA로 생물학적 타당성 확인

## 재현성
- [ ] sessionInfo() 기록
- [ ] 랜덤 시드 고정 확인
