# Pedigree analysis :family:
Author: Sonia Sarmiento

## Unlock and explore familial relationships in your dataset

## Introduction
Welcome to the Pedigree Analysis Repository! Here you will find different R codes for analyzing familial relationships in your datasets. With our without pre-defined pedigree links, you can easily perform a variety of tasks and gain fruther insights into the relationships between individuals in your data. Whether you are working on a research project or just interested in exploring your own data, this repository is a great resource to have at your fingertips!

Some examples of what the scripts that are shown here are able to:
* Check any family links to correct when necessary
* Add any missing individuals to the pre-existing assigned families
* Make PED files for single or multiple trios to use, for instance, during pedigree phasing


## Function 1: Checking family links
Ensure ped file relationship accuracy.
* Input: GDS file (from VCF), PED file
* Script: ```1_Checking_family_links.R```
* Output: Beta matrix, Correlation plots for each Family defined in PED File

## Function 2: Plotting K0/K1 to solve undetermined relationships
K0/K1 plotting helps determine relatedness between individuals by plotting the number of alleles shared between two individuals (more specifically, no alleles shared - K0 - vs one allele shared - K1).
* Input: GDS file (from VCF), PED file
* Script: ```2_IBD_Analysis.R```
* Output: K0/k1 plots


## Function 3: Adding new individuals into the pedigree
Expand your pedigree with new individuals using this R code for checking relationships with existing families.
* Input: GDS file (from VCF), PED file, list of individuals you want to add
* Script: ```3_Adding_individuals_to_pedigree.R```
* Output: Beta matrix correlation plots with additional individuals


## Function 4: Creating PED files with a focus individual
Create PED files considered a specific individual as focal. Specifically, close relationships are considered for how many trios as specified, prioritizing parental relationships and then grandparents, offspring, siblings and finally grandkids.
* Input: List of individuals, main PED file specifying all relationships
* Script: ```4_Outputting_PED_files.R```
* Output: PED files of focus individual (focus individual specified in the title)




