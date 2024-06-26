#!/bin/bash
# 
# File: run_rsv_alignment_pipeline_RSVA.sh by Marc Perry
# 
# Last Updated: 2024-06-17; Status: working in production

set -beEu -o pipefail
set -x

while read DIR FQ1 FQ2;
do
  cd "${DIR}";
  ../rsv_alignment_pipeline_RSVA.sh "${FQ1}" "${FQ2}" >& logfile.txt;

  # Modify the consensus.fasta file header to match the sample name, AND rename the output file by adding the sample name
  echo ">${DIR} RSV-A" > "${DIR}"_pipeline_alignment.consensus.fa
  tail -n 1 pipeline_alignment.consensus.fa >> "${DIR}"_pipeline_alignment.consensus.fa

  # Calculate the coverage of the non-redundant inserts
  while read CHR START END;
  do
    samtools coverage -r "${CHR}":"${START}"-"${END}" pipeline_alignment.sorted.bam >> actual_untrimmed_nonredundant_covg_per_amplicon.tsv;
  done < ../RSVA.non-redundant-inserts.bed

  head -n 1 actual_untrimmed_nonredundant_covg_per_amplicon.tsv > "${DIR}"_actual_untrimmed_coverage_per_amplicon.tsv
  grep ^RS actual_untrimmed_nonredundant_covg_per_amplicon.tsv >> "${DIR}"_actual_untrimmed_coverage_per_amplicon.tsv  

  # Run some basic samtools stats on first the intact bam file generated by bwa
  samtools stats pipeline_alignment.sorted.bam > samtools_stats.tsv
  grep ^SN samtools_stats.tsv | cut -f 2- > "${DIR}"_summary_samtools_stats.tsv

  # For comparison, run basic samtools stats on the new bam file AFTER executing the ivar primertrim step
  samtools stats pipeline_alignment.primertrim.bam > samtools_primertrim_stats.tsv
  grep ^SN samtools_primertrim_stats.tsv | cut -f 2- > "${DIR}"_summary_samtools_primertrim_stats.tsv

  cd ../;
done
