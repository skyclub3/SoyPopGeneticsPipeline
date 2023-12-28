#!/bin/bash

# Get the base name of the input file
NAME=`basename $1`

# Remove the extension from the file name
fileNAME="${NAME%.*}"

# Print the original and modified file names
echo "Original file name: $NAME"
echo "Modified file name: $fileNAME"

# Run PLINK with the specified options
plink \
  --vcf $1 \                  # Input VCF file
  --chr-set 20 no-xy \        # Set the chromosome count to 20, excluding XY
  --double-id \               # Treat the input file as having double IDs
  --allow-extra-chr \         # Allow extra chromosomes
  --set-missing-var-ids @:# \ # Set missing variant IDs using the specified pattern
  --make-bed \                # Create a binary PED file
  --pca \                     # Perform Principal Component Analysis
  --out $fileNAME             # Output file name

