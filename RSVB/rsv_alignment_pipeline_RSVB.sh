#!/bin/bash
set -beEu -o pipefail
set -x

usage() {
    echo "usage: $0 sample_R1.fq.gz sample_R2.fq.gz >& logfile.txt"
}

if [ $# != 2 ]; then 
  usage
  exit 1
fi

read1_fq=$1
read2_fq=$2

# STEP_1. Use bwa to align the paired end reads to the RSV-A RefSeq
bwa mem -t 6 ../RE20000104_RSVB_reference.fasta "${read1_fq}" "${read2_fq}" | samtools sort | samtools view -F 4 -o pipeline_alignment.sorted.bam

# STEP_2. Create a .bai index file for your new bam alignment
samtools index pipeline_alignment.sorted.bam

# STEP_3. Use the ivar package to remove the PCR amplification primer sequences from the 5'-end of the aligned reads
ivar trim -e -i pipeline_alignment.sorted.bam -b ../RSVB.primer.bed -p pipeline_alignment.primertrim | tee IVAR_OUT

# STEP_4. Sort this new, cleaned (trimmed) bam file
samtools sort pipeline_alignment.primertrim.bam -o pipeline_alignment.primertrim.sorted.bam

## STEP_5. Use ivar to call variants from the trimmed bam file
## Skipping this step for now because we don't have the correct matching GFF3 file (yet)
## samtools mpileup -A -d 600000 -B -Q 0 --reference ../OM857384.1.fasta pipeline_alignment.primertrim.sorted.bam | ivar variants -p pipeline_alignment.variants -q 20 -t 0.1 -m 20 -r ../OM857384.1.fasta -g ../OM857384.1.gb.gff

# STEP_6. Use ivar to build a consensus.fasta file
samtools mpileup --count-orphans -d 600000 --no-BAQ -Q 0 --reference ../RE20000104_RSVB_reference.fasta pipeline_alignment.primertrim.sorted.bam | ivar consensus -p pipeline_alignment.consensus -q 20 -t 0.6 -m 20 -n N

# STEP_7. Use samtools to calculate crude coverage
samtools coverage pipeline_alignment.primertrim.sorted.bam > samtools_coverage.tsv
