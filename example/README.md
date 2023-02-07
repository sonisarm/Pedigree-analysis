This file contains files to test the code in main folder. The name corresponds to the name given in the scripts. Also in the name, is indicated which code corresponds to which files (e.g.```Function1_ped_refpanel.txt``` corresponds to R code ```1_...```, but can also be used in subsequent R codes).
The main files are the GDS coming from genotype data, pedigree information (either all or for your specific data organised by families) and, when needed for instance when names do not correspond between files, a metadata file indicating the matching names.

The GDS file can be made from a VCF in R as follows:
```{r}
library(SNPRelate)
snpgdsVCF2GDS(vcfname, gdsname) 
```
The data format is 1 row per individual, 1 column per SNP, coded as 0/1/2 copies of the reference allele. 
Then the GDS with genotype data, should have ideally couple hundred SNPs (<1000) and be filtered for:
- high minor allele frequency, (```maf05```, filtering out SNPs with low allele freq)
- low missingness, (```miss05```, filtered out SNPs with more than 5% missing data)
- in low LD (```LDpruned```)

Minor allele frequency can be filtered with VCFtools and LD with PLINK in two steps (1)get SNPs with lower LD as determined, 2)keep this SNPs from input data) as follows:
```
plink --vcf filteredinput.vcf --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise 100 10 0.1 --out ld 
plink --vcf filteredinput.vcf --allow-extra-chr --set-missing-var-ids @:# --extract ld.prune.in --recode vcf-iid --out output
```  
