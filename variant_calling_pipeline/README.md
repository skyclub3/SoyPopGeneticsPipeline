# 1. Varinat Calling pipeline using GATK

Variant Calling pipeline was based on GATK software developed by Van der Auwera, and constructed by Jae-Yoon Kim, Youngbeom Cho.

This pipeline uses FastQ files of samples and finally presents VCF files for SNP and INDEL.

Source code was written in bash, sh-compatible command language, and supported only on linux platform.


# 2. Flow-chart of pipeline

The flow-chart is as follows:

![그림2](https://user-images.githubusercontent.com/49300659/81303841-36bd1e00-90b7-11ea-9295-638664dc2d5a.jpg)


# 3. Usage

## 3-1. Preparation

Usage : sh step01_Preparation.sh  [Type START]

![s1](https://user-images.githubusercontent.com/49300659/67937919-cd44ea00-fc11-11e9-8f6f-f176d54c2f16.png)


    Example: sh step01_Preparation.sh \
    
                         START                                           # START of this step


## 3-2. Indexing Reference Genome

Usage : sh step02_Reference_Indexing.sh  [Reference Fasta file]

![s2](https://user-images.githubusercontent.com/49300659/67938042-11d08580-fc12-11e9-83c0-3fed0265f698.png)


    Example: sh step02_Reference_Indexing.sh \
    
                         Reference/hg38_example.fa.gz                    # Reference f


## 3-3. Variant Calling

Usage : sh step03_Variant_Calling.sh  [Sample_directory]  [Sample_suffix: fastq.gz or fq.gz]  [# of Jobs]  [Threads]

![s3_re](https://user-images.githubusercontent.com/49300659/67938735-6cb6ac80-fc13-11e9-9670-42202f3b98c3.png)

                         
    Example: sh step03_Variant_Calling.sh \
    
                         ExampleData/ \                                  # Directory fo samples
                         
                         fastq.gz \                                      # Suffix of Samples
                         
                         3 \                                             # Number of jobs to run
                         
                         5 \                                             # Number of threads to use
                         
                         15g                                             # Memory size to use


## 3-4. Combine samples and Filtering

Usage : sh step04_Combine_gVCFs_and_Filtering.sh  [gVCF directory]  [Threads]  [Output name]

![s4](https://user-images.githubusercontent.com/49300659/67938513-fade6300-fc12-11e9-8fca-5caf24a7ceba.png)
                        

    Example: sh step04_Combine_gVCFs_and_Filtering.sh \
    
                         Results/ \                                      # Directory of gVCF samples
                         
                         5 \                                             # Number of threads to use
                         
                         sample123                                       # Name of output file

# 4. Results

Result files for each calculation step are stored in the "Results" directory, and finally vcf files for INDELs, SNPs, and bi-allelic SNPs are presented.


# 5. Requirement

The required programs are BWA, SAMTOOLS, VCFTOOLS, BGZIP, and GATK, and all the programs are provided in the "src" directory.



# 6. Contact

jaeyoonkim@kribb.re.kr

yycho@kribb.re.kr

# 7. Reference

Danecek, P., Auton, A., Abecasis, G., Albers, C. A., Banks, E., DePristo, M. A., ... & McVean, G. (2011). The variant call format and VCFtools. Bioinformatics, 27(15), 2156-2158.
                         
Li, H., Handsaker, B., Wysoker, A., Fennell, T., Ruan, J., Homer, N., ... & Durbin, R. (2009). The sequence alignment/map format and SAMtools. Bioinformatics, 25(16), 2078-2079.

Li, H., & Durbin, R. (2010). Fast and accurate long-read alignment with Burrows–Wheeler transform. Bioinformatics, 26(5), 589-595.

Van der Auwera, G. A., Carneiro, M. O., Hartl, C., Poplin, R., Del Angel, G., Levy‐Moonshine, A., ... & Banks, E. (2013). From FastQ data to high‐confidence variant calls: the genome analysis toolkit best practices pipeline. Current protocols in bioinformatics, 43(1), 11-10.
