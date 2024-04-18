rm(list= ls())
library(dplyr)
library(stringr)
library(tidyr)

all_variants<-read.table("VEP_merged_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
mirna<-read.table("miRNA.bed" , sep = '\t', header = FALSE, na.strings=c("","NA"), stringsAsFactors = FALSE)

all_variants<-all_variants %>% mutate_all(list(~str_replace(., "chr", "")))
mirna$V1<-sub("chr", "", mirna$V1)

all_variants$miRNA<-NA
for(i in 1:nrow(all_variants)){
  mi<-subset(mirna, V1 == all_variants$Chrom[i] & as.numeric(mirna$V3) >= as.numeric(all_variants$position[i]) & as.numeric(mirna$V2) <= (as.numeric(all_variants$position[i]) + max(pmax(nchar(all_variants$reference[i]), nchar(all_variants$alternate[i])))))
  pos<-as.numeric(all_variants$position[i])
  if(nrow(mi !=0)){
    for(j in 1:nrow(mi)){
      if(between(pos, mi$V2[j], mi$V3[j])){
        all_variants$miRNA[i]<-mi$V4[j]
      }
    }
  }
}
all_variants<-subset(all_variants, !is.na(miRNA))

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
all_variants<-subset(all_variants, Region =="three_prime_UTR")

all_variants<-all_variants[,c(1,23)]
if(nrow(all_variants)!=0){
  all_variants$miRNA<-"miRNA"
}
all_variants<-unique(all_variants)

write.table(all_variants, file="miRNA_variants.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)
