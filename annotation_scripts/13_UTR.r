rm(list= ls())
library(dplyr)
library(stringr)
library(tidyr)

#Get Variants
vep_variants<-read.table("VEP_merged_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)

#Load UTRannotator
#Preliminary filter
vep_variants<-vep_variants %>% mutate(five_prime_UTR_variant_annotation = strsplit(as.character(five_prime_UTR_variant_annotation), "&")) %>% unnest(five_prime_UTR_variant_annotation) #split rows with multiple annotations
oGain_start<-unique(subset(vep_variants, grepl("uAUG_gain", vep_variants$five_prime_UTR_variant_annotation) & grepl("uAUG_gained_type:([^,]+)oORF", vep_variants$five_prime_UTR_variant_annotation) & (grepl("Strong", vep_variants$five_prime_UTR_variant_annotation) | grepl("Moderate", vep_variants$five_prime_UTR_variant_annotation))))
oLoss_stop<-unique(subset(vep_variants, grepl("uSTOP_lost", vep_variants$five_prime_UTR_variant_annotation) & grepl("AltStopDistanceToCDS:NA", vep_variants$five_prime_UTR_variant_annotation) & (grepl("Strong", vep_variants$five_prime_UTR_variant_annotation) | grepl("Moderate", vep_variants$five_prime_UTR_variant_annotation))))
ustrong<-unique(subset(vep_variants, grepl("uAUG_lost", vep_variants$five_prime_UTR_variant_annotation) & grepl("Strong", vep_variants$five_prime_UTR_variant_annotation)))
uFrameshift<-unique(subset(vep_variants, grepl("uFrameShift", vep_variants$five_prime_UTR_variant_annotation) & grepl("uFrameShift_alt_type:([^,]+)oORF", vep_variants$five_prime_UTR_variant_annotation) & (grepl("Strong", vep_variants$five_prime_UTR_variant_annotation)| grepl("Moderate", vep_variants$five_prime_UTR_variant_annotation))))

utr<-rbind(ustrong,oGain_start,oLoss_stop,uFrameshift)
utr<-utr[,c(1,16,17)]
utr<-unique(utr)

#Final output
utr$five_prime_UTR_variant_annotation<-gsub("([^.]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)$", "\\5_&_\\6", utr$five_prime_UTR_variant_annotation, perl=TRUE,) 

uc<-utr %>% count(five_prime_UTR_variant_annotation)
utr$five_prime_UTR_variant_consequence<-"UTRANN_FLAGGED"

write.table(utr[,c(1,3)], file="UTRann_variants.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)
