rm(list=ls())
library(dplyr)
library(tidyr)
library(stringr)

#Process dorfs from Chothani et al
dorfs<-load(file = 'dorfs.rda')
dorf1<-dorf1[c(1,2,5,6)]
dorf2<-dorf1
dorf1$pos<-"start"
dorf2$pos<-"stop"
dorf1$V5<-dorf1$V4+2
dorf2$V4<-dorf2$V5-2
dorf1$dorfID<-paste0(dorf1$iORF_id,"_",dorf1$pos,sep="")
dorf2$dorfID<-paste0(dorf2$iORF_id,"_",dorf2$pos,sep="")

dorfs<-rbind(dorf1,dorf2)

#Read in variants
locations<-read.table(file = "VEP_merged_variants.tsv", sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)#[c(4,5,1,3,31)]#
locations<-subset(locations, Region == "three_prime_UTR")
locations$DORFS<-"-"
dorfs$chr<-paste0("chr",dorfs$chr,sep="")

#Cross reference with dORFs
for(i in 1:nrow(locations)){
  temps<-subset(dorfs, chr == locations$Chrom[i] & (as.numeric(dorfs$V5) >= as.numeric(locations$position[i])) & (as.numeric(dorfs$V4) <= as.numeric(locations$position[i])))
  if(nrow(temps)!=0){
    for(j in 1:nrow(temps)){
      if(between(as.numeric(locations$position[i]), as.numeric(temps$V4[j]),as.numeric(temps$V5[j]))){
        locations$DORFS[i]<-temps$dorfID[j]
      }
    }
  }
}
locations<-locations[c(1,23)]
l2<-locations
locations<-subset(locations, DORFS != "-")
if(nrow(locations)!=0){
  locations$DORFS<-"DORF"
}

write.table(locations, file="DORF_variants.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)
