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
for INTERVAL in $2
do
    if [ $count -le $JOB ]
    then
        nohup /usr/bin/java $MEMx -Djava.io.tmpdir=$TMP -DGATK_STACKTRACE_ON_USER_EXCEPTION=true \
        -jar $GATK4 GenomicsDBImport \
        --tmp-dir ${TMP} \
        --sample-name-map /data2/yycho/JY_Calling_v5/GenomicsDBImport_sample_map.txt \
        --genomicsdb-workspace-path $RESP/GenomicDBImport_Test_${INTERVAL} \
        --reference ${Reffile} \
        --reader-threads 5 \
        --batch-size 10 \
        --max-num-intervals-to-import-in-parallel 4 \
        --intervals ${INTERVAL}    
        1> $RESP/GenomicsDBImport_${INTERVAL}.log 2> $RESP/GenomicsDBImport_${INTERVAL}.err &

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait


count=1
for INTERVAL in $2
do
    if [ $count -le $JOB ]
    then
wait
       nohup /usr/bin/java $MEMx -Djava.io.tmpdir=$TMP -DGATK_STACKTRACE_ON_USER_EXCEPTION=true \
       -jar ${GATK4} GenotypeGVCFs \
       --tmp-dir ${TMP} \
       --variant gendb://$RESP/GenomicDBImport_Test_${INTERVAL} \
       --output $RESP/cohort2781.${INTERVAL}.vcf \
       --reference ${Reffile} \
       --create-output-bam-index true \
       --create-output-bam-md5 true \
       --create-output-variant-index false \
       --sequence-dictionary ${Dictfile} \
       --max-alternate-alleles 6 
       1> $RESP/cohort2781.${INTERVAL}.vcf.log 2> $RESP/cohort2781.${INTERVAL}.vcf.err &

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait
echo "GenomicDBImport_Test_${INTERVAL} finished"
