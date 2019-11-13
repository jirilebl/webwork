#!/usr/bin/perl

open(my $in, '<', $ARGV[0]) or die $!;

$taxonomy_file = "~/gh/webwork-open-problem-library/OpenProblemLibrary/Taxonomy";

@f = glob($taxonomy_file);

if (scalar (@f) != 1) {
	print (STDERR "Can't open/find $taxonomy_file with the taxonomy, you might want to edit the script\n");
	exit(2);
}

$taxonomy_file = @f[0];

sub is_in_taxonomy {
	open(my $taxin, '<', $taxonomy_file) or die $!;

	my $x = $_[0];

	my $ln;
	while ($ln = <$taxin>) {
		if ($ln =~ m/^[ \t]*\Q$x\E[ \t]*$/) {
			close($taxin);
			return 1;
		}
	}
	close($taxin);
	return 0;
}


$indoc = 0;
$gotbeginproblem = 0;
$gotinclude = 0;
$gotPGcourse = 0;
$gotDBsubj = 0;
$gotDBch = 0;
$gotDBsec = 0;

$result = 0;

$resources = "";
@images = ();

while ($line = <$in>) {
	if ($line =~ m/^ *&?DOCUMENT/) {
		if ($indoc != 0) {
			print(STDERR "$ARGV[0] ... DOCUMENT out of place\n");
			$result++;
		}
		$indoc ++;
	} elsif ($line =~ m/^ *&?ENDDOCUMENT/) {
		if ($indoc != 1) {
			print(STDERR "$ARGV[0] ... ENDDOCUMENT out of place\n");
			$result++;
		}
		$indoc ++;
	} elsif ($line =~ m/^[^#]*beginproblem/) {
		$gotbeginproblem++;
	} elsif ($line =~ m/^ *includePGproblem/) {
		$gotinclude++;
	} elsif ($line =~ m/^[^#]*['"]PGcourse.pl['"]/) {
		$gotPGcourse++;
	} elsif ($line =~ m/^[ \t]*#+[ \t]*RESOURCES/) {
		$resources = $line;
	} elsif ($line =~ m/^[ \t]*#+[ \t]*DBsubject\( *'*ZZZ/ or
		 $line =~ m/^[ \t]*#+[ \t]*DBchapter\( *'*ZZZ/ or
		 $line =~ m/^[ \t]*#+[ \t]*DBsection\( *'*ZZZ/) {
		exit(0);
	} elsif ($line =~ m/^[ \t]*#+[ \t]*DBsubject\( *'(.*?)' *\)[ \t]*$/ or
		 $line =~ m/^[ \t]*#+[ \t]*DBsubject\( *(.*?) *\)[ \t]*$/) {
		my $subj = $1;
		#print "subj>$subj\n";
		if (not is_in_taxonomy($subj)) {
			print(STDERR "$ARGV[0] ... DBsubject $subj not in taxonomy\n");
			$result++;
		}
		$gotDBsubj++;
	} elsif ($line =~ m/^[ \t]*#+[ \t]*DBchapter\( *'(.*?)' *\)[ \t]*$/ or
		 $line =~ m/^[ \t]*#+[ \t]*DBchapter\( *(.*?) *\)[ \t]*$/) {
		my $subj = $1;
		#print "ch>$subj\n";
		if (not is_in_taxonomy($subj)) {
			print(STDERR "$ARGV[0] ... DBchapter $subj not in taxonomy\n");
			$result++;
		}
		$gotDBch++;
	} elsif ($line =~ m/^[ \t]*#+[ \t]*DBsection\( *'(.*?)' *\)[ \t]*$/ or
		 $line =~ m/^[ \t]*#+[ \t]*DBsection\( *(.*?) *\)[ \t]*$/) {
		my $subj = $1;
		#print "sec>$subj\n";
		if (not is_in_taxonomy($subj)) {
			print(STDERR "$ARGV[0] ... DBsection $subj not in taxonomy\n");
			$result++;
		}
		$gotDBsec++;
	} elsif ($line =~ m/^[^#]*image[ \t]*\([ \t]*['"]([^'"]*)['"]/) {
		push(@images,$1);
	}
}

if ($indoc != 2) {
	print(STDERR "$ARGV[0] ... DOCUMENT/ENDDOCUMENT missing\n");
	$result++;
}

if ($gotbeginproblem == 0 and $gotinclude == 0) {
	print(STDERR "$ARGV[0] ... no beginproblem and not an include\n");
	$result++;
}

if ($gotbeginproblem > 1) {
	print(STDERR "$ARGV[0] ... more than one beginproblem\n");
	$result++;
}

if ($gotPGcourse == 0 and $gotinclude == 0) {
	print(STDERR "$ARGV[0] ... no PGcourse.pl and not an include\n");
	$result++;
}

if ($gotPGcourse > 1) {
	print(STDERR "$ARGV[0] ... more than one PGcourse.pl\n");
	$result++;
}

if ($gotDBsubj > 1) {
	print(STDERR "$ARGV[0] ... More than one DBsubject\n");
	$result++;
}

if ($gotDBch > 1) {
	print(STDERR "$ARGV[0] ... More than one DBchapter\n");
	$result++;
}

if ($gotDBsec > 1) {
	print(STDERR "$ARGV[0] ... More than one DBsection\n");
	$result++;
}

if ($gotDBsubj < 1) {
	print(STDERR "$ARGV[0] ... No DBsubject\n");
	$result++;
}

if ($gotDBch < 1) {
	print(STDERR "$ARGV[0] ... No DBchapter\n");
	$result++;
}

if ($gotDBsec < 1) {
	print(STDERR "$ARGV[0] ... No DBsection\n");
	$result++;
}

foreach (@images) {
	$image = $_;
	if (index($resources, "'$image'") == -1 and
	    index($resources, '"$image"') == -1) {
		print(STDERR "$ARGV[0] ... $image not found in RESOURCES (or no RESOURCES)\n");
		$result++;
	}
}

if ($result > 0) {
	print("$ARGV[0]\n");
	exit(1);
}

exit(0);
