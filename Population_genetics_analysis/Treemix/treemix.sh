#!bin/usr/env bash
#======================================================================================================================================
FILE=cohort2317.ALL.VF.SNP.MISS15.Trim.GT.BI.BEAGLE.chr.reheader.MAF1.rename
#=======================================================================================================================================
for i in {0..10}
do
 treemix -i $FILE.treemix.frq.gz -m $i -o $FILE.$i -root SOJA -bootstrap -k 500 -noss > treemix_${i}_log &
done
