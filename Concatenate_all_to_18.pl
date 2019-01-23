#!/usr/local_rwth/bin/perl -w

#############################################################################
## Script for joining simulation data                                      ##
#############################################################################
## (c) Ehsan Zandi, April 2012                                             ##
##     ehsan.zandi@rwth-aachen.de                                          ##
##     Institute of Communication Systems and Data Processing, RWTH Aachen ##
#############################################################################


system("clear");
my @four = (4, 4, 4, 4, 4, 4, 4, 4, 4, 4);
$name = "BS1_1_MT12b-12c/LTE_ILM_BS1_1_MT12b-12c_";
$nbFiles = 100; 
@mcs = (213,413,613,212,412,612,223,423,623,234,434,634,256,456,656,278,478,678);
#@mcs = 678;
@dBbase = (-10,0,10,20,30);
$Num_of_parallelisedSim = 4;     #This means we have simulated 4*25 frames rather than 100 ones and the BER, FER are to be averaged over 4 times.

#@mcs = (612);
#@dBbase = (0);
#$nbFiles = 30;

for ($m = 0; $m <$#mcs+1; $m++) {
	print "Files for mcs=$mcs[$m] are being concatenated,\t";
	$abort = 0;
	my $validity_test = 0;
	$base_filename = $name.$mcs[$m];
	#$resultfile = "/home/ez399388/New folder/Final Results/".$base_filename;
	$goodputfile = "Final Results/GPT_LTE_ILM_BS1_".$mcs[$m].".txt";
	#if (-e $resultfile) {
	#system ("rm",  $resultfile);
	#}
	if (-e $goodputfile) {
	system ("rm",  $goodputfile);
	}
	## CHECK IF ALL NECESSARY FILES ARE AVAILABLE  #################################
	#$abort = 0;
	#open(OUTPUT, ">>$resultfile") or die "could not open file $resultfile\n";
	open(GPT, ">>$goodputfile") or die "could not open file $goodputfile\n";
	#print OUTPUT "SNR -10 0.1 30\nSTEPS 21\n";
	for ($q = 0; $q <$#dBbase+1; $q++){
		last if ($abort > 0);
		for($d=0; $d < $nbFiles; $d++) {
			last if ($abort > 0);
			my @value =  (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
			for ($k=1; $k<$Num_of_parallelisedSim+1; $k++) {
				$tempfile = $base_filename."_".$dBbase[$q]."_".$d."_".$k;
				open(TEMPFILE, "<$tempfile")
				#or die "could not open file $tempfile\n";
				or ($abort++ and last);
				my $lines = <TEMPFILE>;
				#my @validity_test = <TEMPFILE>;
				close(TEMPFILE);
				@a = split(/     /, $lines);
				$validity_test = $#a + $validity_test;
				if ($#a != 9) {
					$abort++;
					print "$tempfile is missing\n";
					last;
				}
				for ($i=0; $i<$#a+1; $i++) {
					$value[$i] = $value[$i] + $a[$i];
					if ($k == 4) {
						$value[$i] = $value[$i] / $four[$i];
					}
				}
			} 
			#print OUTPUT "@value\n";
			print GPT "$value[$#value]\n";
		}
	}
	if($abort > 0){
		print "Joining is unable to concatenate mcs=$mcs[$m], because some files are missing!\n";
		system ("rm",  $resultfile);
		break;
	}
	#close(OUTPUT);
	close(GPT);
	if ($validity_test == 18000) {
	print "mcs $mcs[$m] has correctly been fulfilled.\n";
	}
}






