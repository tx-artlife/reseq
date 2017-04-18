#!usr/bin/perl;
#this perl run the basic steps for mapping resequenced reads to reference genome
use warnings;
use strict;

## debug: 1=>only print out command line, not run the code;  0=>run the code
my $debug = 0;

##1=>remove the duplicates using MarkDuplicates from picard after bam file is sorted and indexed, which is slow
my $remove_duplicates = 1;


if($#ARGV!=3){
	print "usage: perl this ref.fa read1.fq read2.fq outputName\n";
	exit;
}


#my $ref = "ref.fa";
#my $fq1 = "reseq.read1.fq";
#my $fq2 = "reseq.read2.fq";

my $ref = $ARGV[0];
my $fq1 = $ARGV[1];
my $fq2 = $ARGV[2];

##the name of the reads file, used for naming of output files
my $name = $ARGV[3];

## index reference sequence for bwa
#bwa index -a bwtsw reference.fasta # genome sequence >1Gb
#bwa index -a is reference.fasta # genome sequence <1Gb
print "===============Step 1: indexing reference sequence for bwa...===============\n";
print "bwa index -a is $ref\n";
if($debug==0){
	`bwa index -a is $ref`;
}
print "Step 1: indexing reference sequence for bwa done!\n";


### map reads with bwa-mem algorithm
#bwa mem -a -T 20 -t 16 reference.fasta SingleEnd_reads.fq > alignment.sam # single-end reads
#bwa mem -a -p -T 20 -t 16 reference.fasta PairEnd_reads.fq > alignment.sam # interleaved pair-end reads
#bwa mem -a -T 20 -t 16 reference.fasta PairEnd_reads_1.fq PairEnd_reads_2.fq > alignment.sam # pair-end reads in two separate files
print "===============Step 2: mapping reads with bwa-mem...===============\n";
print "bwa mem -a -T 20 -t 16 $ref $fq1 $fq2 >$name.sam\n";
if($debug==0){
        `bwa mem -a -T 20 -t 16 $ref $fq1 $fq2 >$name.sam`;
}
print "Step 2: mapping reads with bwa-mem done!\n";

## index reference sequence for samtools
#samtools faidx reference.fasta
print "===============Step 3: indexing reference for samtools...===============\n";
print "samtools faidx $ref\n";
if($debug==0){
        `samtools faidx $ref`;
}
print "Step 3: indexing reference for samtools done!\n";

#### convert sam to bam
#samtools view -bhS -q 20 alignment.sam > alignment.bam
print "===============Step 4: converting sam to bam...===============\n";
print "samtools view -bhS -q 20 $name.sam >$name.bam\n";
if($debug==0){
        `samtools view -bhS -q 20 $name.sam >$name.bam`;
}
print "Step 4: converting sam to bam done!\n";

print "===============Step 4-1: deleting sam file to save space...===============\n";
print "rm $name.sam\n";
if($debug==0){
        `rm $name.sam`;
}
print "Step 4-1: deleting sam file done!\n";

##sort bam (adjust -m according to the available memories)
#samtools sort -m 250000000000 alignment.bam alignment.sorted
#NOTE: -T is required!!
print "===============Step 5: sorting bam...===============\n";
print "samtools sort -m 2500M -@ 16 -T tmp.$name $name.bam -o $name.sorted.bam\n";
if($debug==0){
        `samtools sort -m 2500M -@ 16 -T tmp.$name $name.bam -o $name.sorted.bam`;
}
print "Step 5: sorting bam done!\n";

print "=============step 5-1: deleting unsorted bam file to save space...=================\n";
print "rm $name.bam\n";
if($debug==0){
        `rm $name.bam\n`;
}
print "delete unsorted bam file done\n";

##index sorted bam file
#samtools index alignments/sim_reads_aligned.sorted.bam
print "===============Step 6: indexing sorted bam file ...===============\n";
print "samtools index $name.sorted.bam\n";
if($debug==0){
        `samtools index $name.sorted.bam`;
}
print "Step 6: indexing sorted bam file done!\n";

if($remove_duplicates==1){
	print "============================remove duplicates=============================\n";
	print "========================run picard  MarkDuplicates=========================\n";
	print "java -jar ~/bin/picard.jar MarkDuplicates I=$name.sorted.bam O=$name.sorted.duprmed.bam M=$name.marked_dup_metrics.txt ASSUME_SORTED=true REMOVE_DUPLICATES=true\n";
	if($debug==0){
		`java -jar ~/bin/picard.jar MarkDuplicates I=$name.sorted.bam O=$name.sorted.duprmed.bam M=$name.marked_dup_metrics.txt ASSUME_SORTED=true REMOVE_DUPLICATES=true`;		
       	}
	print "MarkDuplicates run done\n";


	####the output bam file need to be indexed again for reads retrival
	####but it does not need to be sorted again??
	print "=========================index dup.removed bam file===========================\n";
	print "samtools index $name.sorted.duprmed.bam\n";
	if($debug==0){
		`samtools index $name.sorted.duprmed.bam`;
	}
	print "indexing dup.removed bam file done!\n";

}

## generate bcf for one or multiple samples
#samtools mpileup -g -C 50 -Q 20 -q 20 -f reference.fasta FinalAlignment.sorted.bam -o SNPs.bcf
#print "===============Step 7: generating bcf...===============\n";
#`samtools mpileup -g -C 50 -Q 20 -q 20 -f $ref	$name.sorted.bam -o $name.bcf`;
#print "Step 7: generating bcf done!\n";







