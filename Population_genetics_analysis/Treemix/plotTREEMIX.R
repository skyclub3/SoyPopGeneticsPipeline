#!bin/usr/env R
setwd("/data2/yycho/Results/Treemix")
prefix="merge2.fix.GT.LDpruned"
library(RColorBrewer)
library(R.utils)
source("/data2/yycho/treemix/src/plotting_funcs.R") # here you need to add the path

#par(mfrow=c(2))
for(edge in 0:10){
  plot_tree(cex=0.8,paste0(prefix,".",edge))
  title(paste(edge,"edges"))
}


for(edge in 0:5){
 plot_resid(stem=paste0(prefix,".",edge),pop_order="plink.order")
}
