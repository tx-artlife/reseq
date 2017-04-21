#!/usr/bin/awk -f
##calculate the average depth for a given window size
##./this input_coverage_file(base by base) >outfile
BEGIN{
	#print "start";
	wSize = 10000;
	#print $wSize;
	sum = 0;
	avg = 0;
}
{
	#$wSize = 100;	
	#print $2;
	sum+=$3;
	
	if ($2%wSize == 0){
		avg = sum/wSize;
		#print out chrom name, position, average depth
		print $1,$2,avg;
		sum = 0;
	}
	#print $2;
}
