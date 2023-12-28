#!bin/usr/env R
#===========================================================================================================
# load tidyverse package
library(tidyverse)
library(gridExtra)
# read in data
pca <- read_table2("./cohort2317.ALL.VF.SNP.MISS15.Trim.GT.BI.BEAGLE.chr.reheader.MAF1.rename.renamesoja.vcf.eigenvec", col_names = FALSE)
eigenval <- scan("./cohort2317.ALL.VF.SNP.MISS15.Trim.GT.BI.BEAGLE.chr.reheader.MAF1.rename.renamesoja.vcf.eigenval")

# sort out the pca data
# remove nuisance column
pca <- pca[,-1]
# set names
names(pca)[1] <- "ind"
#names(pca)[2:ncol(pca)] <- paste0("PC", 1:(ncol(pca)-1))

# sort out the individual species and pops
# spp
spp <- rep(NA, length(pca$ind))
spp[grep("JPN", pca$ind)] <- "JPN"
spp[grep("CHN", pca$ind)] <- "CHN"
spp[grep("North", pca$ind)] <- "North"
spp[grep("KOR", pca$ind)] <- "KOR"
spp[grep("Other", pca$ind)] <- "Other"
spp[grep("South", pca$ind)] <- "SA"
spp[grep("OTHEr", pca$ind)] <- "OTHER"
spp[grep("EU", pca$ind)] <- "EU"
spp[grep("Other", pca$ind)] <- "Other"
spp[grep("SOJA", pca$ind)] <- "SOJA"



loc <- rep(NA, length(pca$ind))
loc[grep("SOJA", pca$ind)] <- "SOJA"
loc[grep("North", pca$ind)] <- "North"
loc[grep("South", pca$ind)] <- "SA"
loc[grep("EU", pca$ind)] <- "EU"
loc[grep("CHN", pca$ind)] <- "CHN"
loc[grep("KOR", pca$ind)] <- "KOR"
loc[grep("JPN", pca$ind)] <- "JPN"


# combine - if you want to plot each in different colours
#spp_loc <-paste0(spp, "_", loc)


# remake data.frame
pca <- as.tibble(data.frame(pca, spp, loc))


# first convert to percentage variance explained
pve <- data.frame(PC = 1:20, pve = eigenval/sum(eigenval)*100)


# make plot
a <- ggplot(pve, aes(PC, pve)) + geom_bar(stat = "identity")
a + ylab("Percentage variance explained") + theme_light()


# calculate the cumulative sum of the percentage variance explained
cumsum(pve$pve)

# plot pca
source('./ggplot_theme_Publication/ggplot_theme_Publication-2.R')
b <- ggplot(pca, aes(X3, X4, col = spp, shape = loc)) + geom_point(size = 2.5)
b <- b + xlab(paste0("PC1 (", signif(pve$pve[1], 3), "% explained var.)")) + ylab(paste0("PC2 (", signif(pve$pve[2], 3), "% explained var.)"))
#b + scale_colour_Publication()+ theme_Publication() + scale_shape_manual(values=c(7,10,12,14,1,9,5,6)) + theme_bw()
b + scale_colour_Publication()+ theme_Publication() + scale_shape_manual(values=c(15,16,15,15,17,17,18,6)) + theme_bw()+ theme(plot.background = element_blank()) + theme(panel.border = element_rect(size = 2)) 
ggsave("PCA12.pdf",width=10)


c <- ggplot(pca, aes(X3, X5, col = spp,shape=spp)) + geom_point(size = 2.5)
c <- c + xlab(paste0("PC1 (", signif(pve$pve[1], 3), "%)")) + ylab(paste0("PC3 (", signif(pve$pve[3], 3), "%)"))
#c + scale_colour_Publication()+ theme_Publication() + scale_shape_manual(values=c(7,10,12,14,1,9,5,6)) + theme_bw()
c + scale_colour_Publication()+ theme_Publication() + scale_shape_manual(values=c(15,16,15,15,17,17,18,6)) + theme_bw() +theme(plot.background = element_blank()) + theme(panel.border = element_rect(size = 2)) 
ggsave("PCA13.pdf",width=10)


d <- ggplot(pca, aes(X4, X5, col = spp,shape=spp)) + geom_point(size = 2.5)
d <- d + xlab(paste0("PC2 (", signif(pve$pve[2], 3), "%)")) + ylab(paste0("PC3 (", signif(pve$pve[3], 3), "%)"))
#d + scale_colour_Publication()+ theme_Publication() + scale_shape_manual(values=c(7,10,12,14,1,9,5,6)) + theme_bw()
d + scale_colour_Publication()+ theme_Publication() + scale_shape_manual(values=c(15,16,15,15,17,17,18,6)) + theme_bw() + theme(plot.background = element_blank()) +theme(panel.border = element_rect(size = 2))
ggsave("PCA23.pdf",width=10)
