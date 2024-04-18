rm(list= ls())
library(dplyr)
library(tidyr)
library(stringr)

#Get variants
all_variants<-read.table("VEP_merged_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)

#prep IRES locations
ires<-read.table("human_IRES_info.txt" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)[,c(1,3)]
colnames(ires)<-c("id","location")
ires$location<-as.character(ires$location)

#Handle X/Y dual locations and NA values
ires<-ires %>% mutate(location = strsplit(as.character(location), ";")) %>% unnest(location)
ires<-subset(ires, nchar(location) != 1)

#Drop trailing strand
ires$location<-sub("\\+$", "", ires$location)
ires$location<-sub("-$", "", ires$location)

#Split location
ires$location<-gsub(",", "", ires$location)
ires<-ires %>% separate(location, c("chrom", "loc"), sep=":")
ires<-ires %>% separate(loc, c("start", "stop"), sep="-")

all_variants$ires<-NA
all_variants<-subset(all_variants, Region == "five_prime_UTR") #This should be done before the loop for AggV2

for(i in 1:nrow(all_variants)){
  ir<-subset(ires, chrom == all_variants$Chrom[i])
  pos<-all_variants$position[i]
  for(j in 1:nrow(ir)){
    if(between(as.numeric(pos), as.numeric(ir$start[j]), as.numeric(ir$stop[j]))){
      all_variants$ires[i]<-ir$id[j]
    }
  }
}
all_variants<-subset(all_variants, !is.na(ires))

#Set filter thresholds
all_variants<-subset(all_variants, CADD_PHRED != "-" & PhyloP != "-")
cadd_cutoff<-22.7
phy_cutoff<-1.879

#Get variants with multiple PhyloP scores
all_variants2<-subset(all_variants, grepl( ",", all_variants$PhyloP, fixed = TRUE))
all_variants<-subset(all_variants, !(Uploaded_variation %in% all_variants2$Uploaded_variation ))

####Reformat the PhyloP score to retain only the maximal score
if(nrow(all_variants2)>0){
  for(i in 1:nrow(all_variants2)){
    phylop<-as.data.frame(strsplit(all_variants2$PhyloP[i], "\\,"), stringsAsFactors = FALSE)#Split.
    phylop<-as.data.frame(phylop)
    phylop[,1]<-as.numeric(phylop[,1])
    all_variants2$PhyloP[i]<-as.numeric(max(phylop))
  }
  remove(i, phylop)
}
gc()
all_variants<-rbind(all_variants, all_variants2)

####Subset to variants with a PhyloP/CADD score >= N
all_variants<-subset(all_variants, as.numeric(PhyloP) > phy_cutoff & as.numeric(CADD_PHRED) > cadd_cutoff)

all_variants<-all_variants[,c(1,23)]

write.table(all_variants, file="IRES_variants.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)

