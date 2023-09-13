# Near_coding_annotation
This is a repository of peripheral scripts, documents and data associated with the manuscript "Systematic identification of disease-causing promoter and untranslated region variants in 8,040 undiagnosed individuals with rare disease".
<br />
## The 'green_dominant_regions.tsv' file : 
.tsv file containing the coordinates of near-coding regions in MANE transcripts for "Green" + "Dominant" PanelApp genes (GRCh38) <br />
<br />
### Columns: <br />
**Chromosome** - with "chr" prefix <br />
**Start** - one based, fully closed <br />
**End** - one based, fully closed <br />
**Transcript** - MANE v1.0 Transcript ID (not, there may be both 'Select' and 'Plus clinical' transcripts for a given gene. <br />
**Region** - the region 'type' of the location in question. This could be either "promoter" as determined using ENCODE's promoter-like candidate cis regulatory elements, "five_prime_UTR", "5_prime_intron", "three_prime_UTR", and "3_prime_intron" <br />
## The 'annotation_coordinates.tsv' file : 
.tsv file containing the coordinates of annotations (not otherwise available in VEP) in near-coding regions in MANE transcripts for "Green" + "Dominant" PanelApp genes (GRCh38) <br />
