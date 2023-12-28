MAIN=XPEHH
INPUT=XPEHH/POP/$1
INPUT2=XPEHH/POP/$2
RESP=XPEHH/script
dir=${1}_${2}
if [ ! -d $dir ]; then
    mkdir $dir
fi
SET=$(seq 1 20)
for i in $SET
do
cat <<EOF > $RESP/${dir}_chr${i}.r

#bin/usr/env R

# load packages
library(rehh)

library(tidyverse)




pop1_map <- read.table("${INPUT}/chr${i}.map")

pop2_map <- read.table("${INPUT2}/chr${i}.map")


# read in data for each species
# house
pop1_hh <- data2haplohh(hap_file ="${INPUT}/chr${i}.header.vcf", map_file=pop1_map, polarize_vcf = FALSE)



# bactrianus
pop2_hh <- data2haplohh(hap_file = "${INPUT2}/chr${i}.header.vcf",map_file=pop2_map, polarize_vcf = FALSE)

#perform scans
pop1_scan <- scan_hh(pop1_hh, polarized=FALSE)
pop2_scan <- scan_hh(pop2_hh, polarized=FALSE)



outgroup <- ies2xpehh(pop1_scan, pop2_scan,popname1="$1" , popname2="$2", include_freq=T)

#ggplot(outgroup, aes(POSITION, XPEHH_outgroup_Native)) + geom_point()
#ggsave(file="/data2/yycho/Results/XP-CLR-EHH/Rxpehh/outgroup/xpehh_Ogye_outgroup_chr${i}_plot.png")
#ggplot(outgroup, aes(POSITION, LOGPVALUE)) + geom_point()
#ggsave(file="/data2/yycho/Results/XP-CLR-EHH/Rxpehh/outgroup/xpehh_Ogye_outgroup_chr${i}_log_plot.png")

write.csv(outgroup,file="$MAIN/${dir}/${dir}_xpehh_chr${i}.csv")


# find the highest hit
hit <- outgroup %>% arrange(desc(LOGPVALUE)) %>% top_n(1)


# get SNP position
x <- hit$POSITION


marker_id_1 <- which(pop1_hh@positions == x)
marker_id_2 <- which(pop2_hh@positions == x)



pop1_furcation <- calc_furcation(pop1_hh, mrk = marker_id_1)
pop2_furcation <- calc_furcation(pop2_hh, mrk = marker_id_2)


outgroup <- tbl_df(outgroup)
colnames(outgroup) <- tolower(colnames(outgroup))
write_tsv(outgroup, "$MAIN/${dir}/${dir}_chr${i}_xpEHH.tsv")
EOF
done
