# 1. Quality check raw reads
fastqc SR1.fastq SR2.fastq

# 2. Trim with fastp (corrected output filenames to match input)
fastp -i SR1.fastq -I SR2.fastq \
      -o SR1_trimmed.fastq -O SR2_trimmed.fastq \
      --unpaired1 SR1_unpaired.fastq --unpaired2 SR2_unpaired.fastq \
      --length_required 36 \
      --qualified_quality_phred 20 \
      --unqualified_percent_limit 40
      
fastqc SR1_trimmed.fastq SR2_trimmed.fastq

# 3. Repair paired-end files to ensure equal sequence counts
# fastp can automatically handle paired-end consistency
fastp -i SR1.fastq -I SR2.fastq \
      -o SR1_trimmed.fastq -O SR2_trimmed.fastq \
      --unpaired1 SR1_unpaired.fastq --unpaired2 SR2_unpaired.fastq \
      --length_required 36 \
      --qualified_quality_phred 20 \
      --unqualified_percent_limit 40 \
      --correction  # This enables read correction and maintains pairing
# verify that these two give equal sequence counts
echo "SR1 trimmed sequences: $(grep -c '^@' SR1_trimmed.fastq)"
echo "SR2 trimmed sequences: $(grep -c '^@' SR2_trimmed.fastq)"

# 4. Run velveth with repaired files
velveth Assembly 31 -shortPaired -separate -fastq SR1_trimmed.fastq SR2_trimmed.fastq

# 5. Run velvetg with proper parameters
velvetg Assembly -exp_cov auto -cov_cutoff 5 -ins_length 200

# 6. Run QUAST on the contigs
quast.py /path/to/contigs.fa -o quast_out

# 7. Check number of contigs in contigs.fa
grep -c "^>" /path/to/contigs.fa

# 8. View report.html in quast_out

# 9. Gene Prediction with Augustus
augustus --species=E_coli_K12 /path/to/contigs.fa > contig_1.gff

# 10. getting DNA sequence of all genes using StringTie gffread
gffread -w output_nt.fasta -g /path/to/contigs.fa contig_1.gff

# 11. getting protein sequence of all genes using StringTie gffread
gffread -y output_prot.fasta -g /path/to/contigs.fa contig_1.gff

# 12. We can blast these sequences & find homology with existing genes
blastp -db /path/to/blastdb/ecdb -query output_prot.fasta -out blast_ecdb.fasta -outfmt 6

blastp -db /path/to/blastdb/swissprot -query output_prot.fasta -out blast_swissprot.fasta -outfmt 6
