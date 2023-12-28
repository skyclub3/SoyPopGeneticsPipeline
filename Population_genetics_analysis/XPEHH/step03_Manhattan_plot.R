#!bin/usr/env R
#===========================================================================================================================
library("CMplot")

df <- read.table("XPEHH/SOJA_KOR/t.txt")


names(df) <- c("chr","pos","ehh")

snp <- c(1:9427007)

df1 <- cbind(snp,df)

#CMplot(df1,plot.type="d",bin.size=1e6,chr.den.col=c("darkgreen", "yellow", "red"),file="jpg",dpi=300, file.output=TRUE,verbose=TRUE,width=9,height=6)

#CMplot(df1,plot.type="m",ylim=c(0,3),LOG10=FALSE,threshold=NULL,file="jpg",dpi=300,file.output=TRUE,verbose=TRUE,width=14,height=6)
CMplot(df1,plot.type="m",LOG10=FALSE,threshold=NULL,file="jpg",dpi=300,file.output=TRUE,verbose=TRUE,width=14,height=6,amplify=FALSE,cex=0.5)
