##########################################################
### Author: Sarmiento Cabello, Sonia                   ###
### Version: 1.0.                                      ###
### Objective: Add individuals to an existing pedigree ###
###            using their genetic information.        ###
##########################################################

# Load libraries
library(SNPRelate)
library(hierfstat)
library(corrplot)
library(tidyverse)
library(dplyr)

#Load Files
genofile <- snpgdsOpen('ref_panel_snps_f1_masked_maf05_miss05_LDpruned.gds') #GDS
ped <- read.delim('Function1_pedigree_refpanel.txt',h=F, sep="") #ped file
hub <- read.delim('Function2_UnassignedIndvs.txt', h=F) # List of individuals missing from the pedigree

# Add column names for pedigree file (in case they are not assigned)
colnames(ped) <- c('famid','id','dadid','momid','sex','pheno')

# Calculate beta estimates from genomic data
beta1 <- snpgdsIndivBeta(genofile, autosome.only = F)
showfile.gds(closeall=TRUE)        # Close files after loading them to R
beta.mean <- snpgdsIndivBetaRel(beta1, mean(beta1$beta))

# Update sample names (if needed)
n <- read.delim('Function1_metadata.txt', sep=",", h=T).  #File with update sample names
  ## Change names to new ones 
beta.mean$sample.id=as.character(beta.mean$sample.id)
n$rawVCFname=as.character(n$rawVCFname)
n$NEWname=as.character(n$NEWname)
hub$V1=as.character(hub$V1)
  ## Replace the names in the beta matrix
pos_beta<- match(beta.mean$sample.id, n$rawVCFname)
pos_beta=na.omit(pos_beta)
  #The code below has the same output as if we loop through all values in list "pos_beta"
beta.mean$sample.id[pos_beta] <- n$NEWname[pos_beta] #Replace the values
  ## Replace the names on the missing individuals
n_hub=n %>%filter(n$rawVCFname %in% hub$V1)
pos_hub <- match(hub$V1, n_hub$rawVCFname)
pos_hub=na.omit(pos_hub)
hub$V1[pos_hub] <- n_hub$NEWname[pos_hub[pos_hub]] #Replace the values

# Sample names in a second matrix called tmp without diagonal elements
samples <- beta.mean$sample.id
tmp <- beta.mean$beta
diag(tmp) <- NA
colnames(tmp) <- samples
rownames(tmp) <- samples

#### Plot Beta Matrices for Hubs + Families ####
for(i in unique(ped$famid)){
  print(paste("Analysing family", i))
  #select family on ped file
  tmp.ped <- ped[ped$famid == i,]
  #replace 0s for NAs
  tmp.ped$dadid[tmp.ped$dadid == 0] <- NA
  tmp.ped$momid[tmp.ped$momid == 0] <- NA
  #select ID (ind, dad, mom)
  fam <-tmp.ped$id
  fam <- append(fam, tmp.ped$dadid)
  fam <- append(fam, tmp.ped$momid)
  fam <- na.omit(fam)
  fam <- unique(fam)
  tmp.hub=tmp[(row.names(tmp) %in% fam), ]
  #Identify which missing individuals are related to the families and add to the plotting
  hubs_rel=sapply(apply(tmp.hub,1, function(x) which(x>0.1)),names)
  f=fam
  for(j in hubs_rel){
    f=append(f, j)
  }
  f[f==0] <- NA
  f=na.omit(f)
  f=unique(f)
  hub_id=f[f %in% hub$V1]
  print(paste("HUBs -->", hub_id))
  all_id=append(fam, hub_id)
  f=f[f %in% all_id]
  #tmp.fam=tmp[(row.names(tmp) %in% fam),(colnames(tmp) %in% fam)]
  # return position of IDs in matrix
  fam.indx <- which(samples %in% f)
  pdf(paste0("Beta_matrix_Family_", i, "_withHUBS.pdf"))
  corrplot(tmp[fam.indx,fam.indx], method = 'square', is.corr = F,
           diag=F, tl.col = 'black', addCoef.col  = 'black', type = 'lower',
           tl.cex=0.8, tl.srt = 45, number.cex = 0.8)
  dev.off()
}
