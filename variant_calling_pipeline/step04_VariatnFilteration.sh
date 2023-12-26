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
        -jar $GATK4 VariantFiltration \
        --tmp-dir ${TMP} \
        --variant $RESP/cohort.${CHR}.vcf   \
        --output $RESP/cohort.${CHR}.VF.vcf \
        --filter-name LowReadPosRankSum --filter-expression "ReadPosRankSum < -2.0" \
        --filter-name LowMQRankSum --filter-expression "MQRankSum < -2.0" \
        --filter-name LowQual --filter-expression "QUAL < 30.0" \
        --filter-name QD --filter-expression "QD < 3.0" \
        --filter-name FS --filter-expression "FS > 30.0" \
        --filter-name SOR --filter-expression "SOR > 3.0" \
        --filter-name MQ --filter-expression "MQ < 40.0" \
        --filter-name DP0 --filter-expression "DP < 7" \
        --genotype-filter-name DP --genotype-filter-expression "DP < 7" \
        --genotype-filter-name GQ --genotype-filter-expression "GQ < 20.0" \
        --reference ${Reffile} \
        1> $RESP/cohort.${CHR}.VF.vcf.log 2> $RESP/cohort.${CHR}.VF.vcf.err &

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait
