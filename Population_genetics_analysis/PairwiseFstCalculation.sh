#!/bin/bash

while read i
do    
    while read j 
    do
        echo $i
        echo $j

        if [ $i = $j ]
        then
        continue
        else
        fileName1="${i%.*}"
        fileName2="${j%.*}"
        vcftools --gzvcf cohort.ALL.VF.SNP.MISS15.Trim.GT.BI.BEAGLE.chr.reheader.MAF1.rename.vcf.gz --weir-fst-pop $i --weir-fst-pop $j  --out ${fileName1}_${fileName2} 
        fi
    done < list2.txt

done < list.txt


