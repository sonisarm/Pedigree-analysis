This file contains files to test the code in main folder. The name corresponds to the name given in the scripts.
The main files are the GDS coming from genotype data, pedigree information (either all or for your specific data organised by families) and, when needed for instance when names do not correspond between files, a metadata file indicating the matching names.

The Genotype data for a couple hundred SNPs (<1000) should be ideally with
*high minor allele frequency,
low missingness,
low genotyping error rate, and
in low LD, but real-world data usually works well too. The data format is 1 row per individual, 1 column per SNP, coded as 0/1/2 copies of the reference allele. Conversion from a few other formats is supported.
