#!usr/bin/perl;

use Bio::DB::Fasta;

if($#ARGV != 4) {
	print "usage: perl this inputFastaFile seqname start end outputFastafile\n";
	exit;
}
my $inFastafile = $ARGV[0];

my $seqName = $ARGV[1];

my $start = $ARGV[2];

my $end = $ARGV[3];

my $outFastafile = $ARGV[4];

my $db = Bio::DB::Fasta->new($inFastafile);

my $seq = $db->get_Seq_by_id($seqName);

my $subSeq = $seq->subseq($start => $end);

print $subSeq,"\n";

my $subSeqName = $seqName.".".$start.".".$end;
print $subSeqName,"\n";

open(OUT,'>',$outFastafile) and print OUT ">".$subSeqName."\n".$subSeq;
close OUT;
