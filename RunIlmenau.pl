#!/usr/local_rwth/bin/perl -w

#############################################################################
## Script for joining simulation data                                      ##
#############################################################################
## (c) Ehsan Zandi, April 2012 		                                   ##
##     ehsan.zandi@rwth-aachen.de                                          ##
##     Institute of Communication Systems and Data Processing, RWTH Aachen ##
#############################################################################

# if($#ARGV+1 != 2)
# {
# 	print "too few arguments\n";
#         print "should be:\n";
#         print "checkAndJoin.pl filename #files\n";
#         print "Read help_en.txt for further informations.\n";
# 	die;
# }

#$nbFiles = $ARGV[1];
$steps = 100; 
$sim_name = "IlmenauSim";
$memory = "512";
$timePerStep = "23";
@mcs = (213,413,613,212,412,612,223,423,623,234,434,634,256,456,656,278,478,678);
@dBbase = (-10,0,10,20,30);

$BS = "BS1_1";
$track = "MT12b-12c";
$Name = "LTE_ILM_".$BS."_".$track; 
$time_h       = int($timePerStep);
$time_min     = 0;

system ("rm *.args *.sh output* core*");
$pwd = `pwd`;
chop($pwd);

$count_missing = 0;

for ($m = 0; $m <=$#mcs; $m++) {
			$base_filename = $Name."_".$mcs[$m];
			#$resultfile = $base_filename;
			#for ($q = 0; $q<5; $q++){
			for ($q = 0; $q <$#dBbase+1; $q++){
				for(my $d=0; $d < $steps; $d++){
					#$dBbase = -10+10*$q ;
					for($w=1; $w<5; $w++) {
						$tempfile = $base_filename."_".$dBbase[$q]."_".$d."_".$w;
						#print "$resultfile\n" ;
						#$check = $tempfile;
						if (-e $tempfile) {
							open (TEMPFILE, "<$tempfile")
							or die "could not open file $tempfile\n";
							my $lines = <TEMPFILE>;
							@a = split(/     /, $lines);
							close(TEMPFILE); 
							if ($#a != 9) {
								system ("rm $tempfile");
								#print "$tempfile is empty\n";
							}
						}
						unless (-e $tempfile) {
							$count_missing++;
							$index = int( ($count_missing-1) / 100)+1;
							$currentdB = $dBbase[$q] + $d/10;
							$arg = "25 4 10 ".$mcs[$m]." ".$BS."_".$track." " .$currentdB." 0 ".$currentdB." ".$tempfile;
							$filename_args = "LTE_".$index.".args";							
							print "$count_missing files are missing in total.\n";
							open(ARGS, ">>$filename_args");
							print ARGS "$arg\n" ;
							close(ARGS);
						} #end of unless
					}#end of for($w ... )
				}#end of for ($d .... )
			}#end of for ($q ....)
}#end of for($mcs ...)

for($i=1; $i<=$index; $i++)
{
	$job_number = 100;
	$filename_args = "LTE_".$i.".args";	
	$filename_job = "LTE_".$i.".sh";													
	if ($i == $index)
	{
		$job_number = 100+$count_missing-100*$index;
	}
	open(JOB, ">LTE_$i.sh");
	print JOB "#!/usr/bin/env zsh\n\n";
	print JOB "### Job name\n";
	print JOB "#BSUB -J LTE_$i"."[1-"."$job_number"."]\n\n";
	#print JOB "### File / path where STDOUT will be written\n";
	#print JOB "#BSUB -o $base_filename"."\%I.\%J\n\n";
	print JOB "### Execution time\n";
	print JOB "#BSUB -W $time_h".":$time_min"."\n\n";
	print JOB "### Memory usage\n";
	print JOB "#BSUB -M $memory"."\n\n";
	print JOB "### Change to the work directory\n";
	print JOB "cd \"$pwd\"\n\n";
	print JOB "### Execute the application\n";
	print JOB "argcurrent=`sed -n \"\$LSB_JOBINDEX p\" $filename_args`\n";
	print JOB "$sim_name \$argcurrent\n";
	close(JOB);
	system("bsub < $filename_job") == 0 or die "system bsub < $filename_job failed: $?";
}
