What started out as a set of individual, exploratory, steps in analyzing RSV fastq files, has now been amalgamated and integrated into this public repository on GitHub.

The high level architecture of this bioinformatics pipeline is that the inputs are paired-end (PE) fastq sequence files, and the output is a so-called consensus.fasta file for that sample.
That consensus.fasta files can be analyzed further (either one at a time, or more commonly concatenated into a multi-fasta file) using Web Applications that will try to add the individual sequences
onto an existing phylogenetic tree (e.g. UShER, or Nextstrain/Nextclade).

The major steps use a tool named bwa to align the individual fastq sequencing reads to the RSV reference genome (either RSV-A or RSV-B), to generate a bam file.
We then use ivar to perform some quality control (QC) steps, and also trim out the sequence for the PCR amplication primers.  This yields a slightly smaller version of the bam file.
Finally we ivar again to create the consensus.fasta file for the sample.

Along the way this pipeline also generates information and reports on the type and quality of the sequencing reads, and statistics on how many were correctly aligned to the reference genome.
We also calculate the depth of coverage (the read coverage) across the genome, as a measure of success (sequencing success, and alignment success).

A by product of this pipeline are lists of sequence variants that were detected in this sample, and this allows the phylogenetic tree mapping algorithms to assign a patient's sample to a known clade and lineage.
