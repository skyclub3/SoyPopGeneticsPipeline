#!/bin/bash



############################################################################################
#(0) step00 : Preperation
workpath=/data2/yycho/JY_Calling_v5
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
MEM=8g
MEMx=-Xmx${MEM}
JOB=1
TMP=`pwd`/tmp
############################################################################################


TMPDIR=./tmp${RANDOM}
if [ ! -e ${TMPDIR} ]
then
    mkdir ${TMPDIR}
fi


count=1
for CHR in 10
do
    if [ $count -le $JOB ]
    then
wait
       nohup /usr/bin/java $MEMx -Djava.io.tmpdir=$TMP -DGATK_STACKTRACE_ON_USER_EXCEPTION=true \
       -jar ${GATK4} GatherVcfs \
       --TMP_DIR ${TMPDIR}  \
       --INPUT $RESP/cohort.Gm01.VF.SNP.vcf.gz  \
       --INPUT $RESP/cohort.Gm02.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm03.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm04.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm05.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm06.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm07.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm08.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm09.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm10.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm11.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm12.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm13.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm14.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm15.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm16.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm17.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm18.VF.SNP.vcf.gz  \
       --INPUT $RESP/cohort.Gm19.VF.SNP.vcf.gz   \
       --INPUT $RESP/cohort.Gm20.VF.SNP.vcf.gz   \
       --OUTPUT $RESP/cohort.ALL.VF.SNP.vcf.gz  \
       --REFERENCE_SEQUENCE ${Reffile} \
       1> $RESP/cohort.ALL.VF.SNP.vcf.gz.log  &


    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
echo done
