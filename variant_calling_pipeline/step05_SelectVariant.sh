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
#INTERVAL=/data2/yycho/Results/SOY/JY_Calling_v5/gReference/GenomicDBimport.intervals
############################################################################################
# OPTION DELETED DUE TO ERROR: -Djava.io.tmpdir=./tmp${RANDOM}



if [ ! -e ${TMP} ]
then
    mkdir ${TMP}
fi


count=1
for CHR  in $2
do
    if [ $count -le $JOB ]
    then
        nohup /usr/bin/java $MEMx -Djava.io.tmpdir=$TMP -DGATK_STACKTRACE_ON_USER_EXCEPTION=true \
        -jar $GATK4 SelectVariants \
        --tmp-dir ${TMP} \
        --variant $RESP/cohort.${CHR}.VF.vcf   \
        --output $RESP/cohort.${CHR}.VF.SNP.vcf \
        --exclude-filtered true \
        --exclude-non-variants true \
        --set-filtered-gt-to-nocall  true \
        --select-type-to-include SNP \
        --reference ${Reffile} \
        1> $RESP/cohort.${CHR}.VF.SNP.vcf.log 2> $RESP/cohort.${CHR}.VF.SNP.vcf.err &

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait
