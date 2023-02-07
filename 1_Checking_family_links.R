##########################################################
### Author: Sarmiento Cabello, Sonia                   ###
### Version: 1.0.                                      ###
### Objective: Plot Kinship of identified families.    ###
##########################################################


# Loading libraries
library(SNPRelate)
library(hierfstat)
library(corrplot)
library(tidyverse)


# Load data
genofile <- snpgdsOpen('ref_panel_snps_f1_masked_maf05_miss05_LDpruned.gds') #GDS
ped <- read.delim('Function1_pedigree.txt',h=F, sep="") # pedigree
#b <- as.matrix(read.table("swiss_beta_matrix.table")) #load beta matrix, we will also generate it so no need to load

# Rename columns in ped (in case first row does not exist)
colnames(ped) <- c('famid','id','dadid','momid','sex','pheno')

#Calculate beta estimates from genomic data
beta1 <- snpgdsIndivBeta(genofile, autosome.only = F)
beta.mean <- snpgdsIndivBetaRel(beta1, mean(beta1$beta))

# The following section is to change names of samples if needed
n <- read.delim('Function3_metadata.txt', sep=",", h=T) #Data containing different names (e.g. old vs new naming)
  #Change sample ID to new names 
ind <- match(beta.mean$sample, n$rawVCFname)
beta.mean$sample.id[!is.na(ind)] <- n$NEWname[ind[!is.na(ind)]]

# sample names in a second matrix called tmp without diagonal elements
samples <- beta.mean$sample.id
tmp <- beta.mean$beta
diag(tmp) <- NA
colnames(tmp) <- samples
rownames(tmp) <- samples

# plot
#heatmap(tmp)


# Plot Kinship for each family in the pedigree file
for(i in unique(ped$famid)){
  #select family on ped file
  tmp.ped <- ped[ped$famid == i,]
  #replace 0s for NAs
  tmp.ped[tmp.ped == 0] <- NA
  #select ID (ind, dad, mom)
  fam <-tmp.ped$id
  fam <- append(fam, tmp.ped$dadid)
  fam <- append(fam, tmp.ped$momid)
  fam <- na.omit(fam)
  fam <- unique(fam)

  print(paste("Analysing family", i))
  # return position of IDs in matrix
  fam.indx <- which(samples %in% fam)

  pdf(paste0("Family_", i, ".pdf"))
  corrplot(tmp[fam.indx,fam.indx], method = 'square', is.corr = F,
         diag=F, tl.col = 'black', addCoef.col  = 'black',
         tl.cex=0.8, tl.srt = 45, number.cex = 0.8)
  dev.off()

}
