#!/bin/bash

# ==== CONFIGURATION ====
FASTQ_DIR="/home/2375894/radwa-scratch/raw_data/mirna/"
COLLAPSED_DIR="collapsed"
MAPPED_DIR="mapped"
GENOME_INDEX="ref/hg38_genome_index"   
# ========================
cd /home/2375894/radwa-scratch/raw_data/mirna/
# Create output directories
mkdir -p "$COLLAPSED_DIR" "$MAPPED_DIR"

# Loop through all *_clean.fastq files
for fq in ${FASTQ_DIR}/*_clean.fastq; do
    # Skip if no matching files
    [ -e "$fq" ] || continue

    # Extract sample name (remove path and "_clean.fastq")
    sample=$(basename "$fq" _clean.fastq)

    echo "▶️ Processing $sample"

    # Run mapper.pl
    mapper.pl "$fq" \
        -d -e -h -j -m -l 18 \
        -s "${COLLAPSED_DIR}/${sample}.fa" \
        -t "${MAPPED_DIR}/${sample}.arf" \
        -p "$GENOME_INDEX"

    echo "✅ Done: $sample"
done
