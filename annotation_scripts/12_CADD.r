rm(list= ls())
library(dplyr)
library(stringr)
library(tidyr)

#Set cutoff
cadd_cutoff<-25.3

#Get Variants
vep_variants<-read.table("VEP_merged_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
vep_variants<-subset(vep_variants, !(Region == "3_prime_intron" | Region == "5_prime_intron"))

#CADD
vep_variants<-subset(vep_variants, CADD_PHRED != "-")
vep_variants<-subset(vep_variants, as.numeric(CADD_PHRED) >= cadd_cutoff)
if(nrow(vep_variants) != 0){
  vep_variants$CADD_PHRED<-"CADD"
}
write.table(vep_variants[,c(1,18)], file="CADD_variants.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)
