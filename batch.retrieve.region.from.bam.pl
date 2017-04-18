#!usr/bin/perl;
##this perl extract all the reads for each region contained in the input bed file from the bam file
##output extracted bam file(unsorted) and then sort it(sorted bam)  and index it (bai file)
use strict;
use warnings;

if($#ARGV!=1){
	print "usage: perl this in.sorted.bam bedfile\nNOTE\n\t1.bedfile: col1=chromName col2=start col3=end\n\t2.bam file must be sorted and indexed!\n";
	exit;
}

my $bam = $ARGV[0];
my $bed = $ARGV[1];

open(IN,$bed) or die "no $bed file found\n";

my ($line, @a);

while(<IN>){
	$line = $_;
	chomp($line);
	if($line =~/^\s+$/){#empty line
		next;
	}
	@a = split(/\s+/,$line);
	if($#a<2){
		next;
	}	
	print "Extracting chrom: $a[0] from $a[1] to $a[2]\n";
	
	##extract
	print "======================================================\n"
	print "samtools view -h $bam $a[0]:$a[1]-$a[2] >$a[0].$a[1].$a[2].bam\n";
	`samtools view -h $bam $a[0]:$a[1]-$a[2] >$a[0].$a[1].$a[2].bam`;

	##sort
	print "samtools sort -T $a[1]-$a[2] $a[0].$a[1].$a[2].bam -o $a[0].$a[1].$a[2].sorted.bam\n";
	`samtools sort -T $a[1]-$a[2] $a[0].$a[1].$a[2].bam -o $a[0].$a[1].$a[2].sorted.bam`;

	##indexing
	print "samtools index $a[0].$a[1].$a[2].sorted.bam\n";	
	`samtools index $a[0].$a[1].$a[2].sorted.bam`;

}
close IN;
