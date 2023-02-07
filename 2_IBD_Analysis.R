##########################################################
### Author: Sarmiento Cabello, Sonia                   ###
### Version: 1.0.                                      ###
### Objective: Plot IBD between individuals to         ###
###            elucidate unsolved relationships.       ###
##########################################################

# Load packages
library(SNPRelate)
library(hierfstat)
library(corrplot)
library(tidyverse)

# Load GDS
genofile <- snpgdsOpen('ref_panel_snps_f1_masked_maf05_miss05_LDpruned_1.gds')
# Calculate IBD
RV <- snpgdsIBDMoM(genofile, autosome.only = F)
# Close the GDS
snpgdsClose(genofile)

# Load PED file
ped <- read.delim('4_fixed_sexes_readable_All.txt',h=F, sep="")
colnames(ped) <- c('famid','id','dadid','momid','sex','status', 'affected')

# Read file with new names 
n <- read.delim('refpanel_metadata.txt', sep=",", h=T)
## Change the values to character 
RV$sample.id=as.character(RV$sample.id)
n$rawVCFname=as.character(n$rawVCFname)
n$NEWname=as.character(n$NEWname)

## Replace the names in the beta matrix
pos_newname<- match(RV$sample.id, n$rawVCFname)
pos_newname=na.omit(pos_newname)
#The code below has the same output as if we loop through all values in list "pos_beta"
RV$sample.id[pos_newname] <- n$NEWname[pos_newname] #Replace the values
# Plot RV 
  # Colour function
add.alpha <- function(col, alpha=1){
  if(missing(col))
    stop("Please provide a vector of colours.")
  apply(sapply(col, col2rgb)/255, 2, 
        function(x) 
          rgb(x[1], x[2], x[3], alpha=alpha))  
}
  #Actually plotting 
for(i in unique(ped$famid)){
  print(paste("Analysing family", i))
  #select family on ped file
  tmp.ped <- ped[ped$famid == i,]
  #select ID (ind, dad, mom)
  fam <-tmp.ped$id
  indx=which(RV$sample.id %in% fam)
  indx=na.omit(indx)
  RV_fam <- lapply(RV, function(x) {x[indx]})
  pdf(paste0("IBD_Family_", i, ".pdf"))
  plot(RV_fam$k1[indx]~RV_fam$k0[indx], pch=20, xlab="k0", ylab="k1", col=add.alpha('black',0.1), xlim = c(0, 1), ylim = c(0, 1))
  for(i in 1:(length(indx)-1)){
    range1=i+1
    a=indx[i]
    for(k in range1:length(indx)){
      b=indx[k]
      points(x=RV$k0[a,b],y=RV$k1[a,b], pch=20, col='red',cex=1)
      text(x=RV$k0[a,b],y=RV$k1[a,b], cex=0.4,labels=paste(RV$sample.id[a],RV$sample.id[b]))}
  }
  dev.off()
  }
