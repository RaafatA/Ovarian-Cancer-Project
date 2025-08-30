#!/bin/bash

# Check if the input file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file_with_accessions.txt>"
    exit 1
fi

# Input text file containing accession numbers
INPUT_FILE=$1

# Check if the file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File $INPUT_FILE not found!"
    exit 1
fi

# Directory to save the downloaded files (optional)
OUTPUT_DIR="output_fastq_files"
mkdir -p $OUTPUT_DIR

# Loop through each line in the input file (each line should contain an accession number)
while IFS= read -r accession; do
    echo "Processing accession: $accession"
    
    # Use prefetch to download the SRA file for the accession
    prefetch $accession
    
    # Convert the downloaded SRA file to FASTQ using fastq-dump
    fastq-dump --split-files --outdir $OUTPUT_DIR $accession.sra
    
    # Optional: Clean up the downloaded SRA file to save space
    rm $accession.sra

    echo "FASTQ files for $accession are saved to $OUTPUT_DIR"
done < "$INPUT_FILE"

echo "All files have been processed!"
