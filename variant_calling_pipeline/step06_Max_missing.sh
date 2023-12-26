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
INTERVAL=$2
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
        nohup vcftools --vcf ${RESP}/cohort.${CHR}.VF.SNP.vcf --max-missing 0.15 --recode --out ${RESP}/cohort.${CHR}.VF.SNP.MISS15 &

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait
