# Step 1: Estimate the site allele frequency likelihood
./angsd -bam bam.filelist -doSaf 1 -anc reference.fa -GL 1 -P 24 -out out

# Step 2: Obtain the maximum likelihood estimate of the SFS
./misc/realSFS out.saf.idx -P 24 > out.sfs

# Step 3: Calculate per-site thetas
./misc/realSFS saf2theta out.saf.idx -outname out -sfs out.sfs

# Step 4: Estimate for every Chromosome/scaffold
./misc/thetaStat do_stat out.thetas.idx


# Step 5: Estimate Average Theta_W
awk '{ sum += $8; n++ } END { if (n > 0) print sum / n; }' SOJA.thetas.idx.pestPG
