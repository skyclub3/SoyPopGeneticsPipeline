#!/bin/bash



############################################################################################
#(0) step00 : Preperation

SOR=$1
source $SOR
CPU=$3
MEM=$4
MEMx=-Xmx${MEM}
SUFFIX=$5
JOB=1
TMP=`pwd`/tmp
BEAGLE=/data2/yycho/git
############################################################################################



if [ ! -e ${TMP} ]
then
    mkdir ${TMP}
fi


count=1
for CHR  in $2
do
    if [ $count -le $JOB ]
    then
        cat $RESP/cohort.${CHR}.VF.SNP.MISS15.recode.vcf.gz | perl -pe "s/\s\.:/\t.\/.:/g" | bgzip -c > $RESP/cohort.${CHR}.VF.SNP.MISS15.Trim.vcf.gz
        wait
        bcftools annotate -x ^FORMAT/GT $RESP/cohort.${CHR}.VF.SNP.MISS15.Trim.vcf.gz > $RESP/cohort.${CHR}.VF.SNP.MISS15.Trim.GT.vcf
        wait
        bcftools view -m2 -M2 -v snps $RESP/cohort.${CHR}.VF.SNP.MISS15.Trim.GT.vcf > $RESP/cohort.${CHR}.VF.SNP.MISS15.Trim.GT.BI.vcf
        wait
        #zcat $RESP/cohort.${CHR}.VF.SNP.MISS15.Trim.vcf.gz | cut -f1-2790 | tr '/' '|' | bgzip -c  > $RESP/cohort.${CHR}.VF.SNP.MISS15.Trim.phased.vcf.gz
        #wait
        nohup /usr/bin/java $MEMx -Djava.io.tmpdir=$TMP  \
        -jar  ${BEAGLE}/beagle.29May21.d6d.jar  \
        gt=$RESP/cohort.${CHR}.VF.SNP.MISS15.Trim.GT.BI.vcf \
        out=$RESP/cohort.${CHR}.VF.SNP.MISS15.Trim.GT.BI.BEAGLE \
        1> $RESP/cohort.${CHR}.VF.SNP.MISS15.Trim.GT.BI.BEAGLE.vcf.log 2> $RESP/cohort.${CHR}.VF.SNP.MISS15.Trim.GT.BI.BEAGLE.vcf.err &
    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait
