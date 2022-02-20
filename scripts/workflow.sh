# Author: Vijay Nagarajan PhD
# Affiliation: Laboratory of Immunology, NEI/NIH
# Contact: nagarajanv@nih.gov
# Description: This BASH script takes the raw fastq files, checks the quality, does preprocessing, generates swarm command files for assembly and quality assessments
# Platform: This script was developed to run in the NIH Biowulf cluster computing facility, but could be reused/reproduced with appropriate changes

# Project Folder Structure
# cmast
#	Tools
#	RawData
#	Results
#		FastQC
#		BBDUK
#		UniCycler
#		Abyss
#		Quast
#		CheckM
#	Archive

# 1. Set project path
projectpath="/data/cmast"
cd $projectpath

# 2. FastQC
module load fastqc
module load multiqc
cd Results/FastQC
# Run fastqc quality analysis on raw data
find -L ../../RawData -name "*.fastq.gz" | parallel fastqc -o . {}
# Summarise fastqc reports
multiqc *fastqc.zip -n MultiFastQCReportRaw

# 3. BBTOOLS
module load bbtools
module load multiqc
# Identify adapters from list
bbtools bbduk in1=${projectpath}/RawData/1_S1_L001_R1_001.fastq.gz in2=${projectpath}/RawData/1_S1_L001_R2_001.fastq.gz k=23 ref=${projectpath}/RawData/adapters.fasta stats=${projectpath}/Results/BBDUK/stats.txt
# Remove adapters
cd ../../RawData
for i in {1..10}
	do
		bbtools bbduk in1=${i}_S${i}_L001_R1_001.fastq.gz in2=${i}_S${i}_L001_R2_001.fastq.gz out1=${projectpath}/Results/bbduk/${i}_S${i}_R1_trimmed.fastq.gz out2=${projectpath}/Results/bbduk/${i}_S${i}_R2_trimmed.fastq.gz ktrim=r k=21 mink=11 hdist=1 ref=${projectpath}/RawData/adapters.fasta 2> ${projectpath}/Results/bbduk/${i}_S${i}_log.txt
	done
