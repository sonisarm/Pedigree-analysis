# Pedigree analysis
Author: Sonia Sarmiento

## Introduction
Welcome to the Pedigree Analysis Repository! Here you will find different R codes for analyzing familian relationships in your datasets. With pre-defined pedigree links, you can easily perform a variety of tasks and gain insights into the relationships between individuals in your data. Whether you are working on a research project or just interested in exploring your own data, this repository is a great resource to have at your fingertips.

For instance, the scripts that are shown here are able to:
* Check any family links to correct when necessary
* Add any missing individuals to the pre-existing assigned families
* Make PED files for single or multiple trios to use, for instance, during pedigree phasing


# Function 1: Checking family links
Ensure ped file relationship accuracy.
* Input: GDS file (from VCF), PED file
* Script: ```1_Checking_family_links.R```
* Output: Beta matrix, Correlation map for each Family defined in PED File

# Function 2: Adding new individuals into the pedigree
Expand your pedigree with new individuals using this R code for checking relationships with existing families.
* Input: GDS file (from VCF), PED file
* Script: ```1_Checking_family_links.R```
* Output: Beta matrix, Correlation map for each Family defined in PED File



- "Adding_individuals_to_pedigree.R": this code adds previously unidentified relationships based on beta estimates.
- "Checking_family_links.R": with this code you can check if relationships in a ped file are correct.
- "Making multriple trios.R": makes PED files with relevant data of the relationships of one individual up to as many as specified trios. 

