# Author: Vijay Nagarajan PhD
# Affiliation: Laboratory of Immunology, NEI/NIH
# Contact: nagarajanv@nih.gov
# Description: This BASH file creates swarm commands file for abyss genome assembly

for i in {1..10}
do

#cp /data/cmast/Results/Trimmomatic/trimmedfastq/${i}_S${i}_L001_R1_001_paired_trimmed.fastq.gz /data/cmast/Results/Trimmomatic/trimmedfastq/${i}_S${i}_L001_R1_001_paired_trimmed_1.fastq.gz
#cp /data/cmast/Results/Trimmomatic/trimmedfastq/${i}_S${i}_L001_R1_001_unpaired_trimmed.fastq.gz /data/cmast/Results/Trimmomatic/trimmedfastq/${i}_S${i}_L001_R1_001_unpaired_trimmed_1.fastq.gz
#cp /data/cmast/Results/Trimmomatic/trimmedfastq/${i}_S${i}_L001_R2_001_paired_trimmed.fastq.gz /data/cmast/Results/Trimmomatic/trimmedfastq/${i}_S${i}_L001_R2_001_paired_trimmed_2.fastq.gz
#cp /data/cmast/Results/Trimmomatic/trimmedfastq/${i}_S${i}_L001_R2_001_unpaired_trimmed.fastq.gz /data/cmast/Results/Trimmomatic/trimmedfastq/${i}_S${i}_L001_R2_001_unpaired_trimmed_2.fastq.gz

r1pfile=/data/cmast/Results/Trimmomatic/trimmedfastq/${i}_S${i}_L001_R1_001_paired_trimmed_1.fastq.gz
r1upfile=/data/cmast/Results/Trimmomatic/trimmedfastq/${i}_S${i}_L001_R1_001_unpaired_trimmed_1.fastq.gz
r2pfile=/data/cmast/Results/Trimmomatic/trimmedfastq/${i}_S${i}_L001_R2_001_paired_trimmed_2.fastq.gz
r2upfile=/data/cmast/Results/Trimmomatic/trimmedfastq/${i}_S${i}_L001_R2_001_unpaired_trimmed_2.fastq.gz

#echo ${r1pfile}
#echo ${r1upfile}
#echo ${r2pfile}
#echo ${r2upfile}

echo "abyss-pe k=76 j=16 name=${i}_cmastrc110 in='${r1pfile} ${r2pfile}' se='${r1upfile} ${r2upfile}'"
echo "abyss-pe k=86 j=16 name=${i}_cmastrc120 in='${r1pfile} ${r2pfile}' se='${r1upfile} ${r2upfile}'"
echo "abyss-pe k=96 j=16 name=${i}_cmastrc130 in='${r1pfile} ${r2pfile}' se='${r1upfile} ${r2upfile}'"

done