# Run fastqc quality analysis on adapter cleaned data
find -L ${projectpath}/Results/bbduk -name "*.fastq.gz" | parallel fastqc -o . {}
# Summarise fastqc reports
multiqc FastQC/*fastqc.zip -n MultiFastQCReportRaw

# 4. Unicycler
# Assemble individual samples
# Prepare folders for bold/normal/conservative options
for i in {1..10}; do mkdir ${projectpath}/Results/unicycler/bold/${i}; done
for i in {1..10}; do mkdir ${projectpath}/Results/unicycler/normal/${i}; done
for i in {1..10}; do mkdir ${projectpath}/Results/unicycler/conservative/${i}; done
# Prepare swarm commands
for i in {1..10}; do echo "cd /data/cmast/Results/bbduk ; unicycler --depth_filter 0.00 -t 16 --mode bold -1 ${i}_S${i}_R1_trimmed.fastq.gz -2 ${i}_S${i}_R2_trimmed.fastq.gz -o /data/cmast/Results/unicycler/bold/${i}"; done
for i in {1..10}; do echo "cd /data/cmast/Results/bbduk ; unicycler --depth_filter 0.00 -t 16 --mode normal -1 ${i}_S${i}_R1_trimmed.fastq.gz -2 ${i}_S${i}_R2_trimmed.fastq.gz -o /data/cmast/Results/unicycler/normal/${i}"; done
for i in {1..10}; do echo "cd /data/cmast/Results/bbduk ; unicycler --depth_filter 0.00 -t 16 --mode conservative -1 ${i}_S${i}_R1_trimmed.fastq.gz -2 ${i}_S${i}_R2_trimmed.fastq.gz -o /data/cmast/Results/unicycler/conservative/${i}"; done
# Run swarm file
swarm -f unicycler_nofilter_adapter_removed_individual.swarm -g 64 -t 32 --gres=lscratch:200 --module unicycler

# 5. Quast
# Assembly quality analysis
# quast only
for i in {1..10}; do cp ${projectpath}/Results/unicycler/bold/${i}/assembly.fasta ${projectpath}/Results/unicycler/bold/${i}/${i}_b_assembly.fasta; quast.py -o ${projectpath}/Results/quast/alone/bold/${i} ${projectpath}/Results/unicycler/bold/${i}/${i}_b_assembly.fasta; done
for i in {1..10}; do cp ${projectpath}/Results/unicycler/normal/${i}/assembly.fasta ${projectpath}/Results/unicycler/normal/${i}/${i}_n_assembly.fasta; quast.py -o ${projectpath}/Results/quast/alone/normal/${i} ${projectpath}/Results/unicycler/normal/${i}/${i}_n_assembly.fasta; done
for i in {1..10}; do cp ${projectpath}/Results/unicycler/conservative/${i}/assembly.fasta ${projectpath}/Results/unicycler/conservative/${i}/${i}_c_assembly.fasta; quast.py -o ${projectpath}/Results/quast/alone/conservative/${i} ${projectpath}/Results/unicycler/conservative/${i}/${i}_c_assembly.fasta; done
# quast with reference 1
for i in {1..10}; do quast.py -o ${projectpath}/Results/quast/dsm/bold/${i} -r ${projectpath}/NCBI_Cmast_Ref/CmastDSM44356_Ref_Genome.fna.gz -g ${projectpath}/NCBI_Cmast_Ref/CmastDSM44356_Ref_Genome.gff.gz ${projectpath}/Results/unicycler/bold/${i}/${i}_b_assembly.fasta; done
for i in {1..10}; do quast.py -o ${projectpath}/Results/quast/dsm/normal/${i} -r ${projectpath}/NCBI_Cmast_Ref/CmastDSM44356_Ref_Genome.fna.gz -g ${projectpath}/NCBI_Cmast_Ref/CmastDSM44356_Ref_Genome.gff.gz ${projectpath}/Results/unicycler/normal/${i}/${i}_n_assembly.fasta; done
for i in {1..10}; do quast.py -o ${projectpath}/Results/quast/dsm/conservative/${i} -r ${projectpath}/NCBI_Cmast_Ref/CmastDSM44356_Ref_Genome.fna.gz -g ${projectpath}/NCBI_Cmast_Ref/CmastDSM44356_Ref_Genome.gff.gz ${projectpath}/Results/unicycler/conservative/${i}/${i}_c_assembly.fasta; done
# quast with reference 2
for i in {1..10}; do quast.py -o ${projectpath}/Results/quast/16/bold/${i} -r ${projectpath}/NCBI_Cmast_Ref/Cmast16-1433_Ref_Genome.fna.gz -g ${projectpath}/NCBI_Cmast_Ref/Cmast16-1433_Ref_Genome.gff.gz ${projectpath}/Results/unicycler/bold/${i}/${i}_b_assembly.fasta; done
for i in {1..10}; do quast.py -o ${projectpath}/Results/quast/16/normal/${i} -r ${projectpath}/NCBI_Cmast_Ref/Cmast16-1433_Ref_Genome.fna.gz -g ${projectpath}/NCBI_Cmast_Ref/Cmast16-1433_Ref_Genome.gff.gz ${projectpath}/Results/unicycler/normal/${i}/${i}_n_assembly.fasta; done
for i in {1..10}; do quast.py -o ${projectpath}/Results/quast/16/conservative/${i} -r ${projectpath}/NCBI_Cmast_Ref/Cmast16-1433_Ref_Genome.fna.gz -g ${projectpath}/NCBI_Cmast_Ref/Cmast16-1433_Ref_Genome.gff.gz ${projectpath}/Results/unicycler/conservative/${i}/${i}_c_assembly.fasta; done
# Merge all transposted tsv quast reports into one tsv table
head -n 1 ${projectpath}/Results/quast/alone/bold/2/transposed_report.tsv > ${projectpath}/Results/quast/quast_merged_bbduk_alone.tsv
for i in {1..10}; do tail -n +2 ${projectpath}/Results/quast/alone/bold/${i}/transposed_report.tsv >> ${projectpath}/Results/quast/quast_merged_bbduk_alone.tsv ; done
for i in {1..10}; do tail -n +2 ${projectpath}/Results/quast/alone/conservative/${i}/transposed_report.tsv >> ${projectpath}/Results/quast/quast_merged_bbduk_alone.tsv ; done
for i in {1..10}; do tail -n +2 ${projectpath}/Results/quast/alone/normal/${i}/transposed_report.tsv >> ${projectpath}/Results/quast/quast_merged_bbduk_alone.tsv ; done
head -n 1 ${projectpath}/Results/quast/dsm/bold/2/transposed_report.tsv > ${projectpath}/Results/quast/quast_merged_bbduk_dsm.tsv
for i in {1..10}; do tail -n +2 ${projectpath}/Results/quast/dsm/bold/${i}/transposed_report.tsv >> ${projectpath}/Results/quast/quast_merged_bbduk_dsm.tsv ; done
for i in {1..10}; do tail -n +2 ${projectpath}/Results/quast/dsm/conservative/${i}/transposed_report.tsv >> ${projectpath}/Results/quast/quast_merged_bbduk_dsm.tsv ; done
for i in {1..10}; do tail -n +2 ${projectpath}/Results/quast/dsm/normal/${i}/transposed_report.tsv >> ${projectpath}/Results/quast/quast_merged_bbduk_dsm.tsv ; done
head -n 1 ${projectpath}/Results/quast/16/bold/2/transposed_report.tsv > ${projectpath}/Results/quast/quast_merged_bbduk_16.tsv
for i in {1..10}; do tail -n +2 ${projectpath}/Results/quast/16/bold/${i}/transposed_report.tsv >> ${projectpath}/Results/quast/quast_merged_bbduk_16.tsv ; done
for i in {1..10}; do tail -n +2 ${projectpath}/Results/quast/16/conservative/${i}/transposed_report.tsv >> ${projectpath}/Results/quast/quast_merged_bbduk_16.tsv ; done
for i in {1..10}; do tail -n +2 ${projectpath}/Results/quast/16/normal/${i}/transposed_report.tsv >> ${projectpath}/Results/quast/quast_merged_bbduk_16.tsv ; done
# quast for four samples 1-4 combined assembly
quast.py -o ${projectpath}/Results/quast/1234/conservative ${projectpath}/Results/unicycler/conservative/1234/assembly.fasta
quast.py -o ${projectpath}/Results/quast/1234/normal ${projectpath}/Results/unicycler/normal/1234/assembly.fasta
quast.py -o ${projectpath}/Results/quast/1234/bold ${projectpath}/Results/unicycler/bold/1234/assembly.fasta
quast.py -o ${projectpath}/Results/quast/1234/dsm/conservative -r ../../../RCSM01_20170523-39981943/cmast-quast-Amy/NCBI_Cmast_Ref/CmastDSM44356_Ref_Genome.fna.gz -g ../../../RCSM01_20170523-39981943/cmast-quast-Amy/NCBI_Cmast_Ref/CmastDSM44356_Ref_Genome.gff.gz ${projectpath}/Results/unicycler/conservative/1234/assembly.fasta
quast.py -o ${projectpath}/Results/quast/1234/dsm/normal -r ../../../RCSM01_20170523-39981943/cmast-quast-Amy/NCBI_Cmast_Ref/CmastDSM44356_Ref_Genome.fna.gz -g ../../../RCSM01_20170523-39981943/cmast-quast-Amy/NCBI_Cmast_Ref/CmastDSM44356_Ref_Genome.gff.gz ${projectpath}/Results/unicycler/normal/1234/assembly.fasta
quast.py -o ${projectpath}/Results/quast/1234/dsm/bold -r ../../../RCSM01_20170523-39981943/cmast-quast-Amy/NCBI_Cmast_Ref/CmastDSM44356_Ref_Genome.fna.gz -g ../../../RCSM01_20170523-39981943/cmast-quast-Amy/NCBI_Cmast_Ref/CmastDSM44356_Ref_Genome.gff.gz ${projectpath}/Results/unicycler/bold/1234/assembly.fasta
quast.py -o ${projectpath}/Results/quast/1234/16/conservative -r ../../../RCSM01_20170523-39981943/cmast-quast-Amy/NCBI_Cmast_Ref/Cmast16-1433_Ref_Genome.fna.gz -g ../../../RCSM01_20170523-39981943/cmast-quast-Amy/NCBI_Cmast_Ref/Cmast16-1433_Ref_Genome.gff.gz ${projectpath}/Results/unicycler/conservative/1234/assembly.fasta
quast.py -o ${projectpath}/Results/quast/1234/16/normal -r ../../../RCSM01_20170523-39981943/cmast-quast-Amy/NCBI_Cmast_Ref/Cmast16-1433_Ref_Genome.fna.gz -g ../../../RCSM01_20170523-39981943/cmast-quast-Amy/NCBI_Cmast_Ref/Cmast16-1433_Ref_Genome.gff.gz ${projectpath}/Results/unicycler/normal/1234/assembly.fasta
quast.py -o ${projectpath}/Results/quast/1234/16/bold -r ../../../RCSM01_20170523-39981943/cmast-quast-Amy/NCBI_Cmast_Ref/Cmast16-1433_Ref_Genome.fna.gz -g ../../../RCSM01_20170523-39981943/cmast-quast-Amy/NCBI_Cmast_Ref/Cmast16-1433_Ref_Genome.gff.gz ${projectpath}/Results/unicycler/bold/1234/assembly.fasta

# 6. CheckM
# Assembly quality analysis
# use checkm.sh for individual builds
# checkm for 1234 combined assembly
cp ${projectpath}/Results/unicycler/bold/1234/assembly.fasta ${projectpath}/Results/unicycler/bold/1234/assembly.fna
cp ${projectpath}/Results/unicycler/conservative/1234/assembly.fasta ${projectpath}/Results/unicycler/conservative/1234/assembly.fna
cp ${projectpath}/Results/unicycler/normal/1234/assembly.fasta ${projectpath}/Results/unicycler/normal/1234/assembly.fna
checkm taxonomy_wf genus Corynebacterium ${projectpath}/Results/unicycler/bold/1234 ${projectpath}/Results/checkm/1234b-taxonomic/ -t 50
checkm taxonomy_wf genus Corynebacterium ${projectpath}/Results/unicycler/conservative/1234 ${projectpath}/Results/checkm/1234c-taxonomic/ -t 50
