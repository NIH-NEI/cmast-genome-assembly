# Author: Vijay Nagarajan PhD
# Affiliation: Laboratory of Immunology, NEI/NIH
# Contact: nagarajanv@nih.gov
# Description: This BASH script runs checkm for analyzing the genome assembly quality
# Platform: This script was developed to run in the NIH Biowulf cluster computing facility, but could be reused/reproduced with appropriate changes

# module load hmmer
# module load prodigal
# module load pplacer

#type="bold"
#type="conservative"
type="normal"
#ty="b"
ty="n"
#ty="c"

#tail -n5 Results/CheckM-Default/1b-taxonomic/out.txt | head -n1 > Results/CheckM/summary_${ty}_T.txt
#tail -n5 Results/CheckM-Default/1b-taxonomic/out.txt | head -n1 > Results/CheckM/summary_${ty}_L.txt

for i in {1..10}
do
echo "${i}"

mkdir /data/CaspiMicrobiomeData/RCSM01_20170523-39981943/cmast-vijay/Results/checkm/${i}${ty}-taxonomic
#mkdir /data/CaspiMicrobiomeData/RCSM01_20170523-39981943/cmast-vijay/Results/CheckM/${i}${ty}-lineage

cp ../Results/unicycler/${type}/${i}/assembly.fasta ../Results/unicycler/${type}/${i}/assembly_${i}${ty}.fna

checkm taxonomy_wf genus Corynebacterium ../Results/unicycler/${type}/${i} ../Results/checkm/${i}${ty}-taxonomic/ -t 50 > ../Results/checkm/${i}${ty}-taxonomic/out.txt
#checkm lineage_wf Results/Unicycler/${type}/${i}${ty} Results/CheckM/${i}${ty}-lineage/ -t 50 > Results/CheckM/${i}${ty}-lineage/out.txt

#tail -n4 Results/CheckM/${i}${ty}-lineage/out.txt | head -n2 | tail -n1 >> Results/CheckM/summary_${ty}_L.txt
tail -n4 ../Results/checkm/${i}${ty}-taxonomic/out.txt | head -n2 | tail -n1 >> ../Results/checkm/summary_${ty}_T.txt

#cat Results/CheckM/summary_${ty}_L.txt
cat ../Results/checkm/summary_${ty}_T.txt

done
