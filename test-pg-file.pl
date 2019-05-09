#!/usr/bin/perl

open(my $in, '<', $ARGV[0]) or die $!;


$indoc = 0;
$gotbeginproblem = 0;
$gotinclude = 0;
$gotPGcourse = 0;

while ($line = <$in>) {
	if ($line =~ m/^ *DOCUMENT/) {
		if ($indoc != 0) {
			#print("$ARGV[0] ... DOCUMENT out of place\n");
			print("$ARGV[0]\n");
			exit(1);
		}
		$indoc ++;
	} elsif ($line =~ m/^ *ENDDOCUMENT/) {
		if ($indoc != 1) {
			#print("$ARGV[0] ... ENDDOCUMENT out of place\n");
			print("$ARGV[0]\n");
			exit(1);
		}
		$indoc ++;
	} elsif ($line =~ m/beginproblem/) {
		$gotbeginproblem++;
	} elsif ($line =~ m/^ *includePGproblem/) {
		$gotinclude++;
	} elsif ($line =~ m/PGcourse.pl/) {
		$gotPGcourse++;
	}
}

if ($indoc != 2) {
	print("$ARGV[0]\n");
	#print("$ARGV[0] ... DOCUMENT/ENDDOCUMENT missing\n");
	exit(1);
}

if ($gotbeginproblem == 0 and $gotinclude == 0) {
	#print("$ARGV[0] ... no beginproblem and not an include\n");
	print("$ARGV[0]\n");
	exit(1);
}

if ($gotPGcourse == 0 and $gotinclude == 0) {
	#print("$ARGV[0] ... no PGcourse.pl and not an include\n");
	print("$ARGV[0]\n");
	exit(1);
}

exit(0);
