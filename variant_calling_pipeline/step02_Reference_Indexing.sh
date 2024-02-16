#~!/bin/env bash

if [ $# -eq 1 ]
then
    echo "START" $0
else
    echo ""
    echo "Usage : sh $0  [Reference Fasta file]"
    echo ""
    exit
fi

############################################################################################
#(1) step01 : Reference Indexing

echo "Reference Indexing..."

BGZIP=./src/htslib-1.3.1/bgzip
BWA=./src/bwa-0.7.12/bwa
SAMTOOL=./src/samtools-1.3.1/samtools

RefDir=$1
$BGZIP -d $RefDir
wait
RefDir=${RefDir%.gz}
RefDirP=$(dirname $RefDir)
RefFile=$(basename $RefDir .fa)

nohup $BWA index -a bwtsw $RefDir \
                   1> $RefDirP/${RefFile}.index.log \
                   2> $RefDirP/${RefFile}.index.err  &
wait

$SAMTOOL faidx $RefDir
$SAMTOOL dict $RefDir -o $RefDirP/$RefFile.dict

echo "Done"

###########################################################################################
