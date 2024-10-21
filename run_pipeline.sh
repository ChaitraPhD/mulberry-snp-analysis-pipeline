#!/bin/bash

# Set the SRA ID and reference genome
SRA_ID="SRR14506998"  # Change this to your SRA ID
REFERENCE_GENOME="reference_genome.fa"  # Path to your reference genome

# Create a directory for outputs
mkdir -p output

# Step 1: Download SRA data\
echo "Downloading SRA data with prefetch..."
prefetch $SRA_ID

fasterq-dump $SRA_ID --outdir ./output

# Step 2: Align reads with BWA
echo "Aligning reads with BWA..."
bwa index $REFERENCE_GENOME
bwa mem $REFERENCE_GENOME output/${SRA_ID}_1.fastq output/${SRA_ID}_2.fastq > output/aligned.sam

# Step 3: Convert SAM to BAM with SAMtools
echo "Converting SAM to BAM..."
samtools view -bS output/aligned.sam > output/aligned.bam

# Step 4: Sort the BAM file
echo "Sorting BAM file..."
samtools sort output/aligned.bam -o output/sorted.bam

# Step 5: Index the sorted BAM file
echo "Indexing BAM file..."
samtools index output/sorted.bam

# Step 6: Call variants with GATK
echo "Calling variants with GATK..."
gatk HaplotypeCaller -R $REFERENCE_GENOME -I output/sorted.bam -O output/variants.vcf

# Step 7: Annotate variants with SnpEff
echo "Annotating variants with SnpEff..."
java -jar /opt/snpeff/snpEff.jar ann -v your_species output/variants.vcf > output/annotated_variants.vcf

echo "Pipeline completed successfully!"
