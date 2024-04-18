# <br />
## Annotation Scripts <br />
<br />
This folder contains script and associated data to annotate near-coding variants. <br />
Although all scripts are numbered with a running order, it is only necessary to run the VEP script first. <br /> 
Scripts 2:13 can be run in any order. <br />
These scripts were written for use inside the Genomics England research environment, and therefore may need a djustments to paths and input in order to run outside this context. <br />
<br />

### 1_VEP_runner.sh   <br />
This script takes in a variant file in VEP-bed format [CHR POS ID REF ALT] and annotates using Ensembl's VEP software with a series of plugins and custom data. <br />
<br /> 
### 2_Post_VEP_merge.r <br />
This script takes the VEP output and merges it with our initial variant file containing additional information (such as participant IDs etc). It also identifies any variants that were passed to the VEP but not succesfully annotated, and reinstates them. <br /> 
<br /> 
### 3_RBP.r  <br />
This script takes the merged VEP output, and intersects it with a set of RBP binding site variants generated in line with Findlay et al 2022. <br /> 
<br /> 
### 4_SAI.r  <br />
This script takes the merged VEP output, and identifies any variant with a max spliceAI score => a defined threshold. <br /> 
<br />
### 5_DORF.r  <br />
This script takes the merged VEP output, and intersects it with a set of Downstream open reading frame start and stop sites taken from Chothani et al 2022. <br /> 
<br />
### 6_PolyA.r  <br />
This script takes the merged VEP output, and intersects it with polyA motifs within 30bp upstream of the primary polyA cleavage site [in DATA] <br /> 
<br />
### 7_IRES.r  <br />
This script takes the merged VEP output, and intersects it with Internal ribosome entry site locations from Zhao et al 2020 [in DATA] <br /> 
<br />
### 8_MIR.r  <br />
This script takes the merged VEP output, and intersects it with micro RNA binding sites obtained from Plotnikova et al 2019; Nowakowski et al 2018; Spengler et al 2016; Bodreau et al 2014 [in DATA] <br /> 
<br />
### 9_TFBS.r  <br />
This script takes the merged VEP output, and intersects it with transcription factor binding site locations from Vierstra et al 2020. This then needs to be passed to the FABIAN tool (steinhaus et al 2022), as per manuscript methods. <br /> 
<br />
### 10_PHYLOP.r  <br />
This script takes the merged VEP output, and identifies any with a PhyloP score over a certain threshold. <br /> 
<br />
### 11_KZ.r <br />
This script takes the merged VEP output, and identifies any variant in the CDS-3 position that alters a referenc A or G to a C or T, and therefore is thought to disrupt the Kozak consensus sequence. <br /> 
<br />
### 12_CADD.r  <br />
This script takes the merged VEP output, and and identifies any variant with a CADD score => a defined threshold. <br /> 
<br />
### 13_UTR.r  <br />
This script takes the merged VEP output, and identifies any that are flagged by UTRannotator as uAUG gain +strong or moderate kozak; uSTOP loss +strong or moderate kozak; uAUG loss +strong kozak; uFrameshift oORF creating with strong or moderate kozak. <br /> 
<br />
### burden.r  <br />
This script takes all annotated output, and combines it to prioritise all variants annotated with a potential to disrupt a near-coding regulatory feature.<br /> 
<br />
<br />
## DATA Folder  <br />
This folder contains additional data generated 'in house' that is required alongside the above annotation scripts.<br />
<br />
*** Additional data required: ***
In addition to the data contained within the 'DATA' sub-folder, data from Chothani et al 2022 "A high-resolution map of human RNA translation", and Findlay et al 2022 "Quantifying negative selection in human 3’ UTRs uncovers constrained targets of RNA-binding proteins", as detiled in the manuscript, is required. <br />
<br />
<br />


