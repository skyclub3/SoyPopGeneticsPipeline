#!bin/usr/env bash
SET=$(seq 1 20)
for i in $SET
do
plink \
--vcf XPEHH/POP/$1/chr$i.header.vcf \
--double-id --chr-set 28 no-xy \
--recode \
--out XPEHH/POP/$1/chr$i
#sed '1d' chr$i.legend | awk '{print $1"\t""11""\t"$2"\t"$4"\t"$3}' > chr$i.map
#sed 's/0/2/g' chr$i.haps > chr$i.hap
done

