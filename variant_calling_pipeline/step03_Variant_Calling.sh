#!~/bin/env bash

if [ $# -eq 5 ]
then
    echo "START" $0
else
    echo ""
    echo "Usage : sh $0  [Sample_directory]  [Sample_suffix: fastq.gz or fq.gz]  [# of Jobs]  [Threads]  [Memory: 15g]"
    echo ""
    exit
fi

############################################################################################
#(0) step00 : Preperation

Sdir=$1
CPU=$4
JOB=$3
MEM=$5
SUFFIX=$2

BWA=./src/bwa-0.7.12/bwa
PICARD=./src/picard.jar
GATK=./src/GenomeAnalysisTK.jar
BGZIP=./src/htslib-1.3.1/bgzip
TABIX=./src/htslib-1.3.1/tabix
SAMTOOL=./src/samtools-1.3.1/samtools

REF_BWA=./Reference/hg38_example.fa
KnownSites=./Annotations/All_20160407_example.vcf

mkdir JAVA_tmp
mkdir Results

WORKDIR=$(pwd)
JAVA_TMP=$WORKDIR"/JAVA_tmp"
RESULTDIR=$WORKDIR"/Results"

ls $Sdir/*$SUFFIX | cut -d '_' -f 1 | uniq > $RESULTDIR/sample.list.txt
Slist=$RESULTDIR/sample.list.txt

#############################################################################################
#(1) step01 : BWA mapping

echo "Step01: BWA mapping"
echo "Threads :" $CPU

count=1
for sample_dir in $(cat $Slist)
do
    if [ $count -le $JOB ]
    then
        sample=$(basename $sample_dir)
        echo $sample
        nohup $BWA mem -M -t $CPU $REF_BWA ${sample_dir}_1.$SUFFIX ${sample_dir}_2.$SUFFIX \
                   2> $RESULTDIR/${sample}.bwa.sam.log \
                   | $SAMTOOL view -bS - \
                   1> $RESULTDIR/${sample}.bwa.bam \
                   2> $RESULTDIR/${sample}.bwa.bam.log &
        if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait 

echo "Step01: Done"

##############################################################################################
#(2) step02 : Picards

echo "Step02 : Picards"
echo "Step02-1 : AddOrReplaceReadGroups"

count=1
for sample_dir in $(cat $Slist)
do
    if [ $count -le $JOB ]
    then
        sample=$(basename $sample_dir)
        echo $sample
        outfiled=${sample}.bwa.bam
        nohup java -Xmx$MEM -jar $PICARD AddOrReplaceReadGroups \
            INPUT=$RESULTDIR/$outfiled \
            OUTPUT=$RESULTDIR/${sample}.RGsorted.bam \
            SORT_ORDER=coordinate \
            RGID=${sample} \
            RGLB=${sample}.LIB \
            RGPL=ILLUMINA \
            RGPU=NONE \
            RGSM=${sample} \
            VALIDATION_STRINGENCY=SILENT \
            MAX_RECORDS_IN_RAM=1280000 \
            >& $RESULTDIR/${sample}.RGsorted.bam.log &

        if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait
echo "Step02-1 : DONE"
echo "Step02-2 : Mark Duplicates"

count=1
for sample_dir in $(cat $Slist)
do
    if [ $count -le $JOB ]
    then
        sample=$(basename $sample_dir)
        echo $sample
        nohup java -Xmx$MEM -jar $PICARD MarkDuplicates \
            INPUT=$RESULTDIR/${sample}.RGsorted.bam \
            OUTPUT=$RESULTDIR/${sample}.RGsorted.dedup.bam \
            METRICS_FILE=$RESULTDIR/${sample}.RGsorted.dedup.metrics \
            REMOVE_DUPLICATES=true \
            ASSUME_SORTED=true \
            VALIDATION_STRINGENCY=SILENT \
            MAX_FILE_HANDLES=1024 \
            MAX_RECORDS_IN_RAM=1280000 \
            >& $RESULTDIR/${sample}.RGsorted.dedup.bam.log &
        if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait

echo "Step02-3 : Samtools Flag stats"
count=1
for sample_dir in $(cat $Slist)
do
    if [ $count -le $JOB ]
    then
        sample=$(basename $sample_dir)
        echo $sample
        nohup $SAMTOOL flagstat $RESULTDIR/${sample}.RGsorted.dedup.bam \
              1> $RESULTDIR/${sample}.RGsorted.dedup.bam.flagstat &
        if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait

echo "Step02-3 : DONE"
echo "Step02: ALL Done"

####################################################################################
#(3) Depth of coverage

echo "Step03 : Depth of coverage"
echo "Each Memory :" $MEM

count=1
for sample_dir in $(cat $Slist)
do
    if [ $count -le $JOB ]
    then
        sample=$(basename $sample_dir)
        echo $sample indexing
        $SAMTOOL index $RESULTDIR/${sample}.RGsorted.dedup.bam 
        nohup java -Djava.io.tmpdir=${JAVA_TMP} -Xmx${MEM} \
                   -jar $GATK \
                   -T DepthOfCoverage \
                   -R ${REF_BWA} \
                   -I $RESULTDIR/${sample}.RGsorted.dedup.bam \
                   -o $RESULTDIR/${sample}.RGsorted.dedup.depth \
                   -nt ${CPU} \
                   -ct 1 \
                   -ct 5 \
                   -ct 10 \
                   -ct 20 \
                   --omitDepthOutputAtEachBase \
                   --omitIntervalStatistics \
                   --omitLocusTable \
                   -rf BadCigar \
                   >& $RESULTDIR/${sample}.RGsorted.dedup.depth.log &
        if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait
echo "Step03 : DONE"


#####################################################################################
#(4) step04 : Recalibration

echo "Step04 : Recalibration"
if [ $KnownSites ]
then
    echo "Known Sites Eixts"
    echo "Starting Recalibration"
    exist=1
else
    echo "Known Sites not Eixts"
    echo "Skip step03 : Recalibrartion"
fi

if [ $exist ]
then 
    count=1
    for sample_dir in $(cat $Slist)
    do
        if [ $count -le $JOB ]
        then
            sample=$(basename $sample_dir)
            echo $sample indexing
            $SAMTOOL index $RESULTDIR/${sample}.RGsorted.dedup.bam \ 
            nohup java -Xmx$MEM -jar $GATK \
                -T BaseRecalibrator \
                -I $RESULTDIR/${sample}.RGsorted.dedup.bam \
                -R $REF_BWA \
                -knownSites $KnownSites \
                -o $RESULTDIR/${sample}.RGsorted.dedup.recal.grp \
                >& $RESULTDIR/${sample}.RGsorted.dedup.recal.grp.log &
            if [ $count -eq $JOB ]
            then
                count=0
                wait
            fi
            count=`expr $count + 1`
        fi
    done
fi
wait

if [ $exist ]
then
    count=1
    for sample_dir in $(cat $Slist)
    do
        if [ $count -le $JOB ]
        then
            sample=$(basename $sample_dir)
            nohup java -Xmx$MEM -jar $GATK \
                -T PrintReads \
                -I $RESULTDIR/${sample}.RGsorted.dedup.bam \
                -R $REF_BWA \
                -BQSR $RESULTDIR/${sample}.RGsorted.dedup.recal.grp \
                -o $RESULTDIR/${sample}.RGsorted.dedup.recal.bam \
                >& $RESULTDIR/${sample}.RGsorted.dedup.recal.bam.log &
            if [ $count -eq $JOB ]
            then
                count=0
                wait
            fi
            count=`expr $count + 1`
        fi
    done
fi
wait

echo "Step04: Done"

####################################################################################
#(5)Step05 : Indel Realingn

echo "Step05 : Indel Realingn"
echo "Step05-1 : Target Creator"
echo "Each memory : " $MEM

if [ $exits ]
then
    sufix=RGsorted.dedup.recal
else
    sufix=RGsorted.dedup
fi

count=1
for sample_dir in $(cat $Slist)
do
    if [ $count -le $JOB ]
    then
        sample=$(basename $sample_dir)
        echo $sample indexing
        $SAMTOOL index $RESULTDIR/${sample}.${sufix}.bam
        nohup java -Djava.io.tmpdir=${JAVA_TMP} -Xmx$MEM \
            -jar $GATK \
            -T RealignerTargetCreator \
            -I $RESULTDIR/${sample}.${sufix}.bam \
            -R $REF_BWA \
            -nt $CPU \
            -o $RESULTDIR/${sample}.${sufix}.intervals \
            >& $RESULTDIR/${sample}.${sufix}.intervals.log &
        if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait

echo "Step05-1 DONE"
echo "Step05-2 Indel Realign"

count=1
for sample_dir in $(cat $Slist)
do
    if [ $count -le $JOB ]
    then
        sample=$(basename $sample_dir)
        echo $sample
        nohup java -Xmx$MEM -Djava.io.tmpdir=$JAVA_TMP \
            -jar $GATK \
            -T IndelRealigner \
            -I $RESULTDIR/${sample}.${sufix}.bam \
            -R $REF_BWA \
            -targetIntervals $RESULTDIR/${sample}.${sufix}.intervals \
            -o $RESULTDIR/${sample}.${sufix}.realigned.bam \
            >& $RESULTDIR/${sample}.${sufix}.realigned.log &
        if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait

echo "Step05-2 DONE"
echo "Step05 ALL DONE"

###################################################################################
#(6) Haplotype caller

echo "Step06 Haplotype Caller"

if [ $KnownSites ]
then
    echo "Known Sites Eixts"
    echo "Starting Haplotype Caller with KnownSites" $KnownSites
    exist=1
else
    echo "Known Sites not Eixts"
    echo "Starting Haplotype Caller without KnownSites"
fi

if [ $exist ]
then
    echo "Making GVCF"
    count=1
    for sample_dir in $(cat $Slist)
    do
        if [ $count -le $JOB ]
        then
            sample=$(basename $sample_dir)
            echo $sample
            nohup java -Xmx$MEM -Djava.io.tmpdir=$JAVA_TMP \
                -jar $GATK \
                -T HaplotypeCaller \
                -I $RESULTDIR/${sample}.${sufix}.realigned.bam \
                --dbsnp $KnownSites \
                -R $REF_BWA \
                -o $RESULTDIR/${sample}.${sufix}.realigned.g.vcf \
                --emitRefConfidence GVCF \
	        --variant_index_type LINEAR \
	        --variant_index_parameter 128000 \
                >& $RESULTDIR/${sample}.${sufix}.realigned.g.vcf.log &
            if [ $count -eq $JOB ]
            then
                count=0
                wait
            fi
            count=`expr $count + 1`
        fi
    done
else
    echo "Making GVCF"
    count=1
    for sample_dir in $(cat $Slist)
    do
        if [ $count -le $JOB ]
        then
            sample=$(basename $sample_dir)
            echo $sample
            nohup java -Xmx$MEM -Djava.io.tmpdir=$JAVA_TMP \
                -jar $GATK \
                -T HaplotypeCaller \
                -I $RESULTDIR/${sample}.${sufix}.realigned.bam \
                --dbsnp $KnownSites \
                -R $REF_BWA \
                -o $RESULTDIR/${sample}.${sufix}.realigned.g.vcf \
                --variant_index_type LINEAR \
                --variant_index_parameter 128000 \
                >& $RESULTDIR/${sample}.${sufix}.realigned.g.vcf.log &
            if [ $count -eq $JOB ]
            then
                count=0
                wait
            fi
            count=`expr $count + 1`
        fi
    done
fi
wait

echo "Step06 DONE"
echo "Calling DONE"
######################################################################################
