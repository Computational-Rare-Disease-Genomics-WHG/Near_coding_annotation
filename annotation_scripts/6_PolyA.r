rm(list=ls())
library(dplyr)
library(tidyr)
library(stringr)
library(Biostrings)

#Read in variants
locations<-read.table(file = "VEP_merged_variants.tsv", sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
locations<-subset(locations, Region =="three_prime_UTR" | Region == "three_prime_UTR_splice")

locations$polyA_old<-"-"
locations$polyA_new<-"-"
locations$polyA_PD<-"-"

#Process variants
polyA<-read.table(file = 'CORE_Poly_A_motifs_mapped.tsv', sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)[c(1:6)]#
polyA<-unique(polyA)

#Limit to the two main polyA signal motifs
mymotifs<-c("AATAAA","ATTAAA", "AGTAAA", "TATAAA", "CATAAA", "GATAAA", "AATATA", "AATACA", "AATAGA", "AAAAAG", "ACTAAA", "AAAAAA")
mymotifsRev<-mymotifs
for(i in 1:length(mymotifsRev)){
  mymotifsRev[[i]]<-as.character(reverseComplement(DNAString(mymotifsRev[[i]])))
}
locations<-locations %>% mutate_all(list(~str_replace(., "chr", ""))) #Crop chr prefix
polyA<-subset(polyA, motif =="AATAAA" | motif == "ATTAAA" | motif =="TTTATT" | motif == "TTTAAT")
polyA$start<-as.numeric(polyA$start)
polyA$end<-as.numeric(polyA$end)
polyA<-subset(polyA, Feature %in% locations$Feature)

#Annotate variants 
pb=txtProgressBar(min=0,max = nrow(locations), initial = 1)
for(j in 1:nrow(locations)){
  setTxtProgressBar(pb,j) #Tell the progress bar how far through you are
  temp<-subset(polyA, Feature == locations$Feature[j] & start <= as.numeric(locations$pos[j]) & end >= as.numeric(locations$pos[j]))
  if(nrow(temp)>0){
    for(k in 1:nrow(temp)){
      motif_new<-unlist(strsplit(temp$motif[k], split=""))
      motif_new[as.numeric(locations$pos[j])-as.numeric(temp$start[k])+1]<-locations$alt[j]
      motif_new<-paste(motif_new, collapse='' )
      pd<-"disrupting"
      if(temp$strand[1] == "+"){
        #Check against forward motifs
        if(motif_new %in% mymotifs){
          pd<-"preserving"
        }
      }
      if(temp$strand[1] == "-"){
        #Check against reversed, complemented motifs
        if(motif_new %in% mymotifsRev){
          pd<-"preserving"
        }
      }
      locations$polyA_old[j]<-temp$motif[k]
      locations$polyA_new[j]<-motif_new
      locations$polyA_PD[j]<-pd
    }
  }
}
close(pb)
locations<-subset(locations, polyA_old != "-")
if(nrow(locations)!=0){
  locations$polyA_PD<-"POLYA"
}
write.table(locations[,c(1,25)], file="polyA_variants.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)

