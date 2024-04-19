rm(list= ls())
library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
library(UpSetR)
library(grid)
library(Rlabkey)

#Total variant counts for case and control must be entered here
full_case<-
full_cont<- 

#Get Variants
vep_variants<-read.table("VEP_merged_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)[,c(1,8,7,9,22)]
vep_variants<-unique(vep_variants)
vep_variants<-subset(vep_variants, Region != "CDS")

#identify variants that appear in more than 1 location (promoter overlap)
vd<-subset(vep_variants, duplicated(vep_variants$Uploaded_variation))
vd<-subset(vep_variants, Uploaded_variation %in% vd$Uploaded_variation)

###### Read in all the annotated variants
#RBP
annot<-read.table("RBP_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
vep_variants<-merge(vep_variants,annot,by="Uploaded_variation",all.x=TRUE)

#SpliceAI
annot<-read.table("SpliceAI_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
vep_variants<-merge(vep_variants,annot,by="Uploaded_variation",all.x=TRUE)

#DORF
annot<-read.table("DORF_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
vep_variants<-merge(vep_variants,annot,by="Uploaded_variation",all.x=TRUE)

#PolyA
annot<-read.table("polyA_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
vep_variants<-merge(vep_variants,annot,by="Uploaded_variation",all.x=TRUE)

#IRES
annot<-read.table("IRES_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
vep_variants<-merge(vep_variants,annot,by="Uploaded_variation",all.x=TRUE)

#miRNA
annot<-read.table("miRNA_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
vep_variants<-merge(vep_variants,annot,by="Uploaded_variation",all.x=TRUE)

#TFBS 
annot<-read.table("fabian_variants.txt" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)[,c(7,1)]
colnames(annot)[2]<-"TFBS"
if(nrow(annot)!=0){
  annot$TFBS<-"TFBS"
}
vep_variants<-merge(vep_variants,annot,by="Uploaded_variation",all.x=TRUE)

#PhyloP
annot<-read.table("PhyloP_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
vep_variants<-merge(vep_variants,annot,by="Uploaded_variation",all.x=TRUE)

#KOZAK
annot<-read.table("Kozak_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
vep_variants<-merge(vep_variants,annot,by="Uploaded_variation",all.x=TRUE)

#CADD
annot<-read.table("CADD_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
vep_variants<-merge(vep_variants,annot,by="Uploaded_variation",all.x=TRUE)

#UTRannotator
annot<-read.table("UTRann_variants.tsv" , sep = '\t', header = TRUE, na.strings=c("","NA"), stringsAsFactors = FALSE)
colnames(annot)[2]<-"UTRann"
vep_variants<-merge(vep_variants,annot,by="Uploaded_variation",all.x=TRUE)
remove(annot)
gc()

###################################################################

#Filter to exclude variants with no annotations
all_variants2<-subset(vep_variants, !is.na(ires) | !is.na(DORFS) | !is.na(polyA_PD) | !is.na(SPLICEAI) | !is.na(TFBS) | !is.na(PhyloP) | !is.na(RBP_Impact) | !is.na(CADD_PHRED) | !is.na(UTRann)| !is.na(koz_pos)| !is.na(miRNA))
colnames(all_variants2)<-c("Uploaded_variation","STATUS","ID","Location","ClinVar","RBP","SPLICE_AI","DORF","POLY_A","IRES","miRNA","TFBS","PHYLOP","KOZAK","CADD","UTR_ANNOTATOR")
all_variants2<-unique(all_variants2)

#Filter to exclude variants with benign annotations
clinsig<-all_variants2[,c(1,5)]
clinsig<-subset(clinsig, ClinVar== "Benign" | ClinVar == "Likely_benign" | ClinVar == "Benign/Likely_benign" | ClinVar == "protective")
all_variants2<-subset(all_variants2, !(Uploaded_variation %in% clinsig$Uploaded_variation))

#Check for irrelevant annotations (i.e. PolyA in 5'UTR)
all_variants2 %>% count(Location)
all_variants2$POLY_A[all_variants2$location_type != "three_prime_UTR" ]<- NA
all_variants2$SPLICE_AI[all_variants2$location_type == "promoter"]<- NA
all_variants2$UTR_ANNOTATOR[all_variants2$location_type == "five_prime_UTR"]<- NA
all_variants2$TFBS[all_variants2$location_type != "promoter" ]<- NA
all_variants2<-subset(all_variants2, !is.na(IRES) | !is.na(DORF) | !is.na(POLY_A) | !is.na(SPLICE_AI) | !is.na(TFBS) | !is.na(PHYLOP) | !is.na(RBP) | !is.na(CADD) | !is.na(UTR_ANNOTATOR)| !is.na(KOZAK)| !is.na(miRNA))

unique_variants<-all_variants2[,c(1:3)]
unique_variants<-unique(unique_variants)
all_variants2 %>% count(STATUS)

rnames<-c("No_variant","Has_variant")
cnames<-c("Case","Control")

mat1.data<-c((full_case-nrow(as.data.frame(subset(unique_variants, STATUS=="case")))),(full_cont-nrow(as.data.frame(subset(unique_variants, STATUS=="control")))),nrow(as.data.frame(subset(unique_variants, STATUS=="case"))),nrow(as.data.frame(subset(unique_variants, STATUS=="control")))) #
mat1 <- matrix(mat1.data,nrow=2,ncol=2,byrow=TRUE,dimnames=list(rnames,cnames))
mat1
fisher.test(mat1)

