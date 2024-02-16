#!~/bin/env bash

if [ $# -eq 3 ]
then
    echo "START" $0
else
    echo ""
    echo "Usage : sh $0  [gVCF directory]  [Threads]  [Output name]"
    echo ""
    exit
fi

#################################################################################
#(0) Preparing

Sdir=$1
CPU=$2
output_name=$3

BWA=./src/bwa-0.7.12/bwa
PICARD=./src/picard.jar
GATK=./src/GenomeAnalysisTK.jar
BGZIP=./src/htslib-1.3.1/bgzip
TABIX=./src/htslib-1.3.1/tabix
SAMTOOL=./src/samtools-1.3.1/samtools
VCFTOOL=./src/vcftools_0.1.13/bin/vcftools

REF_BWA=./Reference/hg38_example.fa
KnownSites=./Annotations/All_20160407_example.vcf

mkdir JAVA_tmp
mkdir Results

WORKDIR=$(pwd)
JAVA_TMP=$WORKDIR"/JAVA_tmp"
RESULTDIR=$WORKDIR"/Results"

ls $Sdir/*g.vcf > $RESULTDIR/g.vcf.list.txt
Slist=$RESULTDIR/g.vcf.list.txt


#################################################################################
#(1) Combining GVCF

echo "Reading GVCF names..."
gvcf_names=$(for names in $(cat $Slist); do echo "-V" $names ; done)
echo "Reading DONE"

echo "Combining GVCF files..."
echo "Memory 20Gb"

if [ gvcf_names ]
then 
    nohup java -Djava.io.tmpdir=${JAVA_TMP} -Xmx20g -jar $GATK \
               -T CombineGVCFs \
               -R $REF_BWA \
               $gvcf_names \
               2> ${RESULTDIR}/${output_name}.log \
               | $BGZIP -c > ${RESULTDIR}/${output_name}.gz \
               2> ${RESULTDIR}/${output_name}.gz.log &
    wait
else
    exit
fi

#################################################################################
#(2) Filtering Combined GVCF file

if [ $KnownSites ]
then
    echo "Known Sites Eixts"
    echo "Starting Filtering with KnownSites :" $KnownSites
    exist=1
else
    echo "Known Sites not Eixts"
    echo "Starting Filtering without KnownSites"
    exits=0
fi

if [ $exist -eq 1 ]
then
    echo "Indexing the vcf.gz file for using the GATK tools"
    $TABIX -f -p vcf ${RESULTDIR}/${output_name}.gz
    nohup java -Djava.io.tmpdir=${JAVA_TMP} -Xmx20g -jar $GATK \
           -T GenotypeGVCFs \
           -R $REF_BWA \
           -nt $CPU \
           -V ${RESULTDIR}/${output_name}.gz \
           -stand_call_conf 30.0 \
           -stand_emit_conf 10 \
           --dbsnp $KnownSites \
           --max_alternate_alleles 24 \
           2> ${RESULTDIR}/${output_name}.Comb.vcf.log \
           | $BGZIP -c > ${RESULTDIR}/${output_name}.Comb.vcf.gz \
           2> ${RESULTDIR}/${output_name}.Comb.vcf.gz.log &
    wait
fi

if [ $exist -eq 0 ]
then
    echo "Indexing the vcf.gz file for using the GATK tools"
    $TABIX -f -p vcf ${RESULTDIR}/${output_name}.gz
    nohup java -Djava.io.tmpdir=${JAVA_TMP} -Xmx20g -jar $GATK \
           -T GenotypeGVCFs \
           -R $REF_BWA \
           -nt $CPU \
           -V ${RESULTDIR}/${output_name}.gz \
           -stand_call_conf 30.0 \
           -stand_emit_conf 10 \
           --max_alternate_alleles 24 \
           2> ${RESULTDIR}/${output_name}.Comb.vcf.log \
           | $BGZIP -c > ${RESULTDIR}/${output_name}.Comb.vcf.gz \
           2> ${RESULTDIR}/${output_name}.Comb.vcf.gz.log &
    wait
fi

echo "Combining DONE"

##################################################################################
#(3) VariantFilteration

echo "Quality filtering...."

$TABIX -f -p vcf ${RESULTDIR}/${output_name}.Comb.vcf.gz
nohup java -Djava.io.tmpdir=${JAVA_TMP} -Xmx20g -jar  $GATK  \
    -T VariantFiltration \
    -R $REF_BWA  \
    -V ${RESULTDIR}/${output_name}.Comb.vcf.gz \
    --filterName LowReadPosRankSum --filterExpression "ReadPosRankSum < -2.0" \
    --filterName LowMQRankSum --filterExpression "MQRankSum < -2.0" \
    --filterName LowQual --filterExpression "QUAL < 30.0" \
    --filterName QD --filterExpression "QD < 3.0" \
    --filterName FS --filterExpression "FS > 30.0" \
    --filterName MQ --filterExpression "MQ < 30.0" \
    --filterName DP0 --filterExpression "DP < 7" \
    --genotypeFilterName DP --genotypeFilterExpression "DP < 7" \
    --genotypeFilterName GQ --genotypeFilterExpression "GQ < 10.0" \
    2> ${RESULTDIR}/${output_name}.Comb.QualCheck.vcf.err \
    | $BGZIP -c > ${RESULTDIR}/${output_name}.Comb.QualCheck.vcf.gz \
    2> ${RESULTDIR}/${output_name}.Comb.QualCheck.vcf.gz.log &
wait

$TABIX -f -p vcf ${RESULTDIR}/${output_name}.Comb.QualCheck.vcf.gz
nohup java -Djava.io.tmpdir==${JAVA_TMP_each} -Xmx20g  -jar $GATK  \
    -T SelectVariants \
    -R $REF_BWA \
    -V ${RESULTDIR}/${output_name}.Comb.QualCheck.vcf.gz \
    --excludeFiltered \
    --excludeNonVariants \
    --setFilteredGtToNocall \
    2> ${RESULTDIR}/${output_name}.Comb.QualFilt.vcf.err \
    | bgzip -c > ${RESULTDIR}/${output_name}.Comb.QualFilt.vcf.gz \
    2> ${RESULTDIR}/${output_name}.Comb.QualFilt.vcf.gz.log &
wait
echo "Filetring Done"

################################################################################
#(4) Split INDEL and SNP variants

echo "Split INDEL and SNP variants..."

$VCFTOOL --gzvcf ${RESULTDIR}/${output_name}.Comb.QualFilt.vcf.gz --keep-only-indels --recode --stdout | $BGZIP -c > ${RESULTDIR}/${output_name}.Comb.QualFilt.INDEL.vcf.gz
$VCFTOOL --gzvcf ${RESULTDIR}/${output_name}.Comb.QualFilt.vcf.gz --remove-indels --recode --stdout | $BGZIP -c > ${RESULTDIR}/${output_name}.Comb.QualFilt.SNP.vcf.gz
$VCFTOOL --gzvcf ${RESULTDIR}/${output_name}.Comb.QualFilt.vcf.gz --remove-indels --max-alleles 2 --recode --stdout | $BGZIP -c > ${RESULTDIR}/${output_name}.Comb.QualFilt.biSNP.vcf.gz

echo "Split DONE"
##############################################################################

