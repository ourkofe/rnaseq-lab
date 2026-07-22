# rnaseq-lab

rna-seq 기반으로 다양한 실습을 해보고 아카이빙하는 레포지토리. 
하나 끝날 때마다 폴더 추가하는 식으로 진행.

```
rnaseq-lab/
├── airway_de_rnaseq/   # 첫번째 - airway dex, star+deseq2
└── ...
```

## rna-seq이란?

세포 안에서 어떤 유전자가 얼마나 발현되고 있는지 확인하는 방법입니다. mRNA를 뽑아서
시퀀싱하면 각 유전자 서열이 얼마나 많이 읽히는지 알 수 있고, 많이 읽힐수록 그 유전자가
많이 발현되고 있다고 봅니다.

DNA는 같은 사람 몸 안에서는 세포마다 다 똑같은데, 어떤 유전자를 켜고 끄는지는 세포
종류나 상태에 따라 달라집니다. 간세포와 뉴런이 하는 일이 다른 것도, 약물 처리 전후로
반응이 다른 것도 결국 어떤 유전자가 얼마나 켜져 있는지의 문제라서, 그걸 숫자로 확인해
보는 게 rna-seq입니다.

bulk rna-seq은 조직/샘플에 있는 세포들을 다 섞어서 평균 발현량을 보는 방식이고 (지금
하는 게 이거), single-cell은 세포 하나하나를 따로 봐서 세포 간 차이까지 잡아내는
방식입니다. bulk가 더 저렴하고 오래된 방법이고, single-cell이 더 세밀하지만 비용이
더 듭니다.

## RNA-seq 분석 종류 정리

지금 하는 건 발현량 비교(1번)고 이게 제일 기본. 나머지는 여기서 확장되는 것들.

**1. 발현량 비교 (진행중)**
- differential expression - 그룹 간 발현차이. DESeq2/edgeR/limma-voom
- time-course - 시간별 발현 변화

**2. 전사체 구조**
- alternative splicing (rMATS, LeafCutter) - star가 이미 spliced alignment라 확장 가능할듯
- isoform/transcript 단위 정량 (salmon, kallisto)
- fusion gene (STAR-Fusion) - 암쪽에서 많이 씀
- RNA editing

**3. 세포/공간**
- single-cell (Seurat, Scanpy) - bulk는 평균이라 이질성 못 봄
- spatial transcriptomics
- RNA velocity

**4. 변이 연계**
- eQTL - 유전형이랑 발현량 연관
- allele-specific expression
- rna-seq으로 variant calling

**5. 특수 RNA**
- miRNA-seq
- circRNA
- Ribo-seq - 실제 번역중인 부분만

**6. 통합분석**
- GSEA/pathway - 다음에 자연스럽게 이어질 듯
- co-expression network (WGCNA)
- multi-omics 통합
