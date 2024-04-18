rm(list=ls())
library(dplyr)
library(tidyr)
library(stringr)
library(ape)

#Get variants
locations<-read.table(file = "VEP_merged_variants.tsv", sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)#[c(3,4,5,7,1,2)]#

#Get CDS Starts sites
mane_start<-read.table(file = 'MANE.GRCh38.v1.0.ensembl_genomic.gff', sep = '\t', header = FALSE, na.strings=c("","NA"), stringsAsFactors = FALSE)#[c(4)]
colnames(mane_start)<-c("seqid","source","type","start","end","score","strand","phase","attributes")
mane_start<-subset(mane_start, type=="start_codon")
mane_start$koz_pos<-NA

#Add column with transcript names
mane_start$Feature<-str_extract_all(mane_start$attributes,"(?<=transcript_id=).+(?=\\.\\d+\\;gene_type)")

#Create a column with the -3 position 
pos_start<-subset(mane_start, strand=="+")
neg_start<-subset(mane_start, strand=="-")

for (i in 1:nrow(pos_start)){
  pos_start$koz_pos[i]<-as.numeric(pos_start$start[i]) - 3
}
for (i in 1:nrow(neg_start)){
  neg_start$koz_pos[i]<-as.numeric(neg_start$end[i]) + 3
}
mane_start<-rbind(pos_start,neg_start)
remove(pos_start, neg_start, i)

locations$koz_pos<-NA

#Map the variants to the Kozak -3 positions, check if they are a G or A > C or T
for(i in 1:nrow(locations)){
  temp<-subset(mane_start, Feature == locations$Feature[i])
  for(j in 1:nrow(temp)){
    if(as.numeric(locations$position[i]) == as.numeric(temp$koz_pos[j])){
      if(locations$ref[i] %in% c("A","G") & locations$alt[i] %in% c("C","T")){
        locations$koz_pos[i]<-"KOZAK"
      }
    }
  }
}

locations<-subset(locations, !is.na(locations$koz_pos))
locations<-locations[,c(1,23)]
write.table(locations, file="Kozak_variants.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)
