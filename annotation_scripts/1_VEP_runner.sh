#!/bin/bash
#BSUB -q medium
#BSUB -P re_gecip_machine_learning
#BSUB -M 5000
#BSUB -R rusage[mem=6000]

module purge
module load bio/BCFtools/1.9-foss-2018b
module load bio/VEP/99.1-foss-2019a-Perl-5.28.1
PERL5LIB=/public_data_resources/vep_resources/VEP_99/VEP_plugins:$PERL5LIB

#Setup variables and load modules
#Running on full input chunk
infile=Variant_files/SFARI_vep_variants.txt
outfile=SFARI_Vep_annotated_variants.vcf

#Using older version of bcftools for compatibility issues
export PERL5LIB=/nas/weka.gel.zone/resources/tools/apps/software/bio/VEP/99.1-foss-2019a-Perl-5.28.1/Plugins/UTRannotator/:/nas/weka.gel.zone/resources/tools/apps/software/bio/VEP/99.1-foss-2019a-Perl-5.28.1/Plugins/CADD.pm:/nas/weka.gel.zone/resources/tools/apps/software/bio/VEP/99.1-foss-2019a-Perl-5.28.1/modules/api/:/resources/tools/manual_apps/software/bio/Bio-DB-BigFile/foss-2019a-Perl-5.28.1/lib/perl5/x86_64-linux-thread-multi:/resources/tools/apps/software/bio/VEP/99.1-foss-2019a-Perl-5.28.1/Plugins/loftee-GRCh38:/public_data_resources/vep_resources/LOFTEE/Build-38/human_ancestor.fa.gz:/public_data_resources/vep_resources/LOFTEE/Build-38/loftee.sql:/public_data_resources/vep_resources/LOFTEE/Build-38/gerp_conservation_scores.homo_sapiens.GRCh38.bw:$PERL5LIB
humanAncestor=/public_data_resources/vep_resources/Build-38/human_ancestor.fa.gz
gerpBigwig=/public_data_resources/vep_resources/Build-38/gerp_conservation_scores.homo_sapiens.GRCh38.bw
cache_dir=/resources/data/vep.caches/helix/99
gnomad=/public_data_resources/gnomad/v3/gnomad.genomes.r3.0.sites.vcf.bgz
fasta=/public_data_resources/reference/GRCh38/GRCh38Decoy_no_alt.fa
dbNSFP=/resources/tools/apps/restricted_academic/software/bio/dbNSFP/4.0/dbNSFP4.0a.txt.gz
module show bio/VEP/99.1-foss-2019a-Perl-5.28.1

vep  --offline \
--input_file ${infile} \
--format vcf \
--tab \
--assembly GRCh38 \
--cache \
--dir_cache ${cache_dir} \
--cache_version 99 \
--species homo_sapiens \
--no_stats \
--fasta ${fasta}  \
--variant_class \
--plugin SpliceAI,snv=/public_data_resources/SpliceAI/Predicting_splicing_from_primary_sequence-66029966/genome_scores_v1.3/spliceai_scores.masked.snv.hg38.vcf.gz,indel=/public_data_resources/SpliceAI/Predicting_splicing_from_primary_sequence-66029966/genome_scores_v1.3/spliceai_scores.masked.indel.hg38.vcf.gz \
--custom /public_data_resources/gnomad/v3/gnomad.genomes.r3.0.sites.vcf.bgz,gnomADg,vcf,exact,0,AF_AFR,AF_AMR,AF_ASJ,AF_EAS,AF_FIN,AF_NFE,AF_OTH \
--custom /public_data_resources/phylop100way/hg38.phyloP100way.bw,PhyloP,bigwig \
--custom /public_data_resources/clinvar/20220417/clinvar/vcf_GRCh38/clinvar_20220812.vcf.gz,ClinVar,vcf,exact,0,CLNSIG \
--plugin UTRannotator,$UTRanDIR/uORF_starts_ends_GRCh38_PUBLIC.txt \
--plugin CADD,/public_data_resources/CADD/v1.6/GRCh38/whole_genome_SNVs.tsv.gz,/public_data_resources/CADD/v1.6/GRCh38/gnomad.genomes.r3.0.indel.tsv.gz \
--plugin LoF,loftee_path:${LOFTEE38},human_ancestor_fa:${LOFTEE38HA},gerp_bigwig:${LOFTEE38GERP},conservation_file:${LOFTEE38SQL} \
--force_overwrite \
--fork 4 \
--output_file ${outfile}

#EXT_VEP
