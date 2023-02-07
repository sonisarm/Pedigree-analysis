##########################################################
### Author: Sarmiento Cabello, Sonia                   ###
### Version: 1.0.                                      ###
### Objective: Creating PED files that focus in the    ###
###            main relationships of 1 individual.     ###
##########################################################

# Load libraries
library(tidyverse)
library(stats)
library(ggplot2)
library(ggpubr)
library(kinship2)

#############
# Load data #
#############

# Related Individuals #
indv <- read.delim('Function3_RelatedIndvs.txt', header=F,sep="")
indv <- unique(indv)
indv_list <- as.list(indv) #make it a list 

# Genetic pedigree (swiss + Georgian) #
ped <- read.delim('Function4_pedigree_all.txt', header=F,sep="")

##################
# Start analysis #
##################
#No. of trios in the PED file
threshold_trios = 4


# Count types of families in datset: 
familytrio=0    # to count total number of individuals in trios
gpfamily=0      # to count total number of individuals with grandparents
offsfamily=0    # to count total number of individuals with offspring
gkfamily=0    # to count total number of individuals with grandkids

# FOR loop for every individual for which we want trios
for(i in indv$V1){
  trionumb=0  #set number of trios to 0
  # Reset grandparents and offspring/sibling dataset
  gp.tmp=data.frame(matrix(ncol = 6))
  o.tmp=data.frame(matrix(ncol = 6))
  s.tmp=data.frame(matrix(ncol = 6))
  gk.tmp=data.frame(matrix(ncol = 6))
  dup_indv=0  # Reset duplicated individuals!
  
  # Start with individual analysis
  tmp <- ped %>% filter(V2==i)
  #Sometimes they are within two families! Remove dup. 
  fam <- tmp[1,1]
  tmp$V1=fam
  tmp <- unique(tmp)
  
  # If still dup, that means that one has parental info and the other not, so lets get the one with parental info!:
  if((nrow(tmp)==2 | (nrow(tmp)>2))){
    tmp <- tmp %>% filter(V3!='NA') %>% filter(V4!='NA') # Keep the one with parents
    tmp <- tmp[1, ]
  }
  
  # PARENTS #
  #Check if individuals have BOTH parents
  if(!is.na(tmp$V3) & !is.na(tmp$V4)){
    print(paste0(i, " has parents"))
    # In case the individual is in more than one family, we choose first row
    i.tmp <- tmp[1,]
    # add info from parents
    i.tmp[2,2]=tmp$V3
    i.tmp[2,5]=1  #add info from dad
    i.tmp[3,2]=tmp$V4
    i.tmp[3,5]=2 #add info from mom
    trionumb=trionumb+1 #one trio more
  }else {
    print(paste0(i, " has no parents info"))
    i.tmp <- tmp[1,]
    #remove any single parents:
    i.tmp$V3=NA
    i.tmp$V4=NA
  }
  
  # GRANDPARENTS #
  # Check if individual has grandparents from dad 
  dad <- tmp$V3
  gp1.tmp <- ped %>% filter(V2==tmp$V3)
  mom <- tmp$V4
  gp2.tmp <- ped %>% filter(V2==tmp$V4)
  
  # In limited cases, indv parents (mom+dad) do not have their parents indicated in some families
   # Lets keep only the rows where parents do have these info
  if((nrow(gp1.tmp)>1)){
    for(row in 1:nrow(gp1.tmp)){
      if(!is.na(gp1.tmp[row,3]) & !is.na(gp1.tmp[row,4])){
        gp1.tmp <- gp1.tmp[row,]
      }
    }
  }
  
  if((nrow(gp2.tmp)>1)){
    for(row in 1:nrow(gp2.tmp)){
      if(!is.na(gp2.tmp[row,3]) & !is.na(gp2.tmp[row,4])){
        gp2.tmp <- gp2.tmp[row,]
      }
    }
  }
  # Now that  gp1 and gp2.tmp are fixed, we can proceed to make PED format for grandparents
  if((nrow(gp1.tmp)==1)){
    if(!is.na(gp1.tmp$V3) & !is.na(gp1.tmp$V4)){
      gp.tmp <- gp1.tmp[1,]
      gp.tmp[2,2]=gp1.tmp$V3
      gp.tmp[2,5]=1  #add info from granddad
      gp.tmp[3,2]=gp1.tmp$V4
      gp.tmp[3,5]=2 #add info from grandmom
      trionumb=trionumb+1 #one trio more
      i.tmp <- i.tmp %>% filter(V2!=dad)
      print(paste0(i, " has paternal grandparents"))
    }
  } 
  #Check if individual has grandparents from mom side
  if((nrow(gp2.tmp)==1) & (nrow(gp.tmp)>2)){
    if(!is.na(gp2.tmp$V3) & !is.na(gp2.tmp$V4)){
      # add info from grandparents from mom
      gp.tmp[4,] <- gp2.tmp[1,]
      gp.tmp[5,2]=gp2.tmp$V3
      gp.tmp[5,5]=1  #add info from granddad
      gp.tmp[6,2]=gp2.tmp$V4
      gp.tmp[6,5]=2 #add info from grandmom
      trionumb=trionumb+1 #one trio more
      i.tmp <- i.tmp %>% filter(V2!=mom)
      print(paste0(i, " has maternal grandparents also"))
    }
  } else if((nrow(gp2.tmp)==1) & (nrow(gp.tmp)<2)){
    if(!is.na(gp2.tmp$V3) & !is.na(gp2.tmp$V4)){
      # add info from grandparents from mom side
      gp.tmp <- gp2.tmp[1,]
      gp.tmp[2,2]=gp2.tmp$V3
      gp.tmp[2,5]=1  #add info from granddad
      gp.tmp[3,2]=gp2.tmp$V4
      gp.tmp[3,5]=2 #add info from grandmom
      trionumb=trionumb+1 #one trio more
      i.tmp <- i.tmp %>% filter(V2!=mom)
      print(paste0(i, " has maternal grandparents only"))
    }
  }else{
      gp.tmp=data.frame(0)
    }
  
  # OFFSPRING #
  # Check if individual has any offspring 
  tmp_male <- ped %>% filter(V3==i)
  tmp_female <- ped %>% filter(V4==i)
  if(dim(tmp_female)[1] == 0){
    print(paste0(i, " is male"))
    tmp2 <- tmp_male #save tmp data into another one
  } else if(dim(tmp_male)[1] == 0){
    print(paste0(i, " is female"))
    tmp2 <- tmp_female #save tmp data into another one
  }
  #Choose offspring to keep in dataset
  rownumb <- nrow(tmp2)
  print(paste0(i, " has ", rownumb, " offspring"))
  t.tmp <- threshold_trios-trionumb
  if(rownumb > t.tmp){  
    o.tmp <- tmp2[1:t.tmp,]
  }else if(rownumb!=0 & (rownumb < t.tmp | rownumb==t.tmp)){
    o.tmp <- tmp2
  }

  # Check if there are offspring, and it they are, then add to trio counting
  if(!is.na(o.tmp[1,2])){
    o.rownumb <- nrow(o.tmp)
    trionumb=trionumb + o.rownumb
    print(paste0("We keep ", o.rownumb, " offspring"))
    # Match matrix column names to dataframe column names of i.tmp
    colnames(o.tmp)[1] <- 'V1'
    colnames(o.tmp)[2] <- 'V2'
    colnames(o.tmp)[3] <- 'V3'
    colnames(o.tmp)[4] <- 'V4'
    colnames(o.tmp)[5] <- 'V5'
    colnames(o.tmp)[6] <- 'V6' 
    #Also, sometimes offsprings are part of more than one family, make sure they are not duplicated:
    o.tmp$V1<-tmp$V1
    o.tmp <- unique(o.tmp)
  }else{
    print(paste0(i, ' has no offspring'))
  }
  
    # SIBLINGS #
  # Check if individual has any siblings from same parents! (no half-sibs in this code)
  if(trionumb < threshold_trios){
    dad <- i.tmp[1,3]
    mom <- i.tmp[1,4]
    tmp_pa <- ped %>% filter(V3==dad) %>% filter(V4==mom)
    tmp_pa <- tmp_pa %>% filter(V2!=i)  #Remove our analysed individual
    pa.rownumb <- nrow(tmp_pa)
    print(paste0(i, " has ", pa.rownumb, " siblings"))
    t.tmp <- threshold_trios-trionumb
    if(pa.rownumb > t.tmp){  
      s.tmp <- tmp_pa[1:t.tmp,]
      trionumb = trionumb + t.tmp
      print(paste0("We keep ", t.tmp, " siblings only"))
    }else if(pa.rownumb!=0 & (pa.rownumb < t.tmp | pa.rownumb==t.tmp)){
      s.tmp <- tmp_pa
      trionumb = trionumb + t.tmp
      print(paste0("We keep all ", t.tmp, " siblings"))
    }
  }

  # GRANDKIDS #
  # only if less than 5 trios in the dataset and if they have offspring! 
  if((trionumb<threshold_trios) & (!is.na(o.tmp[1,2]))){
    for(row in 1:nrow(o.tmp)){
      if(trionumb<threshold_trios){
      kid1<- o.tmp[row,]$V2
      sex<- o.tmp[row,]$V5
        if(sex==1){
        tmp3<-ped %>% filter(V3==kid1)
        } else if(sex==2){
        tmp3<-ped %>% filter(V4==kid1)
        }  
        gk.rownumb <- nrow(tmp3)
        print(paste0(i, " has ", gk.rownumb, " grandkids"))
        t.tmp <- threshold_trios-trionumb
        if(gk.rownumb > t.tmp){  
          gk.tmp <- tmp3[1:t.tmp,]
          gk.rownumb <- nrow(gk.tmp)
          trionumb=trionumb + gk.rownumb
          print(paste0("We keep ", gk.rownumb, " grandkids"))
        }else if(gk.rownumb!=0 & (gk.rownumb < t.tmp | gk.rownumb==t.tmp)){
            gk.tmp <- tmp3
            gk.rownumb <- nrow(gk.tmp)
            trionumb=trionumb + gk.rownumb
            print(paste0("We keep all ", gk.rownumb, " grandkids"))
       }
      }
    }
  }
  

  #Match s.tmp matrix column names with other datasets
  if(!is.na(s.tmp[1,2])){
    colnames(s.tmp)[1] <- 'V1'
    colnames(s.tmp)[2] <- 'V2'
    colnames(s.tmp)[3] <- 'V3'
    colnames(s.tmp)[4] <- 'V4'
    colnames(s.tmp)[5] <- 'V5'
    colnames(s.tmp)[6] <- 'V6' 
  }

  #Match gp.tmp matrix column names with other datasets
  if((nrow(gp.tmp)>2)){
    colnames(gp.tmp)[1] <- 'V1'
    colnames(gp.tmp)[2] <- 'V2'
    colnames(gp.tmp)[3] <- 'V3'
    colnames(gp.tmp)[4] <- 'V4'
    colnames(gp.tmp)[5] <- 'V5'
    colnames(gp.tmp)[6] <- 'V6' 
  }

  ## Do final dataset! ##
  tmp_final=data.frame(matrix(ncol = 6))

  # list of dataframes 
  DAT_list = list(i.tmp)
  #Add dataframes to the list that are not empty:
  if(nrow(gp.tmp)>1) {
    DAT_list <- append(DAT_list, list(gp.tmp))
    gpfamily=gpfamily+1
  }
  if((!is.na(o.tmp[1,2]))){
    DAT_list <- append(DAT_list, list(o.tmp))
    offsfamily=offsfamily+1
    
  }
  if((!is.na(gk.tmp[1,2]))){
    DAT_list <- append(DAT_list, list(gk.tmp))
    gkfamily=gkfamily+1
    
  }
  if((!is.na(s.tmp[1,2]))){
    DAT_list <- append(DAT_list, list(s.tmp))
  }
  #Do final dataset
  tmp_final = do.call(rbind, DAT_list)
  
  #Some families share individuals, thus we group this together as follows: 
  # we have to do this because BAM files are split into families and merging to one bam file is taking a lot of time
  group1<-c(2, 32)
  group2 <- c(7, 9, 29, 30, 38)
  group3<-c(10, 11, 14, 12, 13, 14, 15, 17, 18, 19, 31)
  group4 <- c(20, 22, 23, 24, 25, 36)
  
  if(tmp$V1 %in% group1){
    tmp$V1='2_mix'
  }else if(tmp$V1 %in% group2){
    tmp$V1='7_mix'
  }else if(tmp$V1 %in% group3){
    tmp$V1='10_mix'
  }else if(tmp$V1 %in% group4){
    tmp$V1='20_mix'
  }
  
  # Add the family and status which is undetermined
  tmp_final$V1=tmp$V1
  tmp_final$V6=0
  tmp_final=unique(tmp_final)  # to remove duplicate values of main indv created during the addition of siblings
  
  # In some families, some parents are also grandparents, so they appear duplicate in your dataset
     #  If you have this duplicated individual, keep those with their parental info
  dup_indv <- tmp_final$V2[duplicated(tmp_final$V2)] # Detect individual
  if(!identical(dup_indv, character(0))){
    print(paste0(dup_indv, ' is duplicated in the dataset'))
    
    dup_tmp_final <- tmp_final %>% filter(V2==dup_indv)
    dup_tmp_final <- dup_tmp_final %>% filter(V3!='NA') %>% filter(V4!='NA') # Keep the one with parents
    tmp_final <- tmp_final %>% filter(V2!=dup_indv)
    tmp_final <- rbind(tmp_final, dup_tmp_final)
  }

  #Fix any missing parents:
  fixed_ped <- with(tmp_final, fixParents(
    id = V2, 
    dadid = V3, 
    momid = V4,
    sex = V5))

  # Change NAs to 0s
  fixed_ped$dadid[fixed_ped$dadid == 0] <- NA
  fixed_ped$momid[fixed_ped$momid == 0] <- NA
  
  # add family name
  fixed_ped<- cbind(famid = tmp_final[1,1], fixed_ped)
  # Make sure the order is correct for final ped file
  fixed_ped <- fixed_ped %>% select(famid, id, dadid, momid, sex)   
  fixed_ped$status <- 0
  
  # Is this a trio only?
  if(nrow(fixed_ped)=='3'){
    familytrio=familytrio+1 
    
  }
  
  
  #Write ped
  myfile <- file.path(paste0("PEDFILES/PED_", i, ".txt"))
  write.table(fixed_ped, file = myfile, sep = " ", row.names = FALSE, col.names = FALSE,
                quote = FALSE, append = FALSE)
  
}

print(paste0('Your dataset has ', familytrio, ' trios'))
print(paste0(offsfamily,' individuals in your dataset have offspring'))
print(paste0(gpfamily,' individuals in your dataset have grandparents'))
print(paste0(gkfamily,' individuals in your dataset have grandkids'))
