#!~/bin/env bash

workpath=/data2/yycho/git
softpath=${workpath}/opt/src_packages

READ=$workpath/gResults/GatherVcfs
RESP=$workpath//gResults/GatherVcfs
TMP=$workpath/tmp
REF=$workpath/gReference
ANOT=$workpath/gAnnotation

Reffile=$REF/Gmax_508_v4.0.softmasked_PltdMT.fasta
Dictfile=$REF/Gmax_508_v4.0.softmasked_PltdMT.dict
Sitefile=$ANOT/GCA_000004515.3_liftOver_Gmax_508_v4.0.vcf.gz
Intervalfile=$REF/Gmax_508_v4.0.softmasked_PltdMT.intervals
Annotfield=$ANOT/glycinemax_annotation_fields.lst
Snpfield=$ANOT/snpEff_effectFields.txt
Snpannot=$ANOT/SnpSift_annotation.lst

BWA=$softpath/bwa-0.7.17/bwa
SAMTOOLS=$softpath/samtools-1.10/samtools
BCFTOOLS=$softpath/bcftools-1.10.2/bcftools
TABIX=$softpath/htslib-1.10.2/tabix
BGZIP=$softpath/htslib-1.10.2/bgzip
SNPSIFT=$softpath/snpEff/SnpSift.jar
SNPEFF=$softpath/snpEff/snpEff.jar
GATK3=$softpath/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar
GATK4=$softpath/gatk-4.1.8.1/gatk-package-4.1.8.1-local.jar

