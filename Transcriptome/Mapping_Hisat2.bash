#!/bin/bash

# Define directories and parameters
GENOME_DIR="/home/2375894/radwa-scratch/raw_data/ref_tran/hisat_index"       # Path to the directory containing genome reference files
GTF_FILE="/home/2375894/radwa-scratch/raw_data/ref_tran/genecode.v38.basic.annotation.gtf"  # Path to GTF annotation file
FASTQ_DIR="/home/2375894/radwa-scratch/raw_data/mrna/merged_samples"  # Path to the directory containing FASTQ files
OUTPUT_DIR="/home/2375894/radwa-scratch/raw_data/mapped_reads_HISAT2"                       # Directory for storing output files
THREADS=16                                      # Number of threads for HISAT2 (adjust as needed)
FINAL_OUTPUT="${OUTPUT_DIR}/final_counts.txt"      # Final output file to store all counts

# Create output directory if it doesn't exist
mkdir -p ${OUTPUT_DIR}

# Create or clear the final output file
echo -e "GeneID\t$(ls ${FASTQ_DIR}/*.fq.gz | sed 's/.fq.gz//g' | xargs -n 1 basename | tr '\n' '\t')" > ${FINAL_OUTPUT}

# Change to the directory containing fastq files
cd ${FASTQ_DIR}

# Loop through all single-end fastq.gz files
for sample in *.fq.gz; do
    base=$(basename ${sample} .fq.gz)           # Get the base name of the sample
    R1="${FASTQ_DIR}/${base}.fq.gz"             # Define the read file
    PREPROCESSED_R1="${OUTPUT_DIR}/preprocessed_${base}.fq.gz" # Output file for fastp processed reads

    # Step 1: Run fastp for quality control and trimming
    echo "Running fastp for ${base}..."
    fastp -i ${R1} -o ${PREPROCESSED_R1} -l 17 -g -p -w ${THREADS}

    # Step 2: Align reads using HISAT2
    echo "Aligning ${base} using HISAT2..."
    hisat2 -x ${GENOME_DIR}/genome_index -U ${PREPROCESSED_R1} -S ${OUTPUT_DIR}/mapped_${base}.sam -p ${THREADS}

    # Step 3: Convert SAM to BAM using samtools
    echo "Converting SAM to BAM for ${base}..."
    samtools view -bS ${OUTPUT_DIR}/mapped_${base}.sam > ${OUTPUT_DIR}/mapped_${base}.bam

    # Step 4: Sort the BAM file
    echo "Sorting BAM file for ${base}..."
    samtools sort ${OUTPUT_DIR}/mapped_${base}.bam -o ${OUTPUT_DIR}/mapped_${base}_sorted.bam

done
# Step 5: Run featureCounts with specified parameters
echo "Running featureCounts for ${base}..."
featureCounts -a ${GTF_FILE} -O -M --primary --largestOverlap -s 2 -o ${OUTPUT_DIR}/counts_${base}.txt *_sorted.bam

echo "Pipeline completed successfully!"
