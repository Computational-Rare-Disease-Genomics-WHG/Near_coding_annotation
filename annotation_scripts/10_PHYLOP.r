rm(list= ls())
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

all_variants<-read.table("VEP_merged_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
all_variants<-subset(all_variants, !is.na(PhyloP) & PhyloP != "-")
all_variants<-subset(all_variants, !(Region == "3_prime_intron" | Region == "5_prime_intron"))

#Get variants with multiple PhyloP scores
all_variants2<-subset(all_variants, grepl(",", all_variants$PhyloP, fixed = TRUE))
all_variants<-subset(all_variants, !(Uploaded_variation %in% all_variants2$Uploaded_variation ))

####Reformat the PhyloP score to retain only the maximal score
if(nrow(all_variants2 > 0)){
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

#Set the cutoff
phy_cutoff <- 7.367
all_variants<-subset(all_variants, as.numeric(PhyloP) >= phy_cutoff )
all_variants<-all_variants[c(1,20)]
write.table(all_variants, file="PhyloP_variants.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)
all_variants$PhyloP<-"PHYLOP"
write.table(all_variants, file="PhyloP_variants.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)
