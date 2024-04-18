rm(list= ls())
library(dplyr)
library(tidyr)
library(stringr)

all_variants<-read.table("VEP_merged_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
all_variants<-subset(all_variants, Region !="promoter")

####Reformat the splice AI score to retain only the maximal score
for(i in 1:nrow(all_variants)){
  splice_ai<-as.data.frame(strsplit(all_variants$SpliceAI_pred[i], "\\|"), stringsAsFactors = FALSE)#Split.
  splice_ai<-as.data.frame(splice_ai[2:5,])
  splice_ai[,1]<-as.numeric(splice_ai[,1])
  all_variants$SpliceAI_pred[i]<-as.numeric(max(splice_ai))
}
remove(i, splice_ai)
gc()

all_variants$SPLICEAI<-""

####Drop any variants with a SpliceAI score less than 0.2
all_variants<-subset(all_variants, as.numeric(SpliceAI_pred) >= 0.2 )
all_variants<-all_variants[c(1,12,23)]

write.table(all_variants, file="FULL_SpliceAI_variants.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)

if(nrow(all_variants != 0)){
  all_variants$SPLICEAI<-"SPLICE_AI"
}

write.table(all_variants[,c(1,3)], file="SpliceAI_variants.tsv", quote=FALSE, sep='\t', row.names = FALSE, col.names = TRUE)
