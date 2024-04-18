rm(list= ls())
library(dplyr)
library(tidyr)
library(stringr)

all_variants<-read.table("VEP_merged_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
all_variants<-subset(all_variants, Region == "promoter")

tfbs<-read.table("TFBS.bed" , sep = '\t', header = FALSE, na.strings=c("","NA"), stringsAsFactors = FALSE)

#Intersect variants and TFBS
all_variants$TFBS<-NA
all_variants$TFBS_weight<-NA
pb=txtProgressBar(min=0,max = nrow(all_variants), initial = 1)
for(i in 1:nrow(all_variants)){
  setTxtProgressBar(pb,i) 
  t1<-subset(tfbs, V1 == all_variants$Chrom[i] & tfbs$V3 >= all_variants$position[i] & tfbs$V2 <= all_variants$position[i])
  pos<-all_variants$position[i]
  if(nrow(t1) != 0){
    for(j in 1:nrow(t1)){
      if(between(pos, t1$V2[j], t1$V3[j])){
        all_variants$TFBS[i]<-t1$V4[j]
        all_variants$TFBS_weight[i]<-"outer"
        if(between(pos, t1$V7[j], t1$V8[j])){
          all_variants$TFBS_weight[i]<-"core"
        }
      }
    }
  }
}
close(pb)
all_variants<-subset(all_variants, !is.na(TFBS))
all_variants<-all_variants[,c(1,23,24)]

write.table(all_variants, file="TFBS_variants.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)

all_variants<-subset(all_variants, TFBS_weight == "core")
write.table(all_variants, file="TFBS_variants_CORE.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)

