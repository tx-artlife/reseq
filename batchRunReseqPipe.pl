#!usr/bin/perl;
use strict;
use warnings;

##this perl runs the reseq pipe for a set of reference fasta files using the same reads fastq files one by one;

if($#ARGV !=2){
	print "usage: perl this ref_fasta_files_folder read1.fq read2.fq\n";
	print "Note: fasta files in the given folder must has '.fa' as the file extension\n";
	print "Note: reseq-pipe.pl file must be in the same folder as this perl\n";
	exit;
}
my $reseqPipePl = "reseq-pipe.pl";
if(!-e $reseqPipePl){
	print "$reseqPipePl not found\n";
	exit;
}


my $refFilesFolder = $ARGV[0];
if($refFilesFolder=~/(.+)\/$/){
	$refFilesFolder = $1;
}
	
my $read1 = $ARGV[1];
my $read2 = $ARGV[2];


opendir(DIR,$refFilesFolder) or die "$refFilesFolder not found\n";
my ($fileName,$filePath,$regionName);
while(readdir DIR){
	$fileName = $_;
	if($fileName =~/(.+).fa$/){##fasta file
		print $fileName,"\n";
		
		$regionName = $1;

		$filePath = $refFilesFolder."/".$fileName;
		print $filePath,"\n";
		
		if(!-e $filePath){
			print "$filePath not found\n";
			next;
		}
		
		print "perl $reseqPipePl $filePath $read1 $read2 $regionName\n";
		`perl $reseqPipePl $filePath $read1 $read2 $regionName`;	
	}
}
close DIR
