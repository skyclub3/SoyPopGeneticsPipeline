#!~/bin/env bash
# Version 5.0
# 26 FEB 2021 by JY


if [ $# -eq 5 ]
then
    echo "##################################################################"
    echo "START" $0
    echo "##################################################################"
else
    echo "##################################################################"
    echo "Usage : [Path_source] [Sample_name] [Threads: 3] [Memory: 10g] [Suffix: fastq.gz or fq.gz]"
    echo "##################################################################"
    exit
fi


############################################################################################
#(0) step00 : Preperation

SOR=$1
source $SOR
CPU=$3
MEM=$4
MEMx=-Xmx${MEM}
SUFFIX=$5
JOB=1

############################################################################################
echo ""
echo ""
echo ""
echo "##################################################################"
date
echo "Command :" $0 $*
echo "##################################################################"
echo ""
echo "##################################################################"
echo "GATK Start from the mapping to Haplotype caller"
echo "Outfolder :" $RESP 
echo "##################################################################"

#############################################################################################
#(1) step01 : BWA mapping
echo ""
echo ""
echo ""
echo "##################################################################"
date
echo "Step01: BWA mapping"
echo "Each Thread :" $CPU
echo "Each Memory :" $MEM

count=1
for sample in $2
do
    if [ $count -le $JOB ]
    then
        echo ""
        echo -e "Sample name: $sample"
        echo -e "Command:"
        echo ""
        echo -e "$BWA mem -M -t $CPU $Reffile $READ/${sample}_1.$SUFFIX $READ/${sample}_2.$SUFFIX 
                   2> $RESP/${sample}.mapping.err
                   | $SAMTOOLS view -@ $CPU -bS --no-PG - 
                   1> $RESP/${sample}.bam 
                   2> $RESP/${sample}.bam.err"
        nohup $BWA mem -M -t $CPU $Reffile $READ/${sample}_1.$SUFFIX $READ/${sample}_2.$SUFFIX \
                   2> $RESP/${sample}.mapping.log \
                   | $SAMTOOLS view -@ $CPU -bS --no-PG - \
                   1> $RESP/${sample}.bam \
                   2> $RESP/${sample}.bam.err &
        if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait 

echo ""
echo ""
echo ""
echo "##################################################################"
date
echo "Step02: Read group"
echo "Each Thread :" $CPU
echo "Each Memory :" $MEM

count=1
for sample in $2
do
    if [ $count -le $JOB ]
    then
        echo ""
        echo -e "Sample name: $sample"
        echo -e "Command:"
        echo ""
        echo -e "/usr/bin/java $MEMx -Djava.io.tmpdir=$TMP 
        -jar $GATK4 AddOrReplaceReadGroups 
        --INPUT $RESP/${sample}.bam 
        --OUTPUT $RESP/${sample}.sorted.bam 
        --RGLB $sample 
        --RGPL ILLUMINA 
        --RGPU NONE 
        --RGSM $sample 
        --RGID $sample 
        --SORT_ORDER coordinate 
        --REFERENCE_SEQUENCE $Reffile 
        1> $RESP/${sample}.sorted.log 2> $RESP/${sample}.sroted.err"

        nohup /usr/bin/java $MEMx -Djava.io.tmpdir=$TMP \
        -jar $GATK4 AddOrReplaceReadGroups \
        --INPUT $RESP/${sample}.bam \
        --OUTPUT $RESP/${sample}.sorted.bam \
        --RGLB $sample \
        --RGPL ILLUMINA \
        --RGPU NONE \
        --RGSM $sample \
        --RGID $sample \
        --SORT_ORDER coordinate \
        --REFERENCE_SEQUENCE $Reffile \
        1> $RESP/${sample}.sorted.log 2> $RESP/${sample}.sroted.err &

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait


echo ""
echo ""
echo ""
echo "##################################################################"
date
echo "Step03: Mark dup"
echo "Each Thread :" $CPU
echo "Each Memory :" $MEM

count=1
for sample in $2
do
    if [ $count -le $JOB ]
    then
        echo ""
        echo -e "Sample name: $sample"
        echo -e "Command:"
        echo ""
        echo -e "/usr/bin/java $MEMx -Djava.io.tmpdir=$TMP 
        -jar $GATK4 MarkDuplicates 
        --INPUT $RESP/${sample}.sorted.bam 
        --METRICS_FILE $RESP/${sample}.sorted.markduplicates.metrics.txt 
        --OUTPUT $RESP/${sample}.sorted.markduplicates.bam 
        --ASSUME_SORTED true 
        --MAX_FILE_HANDLES_FOR_READ_ENDS_MAP 1024 
        --REFERENCE_SEQUENCE $Reffile 
        1> $RESP/${sample}.sorted.markduplicates.log 2> $RESP/${sample}.sorted.markduplicates.err"

        nohup /usr/bin/java $MEMx -Djava.io.tmpdir=$TMP \
        -jar $GATK4 MarkDuplicates \
        --INPUT $RESP/${sample}.sorted.bam \
        --METRICS_FILE $RESP/${sample}.sorted.markduplicates.metrics.txt \
        --OUTPUT $RESP/${sample}.sorted.markduplicates.bam \
        --ASSUME_SORTED true \
        --MAX_FILE_HANDLES_FOR_READ_ENDS_MAP 1024 \
        --REFERENCE_SEQUENCE $Reffile \
        1> $RESP/${sample}.sorted.markduplicates.log 2> $RESP/${sample}.sorted.markduplicates.err &
    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait



echo ""
echo ""
echo ""
echo "##################################################################"
date
echo "Step04: Fix mate"
echo "Each Thread :" $CPU
echo "Each Memory :" $MEM

count=1
for sample in $2
do
    if [ $count -le $JOB ]
    then
        echo ""
        echo -e "Sample name: $sample"
        echo -e "Command:"
        echo ""

        echo -e "/usr/bin/java $MEMx -Djava.io.tmpdir=$TMP 
        -jar $GATK4 FixMateInformation 
        --INPUT $RESP/${sample}.sorted.markduplicates.bam 
        --OUTPUT $RESP/${sample}.sorted.markduplicates.fixmate.bam 
        --ADD_MATE_CIGAR true 
        --ASSUME_SORTED true 
        --REFERENCE_SEQUENCE $Reffile  
        1> $RESP/${sample}.sorted.markduplicates.fixmate.log 2> $RESP/${sample}.sorted.markduplicates.fixmate.err"

        nohup /usr/bin/java $MEMx -Djava.io.tmpdir=$TMP \
        -jar $GATK4 FixMateInformation \
        --INPUT $RESP/${sample}.sorted.markduplicates.bam \
        --OUTPUT $RESP/${sample}.sorted.markduplicates.fixmate.bam \
        --ADD_MATE_CIGAR true \
        --ASSUME_SORTED true \
        --REFERENCE_SEQUENCE $Reffile \
        1> $RESP/${sample}.sorted.markduplicates.fixmate.log 2> $RESP/${sample}.sorted.markduplicates.fixmate.err &
    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait



echo ""
echo ""
echo ""
echo "##################################################################"
date
echo "Step05: BQSR"
echo "Each Thread :" $CPU
echo "Each Memory :" $MEM

count=1
for sample in $2
do
    if [ $count -le $JOB ]
    then
        echo ""
        echo -e "Sample name: $sample"
        echo -e "Command:"
        echo ""

        echo -e "/usr/bin/java $MEMx  
        -jar $GATK4 BaseRecalibrator 
        --tmp-dir $TMP 
        --input $RESP/${sample}.sorted.markduplicates.fixmate.bam 
        --output $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.tbl 
        --reference $Reffile 
        --known-sites $Sitefile 
        1> $RESP/${sample}.sorted.markduplicates.fixmate.BQSRtbl.log 2> $RESP/${sample}.sorted.markduplicates.fixmate.BQSRtbl.err"

        nohup /usr/bin/java $MEMx \
        -jar $GATK4 BaseRecalibrator \
        --tmp-dir $TMP \
        --input $RESP/${sample}.sorted.markduplicates.fixmate.bam \
        --output $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.tbl \
        --reference $Reffile \
        --known-sites $Sitefile \
        1> $RESP/${sample}.sorted.markduplicates.fixmate.BQSRtbl.log \
        2> $RESP/${sample}.sorted.markduplicates.fixmate.BQSRtbl.err &

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait



echo ""
echo ""
echo ""
echo "##################################################################"
date
echo "Step06: Apply BQSR"
echo "Each Thread :" $CPU
echo "Each Memory :" $MEM

count=1
for sample in $2
do
    if [ $count -le $JOB ]
    then
        echo ""
        echo -e "Sample name: $sample"
        echo -e "Command:"
        echo ""

        echo -e "/usr/bin/java $MEMx  
        -jar /$GATK4 
        ApplyBQSR 
        --tmp-dir $TMP 
        --bqsr-recal-file $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.tbl 
        --input $RESP/${sample}.sorted.markduplicates.fixmate.bam 
        --output $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.bam 
        --reference $Reffile  
        1> $RESP/${sample}.sorted.markduplicates.fixmate.BQSRappl.log 
        2> $RESP/${sample}.sorted.markduplicates.fixmate.BQSRappl.err"

        nohup /usr/bin/java $MEMx \
        -jar /$GATK4 \
        ApplyBQSR \
        --tmp-dir $TMP \
        --bqsr-recal-file $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.tbl \
        --input $RESP/${sample}.sorted.markduplicates.fixmate.bam \
        --output $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.bam \
        --reference $Reffile \
        1> $RESP/${sample}.sorted.markduplicates.fixmate.BQSRappl.log \
        2> $RESP/${sample}.sorted.markduplicates.fixmate.BQSRappl.err &

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait



echo ""
echo ""
echo ""
echo "##################################################################"
date
echo "Step07: Realin target"
echo "Each Thread :" $CPU
echo "Each Memory :" $MEM

count=1
for sample in $2
do
    if [ $count -le $JOB ]
    then
        echo ""
        echo -e "Sample name: $sample"
        echo -e "Command:"
        echo ""

        echo -e "/usr/bin/java $MEMx -Djava.io.tmpdir=$TMP  
        -jar $GATK3 
        -T RealignerTargetCreator 
        -R $Reffile 
        -nt 3 
        -I $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.bam  
        -o $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.intervals 
        1> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.intervals.log  
        2> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.intervals.err"

        nohup /usr/bin/java $MEMx -Djava.io.tmpdir=$TMP  \
        -jar $GATK3 \
        -T RealignerTargetCreator \
        -R $Reffile \
        -nt 3 \
        -I $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.bam  \
        -o $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.intervals \
        1> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.intervals.log \
        2> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.intervals.err &

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait



echo ""
echo ""
echo ""
echo "##################################################################"
date
echo "Step08: Indel Realign"
echo "Each Thread :" $CPU
echo "Each Memory :" $MEM

count=1
for sample in $2
do
    if [ $count -le $JOB ]
    then
        echo ""
        echo -e "Sample name: $sample"
        echo -e "Command:"
        echo ""

        echo -e "/usr/bin/java $MEMx -Djava.io.tmpdir=$TMP  
        -jar $GATK3  
        -T IndelRealigner 
        -R $Reffile 
        -targetIntervals $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.intervals 
        -I  $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.bam 
        -o  $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.bam 
        1> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.log 
        2> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.err"

        nohup /usr/bin/java $MEMx -Djava.io.tmpdir=$TMP  \
        -jar $GATK3  \
        -T IndelRealigner \
        -R $Reffile \
        -targetIntervals $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.intervals \
        -I  $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.bam \
        -o  $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.bam \
        1> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.log \
        2> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.err &

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait


echo ""
echo ""
echo ""
echo "##################################################################"
date
echo "Step09: Depth of Coverage"
echo "Each Thread :" $CPU
echo "Each Memory :" $MEM

count=1
for sample in $2
do
    if [ $count -le $JOB ]
    then
        echo ""
        echo -e "Sample name: $sample"
        echo -e "Command:"
        echo ""

        echo -e "/usr/bin/java $MEMx -Djava.io.tmpdir=$TMP 
        -jar $GATK3  
        -T DepthOfCoverage 
        -R $Reffile 
        -nt $CPU
        -ct 1 
        -ct 5 
        -ct 10 
        -ct 20 
        --omitDepthOutputAtEachBase 
        --omitIntervalStatistics 
        --omitLocusTable 
        -rf BadCigar 
        -I $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.bam 
        -o $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.DOC 
        1> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.DOC.log 
        2> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.DOC.err"

        nohup /usr/bin/java $MEMx -Djava.io.tmpdir=$TMP \
        -jar $GATK3  \
        -T DepthOfCoverage \
        -R $Reffile \
        -nt $CPU \
        -ct 1 \
        -ct 5 \
        -ct 10 \
        -ct 20 \
        --omitDepthOutputAtEachBase \
        --omitIntervalStatistics \
        --omitLocusTable \
        -rf BadCigar \
        -I $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.bam \
        -o $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.DOC \
        1> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.DOC.log \
        2> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.DOC.err &

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait



echo ""
echo ""
echo ""
echo "##################################################################"
date
echo "Step10: Haplotype caller"
echo "Each Thread :" $CPU
echo "Each Memory :" $MEM

count=1
for sample in $2
do
    if [ $count -le $JOB ]
    then
        echo ""
        echo -e "Sample name: $sample"
        echo -e "Command:"
        echo ""

        echo -e "/usr/bin/java $MEMx  
        -jar $GATK4 HaplotypeCaller 
        --tmp-dir $TMP 
        --reference $Reffile 
        --input $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.bam 
        --output $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf 
        --max-alternate-alleles 6 
        --native-pair-hmm-threads 4 
        --dbsnp $Sitefile 
        --emit-ref-confidence GVCF 
        1> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf.log 
        2> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf.err"

        nohup /usr/bin/java $MEMx \
        -jar $GATK4 HaplotypeCaller \
        --tmp-dir $TMP \
        --reference $Reffile \
        --input $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.bam \
        --output $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf \
        --max-alternate-alleles 6 \
        --native-pair-hmm-threads 4 \
        --dbsnp $Sitefile \
        --emit-ref-confidence GVCF \
        1> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf.log \
        2> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf.err &

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait



echo ""
echo ""
echo ""
echo "##################################################################"
date
echo "Step11: Compression"

count=1
for sample in $2
do
    if [ $count -le $JOB ]
    then
        echo ""
        echo -e "Sample name: $sample"
        echo -e "Command:"
        echo ""

        echo -e "$BGZIP $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf 
        >& $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf.gz.err"

        nohup $BGZIP -c $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf \
        1> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf.gz \
        2> $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf.gz.err &

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait



echo ""
echo ""
echo ""
echo "##################################################################"
date
echo "Step12: Tabix"

count=1
for sample in $2
do
    if [ $count -le $JOB ]
    then
        echo ""
        echo -e "Sample name: $sample"
        echo -e "Command:"
        echo ""

        echo -e "$TABIX -p vcf $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf.gz 
        >& $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf.gz.tabix.err"

        nohup $TABIX -p vcf $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf.gz \
        >& $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf.gz.tabix.err &

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait


echo ""
echo ""
echo ""
echo "##################################################################"
date
echo "Step13: Remove intermediate files"

count=1
for sample in $2
do
    if [ $count -le $JOB ]
    then
        echo ""
        echo -e "Sample name: $sample"
        echo -e "Command:"
        echo ""

        echo -e "
        rm -f $RESP/${sample}.bam 
        rm -f $RESP/${sample}.sorted.bam
        rm -f $RESP/${sample}.sorted.markduplicates.bam
        rm -f $RESP/${sample}.sorted.markduplicates.fixmate.bam
        rm -f $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.bam
        rm -f $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf"

        rm -f $RESP/${sample}.bam 
        rm -f $RESP/${sample}.sorted.bam
        rm -f $RESP/${sample}.sorted.markduplicates.bam
        rm -f $RESP/${sample}.sorted.markduplicates.fixmate.bam
        rm -f $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.bam 
        rm -f $RESP/${sample}.sorted.markduplicates.fixmate.BQSR.realigned.g.vcf

    if [ $count -eq $JOB ]
        then
            count=0
            wait
        fi
        count=`expr $count + 1`
    fi
done
wait

echo ""
echo ""
echo ""
echo "##################################################################"
echo "All steps were done"
date
echo "##################################################################"
echo ""
echo ""

##############################################################################################
