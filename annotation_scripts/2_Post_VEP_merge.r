rm(list=ls())
library(dplyr)
library(tidyr)
library(stringr)

#variant file
variants<-read.table(file = "variants.txt", sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)#[c(8,4,5)]

#Pull in the VEP annotations
vep<-read.table(file = "Vep_annotated_variants.vcf", sep = '\t', header = FALSE, na.strings=c("","NA"), stringsAsFactors = FALSE)#
colnames(vep)<-c("Uploaded_variation","Location","Allele","Gene","Feature","Feature_type","Consequence","cDNA_position","CDS_position","Protein_position","Amino_acids","Codons","Existing_variation","IMPACT","DISTANCE","STRAND","FLAGS","VARIANT_CLASS","SOURCE","SpliceAI_pred","existing_InFrame_oORFs","existing_OutOfFrame_oORFs","existing_uORFs","five_prime_UTR_variant_annotation","five_prime_UTR_variant_consequence","CADD_PHRED","CADD_RAW","LoF","LoF_filter","LoF_flags","LoF_info","gnomADg","gnomADg_AF_AFR","gnomADg_AF_AMR","gnomADg_AF_ASJ","gnomADg_AF_EAS","gnomADg_AF_FIN","gnomADg_AF_NFE","gnomADg_AF_OTH","PhyloP","ClinVar","ClinVar_CLNSIG")
vep<- vep[,c(1,5,7,20:27,40:42)]
vep<-unique(vep)

##Figure out what is missing 
perfect_match<-merge(vep, variants, by=c("Uploaded_variation","Feature")) #Find all variants in annotated set that perfectly match the uploaded variants
perfect_match<-unique(perfect_match)

nrow(as.data.frame(unique(variants$Uploaded_variation)))
missing_variants<-variants[!(variants$Uploaded_variation %in% perfect_match$Uploaded_variation),]
missing_variants<-unique(missing_variants)

perfect_match$mm<-"VEP match"
missing_variants$mm<-"No VEP"

all_variants<-merge(perfect_match,missing_variants,all=TRUE)
all_variants<-unique(all_variants)
all_variants<-subset(all_variants, Region != "")

all_variants %>% count(Region)
all_variants %>% count(Region,STATUS)

#Find any variants that are duplicated (This is caused by overlap between 5'UTR and promoter)
vd<-subset(all_variants, duplicated(all_variants$Uploaded_variation))
vd2<-subset(all_variants, Uploaded_variation %in% vd$Uploaded_variation)

write.table(all_variants, file= "VEP_merged_variants.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)
