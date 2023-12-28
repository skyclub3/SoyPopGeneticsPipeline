#!/bin/env Rscript

library(PopGenome)

suppressPackageStartupMessages(library("argparse"))

parser = ArgumentParser()
parser$add_argument("vcf", nargs=1, help="indexed vcf gzip file")
parser$add_argument("STR", nargs=1, help ="Start position")
parser$add_argument("END", nargs=1, help ="End position")
parser$add_argument("Pop", nargs=1, help ="Population List")
parser$add_argument("CHR", nargs=1, help ="CHR name : 1 or 2 or 3")
parser$add_argument("Window", nargs=1, help ="window (bp)")
parser$add_argument("Sliding", nargs=1, help ="sliding (bp)")

args = parser$parse_args()
VCF = args$vcf
Start = args$STR
End = args$END
Pop_file = args$Pop
CHR = args$CHR
Win = args$Window
Slide = args$Sliding

##==============================================

Start=as.integer(Start)
End=as.integer(End)
CHR=as.character(CHR)
Win = as.integer(Win)
Slide = as.integer(Slide)

##==============================================
#Reding Data
dat = readVCF(VCF, from=Start, to=End, numcols=1000000, tid=CHR, approx=FALSE, out="", parallel=FALSE, gffpath=FALSE)

pop1 <- read.table(Pop_file)
Pop_list = list()
pop_sym=unique(as.character(pop1[,2]))
for ( i in pop_sym){
Pop_list[[i]] =as.character(pop1[which(pop1[,2]==i),][,1])
}

save.image("test.R")

"IC1"=Pop_list[[1]]
"IC2"=Pop_list[[2]]
"LR1"=Pop_list[[3]]
"LR2"=Pop_list[[4]]
"Wild"=Pop_list[[5]]

"pop1" = "IC1"
"pop2" = "IC2"
"pop3" = "LR1"
"pop4" = "LR2"
"pop5" = "Wild"


dat = set.populations(dat,list(IC1, IC2, LR1, LR2,  Wild), diploid=TRUE)
pop_seq = c("IC1","IC2","LR1", "LR2", "Wild")

#==========================================
#Sliding
dat.t=sliding.window.transform(dat, Win, Slide, type=2)

WS = paste(as.character(Win), as.character(Slide), sep="_")

print("YY")
#=========================================
#Extracing X cordinate
x_cordi = c()
dx=dat.t@region.names
count=1
for (x in dx){
se=strsplit(strsplit(x, '-')[[1]], " ")[[2]][2]
fr=strsplit(as.character(strsplit(strsplit(x, '-')[[1]],':')[[1]]), ' ')[[1]]
med=as.integer(round((as.integer(se) + as.integer(fr))/2),1)
x_cordi[count] = med
count = count + 1
}

dxx=strsplit(dat.t@region.names, " ")
count=1
str_x = c()
end_x = c()
for (y in dxx){
    str_x[count] = as.integer(y[1])
    end_x[count] = as.integer(y[3])
    count= count + 1
}


###########################################
#Pi
print("Pi")
dat.t = diversity.stats(dat.t, pi=TRUE)
nn = dat.t@Pi
ids=length(dat.t@region.names)
div=nn/ids
ids2=1:ids
colnames(div) = pop_seq

div=data.frame("STR"=str_x, "END"=end_x, div)
rownames(div) = x_cordi

outfile_name0 = strsplit(VCF, '.vcf.gz')[[1]]
outfile_name1 = paste(outfile_name0, WS, sep=".")
outfile_name9 = paste(outfile_name1, 'div.table.txt', sep='.')

write.table(div, file=outfile_name9, quote=F, col.names=TRUE, row.names=TRUE, sep='\t')


#div.as <- loess(div[,"AS"] ~ ids2, span=0.05)
#plot(predict(loess.nucdiv1), type = "l", xaxt="n", xlab="position (Mb)", ylab="nucleotide diversity", main = "Chromosome 2L (10kb windows)", ylim=c(0,0.01))
#legend("topright",c("M","S","X"),col=c("black","blue","red"), lty=c(1,1,1))

#############################################
#Hap
print("Hap")
hap=dat.t@hap.diversity.within
colnames(hap)= pop_seq


outfile_name2 = paste(outfile_name1, 'Hap.table.txt', sep='.')

hap=data.frame("STR"=str_x, "END"=end_x, hap)
rownames(hap) = x_cordi


write.table(hap, file=outfile_name2, quote=F, col.names=TRUE, row.names=TRUE, sep='\t')


##############################################
#LD
print("LD")
dat.t = linkage.stats(dat.t, detail=TRUE)
ld=dat.t@Wall.B
colnames(ld)= pop_seq

ld=data.frame("STR"=str_x, "END"=end_x, ld)
rownames(ld) = x_cordi


outfile_name3 = paste(outfile_name1, 'LD.table.txt', sep='.')
write.table(ld, file=outfile_name3, quote=F, col.names=TRUE, row.names=TRUE, sep='\t')



################################################
#Fst
print("Fst")
dat.t=F_ST.stats(dat.t, mode="nucleotide")
FST <- t(dat.t@nuc.F_ST.pairwise)

tt = colnames(FST)

tt=gsub("pop1", pop1, tt)
tt=gsub("pop2", pop2, tt)
tt=gsub("pop3", pop3, tt)
tt=gsub("pop4", pop4, tt)
tt=gsub("pop5", pop5, tt)

colnames(FST) = tt

FST=data.frame("STR"=str_x, "END"=end_x, FST)
rownames(FST) = x_cordi

outfile_name4 = paste(outfile_name1, 'Fst.table.txt', sep='.')
write.table(FST, file=outfile_name4, quote=F, col.names=TRUE, row.names=TRUE, sep='\t')

##################################################
#Sfs

dat.t=detail.stats(dat.t)


SFS = data.frame("STR"=str_x, "END"=end_x)

for (i in seq(1, length(pop_seq))){
    print(i)
    sfs = sapply(dat.t@region.stats@minor.allele.freqs, function(x){if(length(x)==0){return(0)}; return(mean(x[,i], na.rm=TRUE))})
    SFS = data.frame(SFS, sfs)
} 


rownames(SFS) = x_cordi
pop_seq2 = c(c("STR","END"),pop_seq)
colnames(SFS) = pop_seq2

outfile_name4 = paste(outfile_name1, 'SFS.table.txt', sep='.')
write.table(SFS, file=outfile_name4, quote=F, col.names=TRUE, row.names=TRUE, sep='\t')

########################################################


    








