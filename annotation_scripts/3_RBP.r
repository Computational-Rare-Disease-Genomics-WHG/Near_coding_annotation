rm(list= ls())
library(dplyr)
library(stringr)
library(tidyr)

locations<-read.table("VEP_merged_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
locations<-subset(locations, Region == "three_prime_UTR")

#Pull in RBP data from Findlay et al.
rbps<-read.csv(file = 'RBP_data_Findlay_et_al.tsv', sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)[,c(1:4,8)]
colnames(rbps)<-c("Uploaded_variation","RBP_Focality","RBP_Impact","RBP","RBP_Ref_affinity")
rbps<-unique(rbps)
rbps<-subset(rbps, RBP_Impact=="lost")
rbps$RBP_Impact<-"RBP_LOSS"

#Get the intersecting RBP loss variants
locations<-merge(locations, rbps, by="Uploaded_variation")
locations<-unique(locations)

write.table(locations[c(1,24)], file="RBP_variants.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)

