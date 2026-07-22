# rnaseq-lab

rna-seq 이것저것 해보는 곳. 하나 끝날 때마다 폴더 추가하는 식으로.

```
rnaseq-lab/
├── airway_de_rnaseq/   # 첫번째 - airway dex, star+deseq2
└── ...
```

## rna-seq이 뭐냐면

세포에서 어떤 유전자가 얼마나 켜져있는지 mRNA 시퀀싱해서 보는 거.
DNA는 다 똑같은데 뭘 켜고 끄는지가 세포/조직마다 다르니까 그걸 정량화하는 거임.
bulk면 세포 다 섞어서 평균, single-cell이면 세포 하나하나.

## 종류가 많던데 정리

지금 하는 건 발현량 비교(1번)고 이게 제일 기본. 나머지는 여기서 확장되는 것들.

**1. 발현량 비교 (지금 함)**
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

## 계획

일단 airway로 기본 DE 파이프라인 손에 익히기.
그 다음은 GSEA로 가거나, star가 spliced alignment니까 splicing 쪽으로 가거나 둘 중 하나.
나머지는 그때그때 봐가면서.
