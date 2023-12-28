prefix="cohort2317.ALL.VF.SNP.MISS15.Trim.GT.BI.BEAGLE.chr.reheader.MAF1.rename"

library(RColorBrewer)
library(R.utils)
source("./plotting_funcs.R")

tre
par(mfrow=c(2,3))
for(edge in 0:5){
  plot_tree(cex=0.8,paste0(prefix,".",edge))
  title(paste(edge,"edges"))
}

for(edge in 0:5){
  plot_resid(stem=paste0(prefix,".",edge),pop_order="GLYCINE3.clut")
}
