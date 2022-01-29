#!/usr/bin/perl
#
# See storyexample.in for an example.  Then run
# ./story-proof-template-maker.pl storyexample.in > out.pg
#

# This allows includes into headers with %HINC, this is not safe
# for a webscript so here is where it is easy to disable.
$allowinc = 1;

my $in;

if ($#ARGV >= 0) {
	open($in, '<', $ARGV[0]) or die $!;
} else {
	$in  = *STDIN;
}

$qnum = 0;
$qcheckers[0] = "";

$partialanswers = 1;
$nopartialcredit = 0;

$haveproofs = 0;
$haveradios = 0;
$havecheckboxes = 0;

$formulas = 0;
$numbers = 0;
$matrices = 0;

$rulewidth = 0;

$out = "";

$setvars = "";
$setup = "";
$header = "";

$insolution = 0;


while ($line = <$in>) {
	$line =~ s/[\r\n]+//;
	chomp($line);
	if ($line eq "%NOPARTIALANSWERS") {
		$partialanswers = 0;
	} elsif ($line eq "%NOPARTIALCREDIT") {
		$nopartialcredit = 1;
	} elsif ($line eq "%NOPARTIAL") {
		$partialanswers = 0;
		$nopartialcredit = 1;
	} elsif ($line =~ m/^%DESC[ \t]*(.*)$/) {
		$header .= "##DESCRIPTION\n## $1\n##ENDDESCRIPTION\n\n";
	# If making an online version, this needs to be removed
	} elsif ($allowinc and $line =~ m/^%HINC[ \t]*(.*)$/) {
		if (open(my $headin, '<', $1)) {
			$header .= do { local $/; <$headin> };
			close($headin);
		}
	} elsif ($line =~ m/^%H *(.*)$/) {
		$header .= "$1\n";
	} elsif ($insolution == 0 and $line =~ m/^%PROOF/) {
		$haveproofs = 1;
		if ($line =~ m/^%PROOFHINT/) {
			$hint = 1;
		} else {
			$hint = 0;
		}
		$qnum++;
		$qcheckers[$qnum-1]="ANS(\$q$qnum\->cmp());\n";
		$out .= << "EOF";
END_TEXT
Context()->normalStrings;

\$q$qnum = DraggableProof([
EOF
		$gotextra = 0;
		while ($line = <$in>) {
			$line =~ s/[\r\n]+//;
			chomp($line);
			if ($line =~ m/^%EXTRA/) {
				$gotextra = 1;
				$out .= "],\n[\n";
			} elsif ($line =~ m/^%END/) {
				if ($gotextra == 0) {
					$out .= "],\n[";
				}
				$out .= << "EOF";
],

SourceLabel => \"Choose from these statements\",
TargetLabel =>  \"The proof\",
);

Context()->texStrings;
BEGIN_TEXT

EOF
				if ($hint) {
					$out .= << "EOF";
\$BITALIC (Drag \\{ \$q$qnum->numNeeded \\} statements from the left column
to the right, putting them in the correct order.) \$EITALIC
EOF
				} else {
					$out .= << "EOF";
\$BITALIC (Drag the statements from the left column
to the right, putting them in the correct order.  There could be extras.) \$EITALIC
EOF
				}
				$out .= << "EOF";

\\{ \$q$qnum\->Print \\}

EOF
				last;
			} elsif ($line eq "") {
				# Do nothing on empty line
			} else {
				$line =~ s/"/\\"/g;
				$out .= "\"$line\",\n";
			}
		}
	} elsif ($insolution == 0 and $line =~ m/^%RADIO/) {
		$qnum++;
		$qcheckers[$qnum-1]="ANS(\$q$qnum\->cmp());\n";
		$haveradios = 1;
		$correct = "";
		$inrandom = 0;
		$optnum = 0;
		if ($line =~ m/^%RADIORANDOM/) {
			$inrandom = 1;
		}
		$out .= << "EOF";
END_TEXT
Context()->normalStrings;

\$q$qnum = RadioButtons([
EOF
		if ($inrandom == 1) {
			$out .= "[\n";
		}

		while ($line = <$in>) {
			$line =~ s/[\r\n]+//;
			chomp($line);
			if ($line =~ s/^%CORRECT *//) {
				$line =~ s/"/\\"/g;
				$out .= "\"$line\",\n";
				$correct = $line;
				$optnum++;
			} elsif ($inrandom == 0 and $line =~ m/^%BEGINRANDOM/) {
				$out .= "[\n";
				$inrandom = 1;
			} elsif ($inrandom == 1 and $line =~ m/^%ENDRANDOM/) {
				$out .= "],\n";
				$inrandom = 0;
			} elsif ($line =~ m/^%END/) {
				if ($inrandom == 1) {
					$out .= "],\n";
					$inrandom = 0;
				}
				$out .= << "EOF";
],
\"$correct\",
);
Context()->texStrings;
BEGIN_TEXT
\\{ \$q$qnum\->buttons \\}

EOF
				last;
			} elsif ($line eq "") {
				# Do nothing on empty line
			} else {
				$line =~ s/"/\\"/g;
				$out .= "\"$line\",\n";
				$optnum++;
				if ($optnum == 1) {
					# The first guy is taken as correct
					$correct = $line;
				}
			}
		}
	} elsif ($insolution == 0 and $line =~ m/^%CHECKBOXES/) {
		$qnum++;
		$qcheckers[$qnum-1]="ANS(checkbox_cmp(\$q$qnum\->correct_ans()));\n";
		$havecheckboxes = 1;
		$thelast = "";
		$out .= << "EOF";
END_TEXT
Context()->normalStrings;

\$q$qnum = new_checkbox_multiple_choice();
\$q$qnum\->qa("Check all that apply",
EOF

		while ($line = <$in>) {
			$line =~ s/[\r\n]+//;
			chomp($line);
			if ($line =~ m/^%EXTRA/) {
				$out .= ");\n\$q$qnum\->extra(\n";
			} elsif ($line =~ m/^%END/) {
				$out .= ");\n";
				if ($thelast ne "") {
					$out .= "\$q$qnum\->makeLast(\"$thelast\");\n";
				}
				$out .= << "EOF";
Context()->texStrings;
BEGIN_TEXT
\\{ \$q$qnum\->print_a() \\}

EOF
				last;
			} elsif ($line eq "") {
				# Do nothing on empty line
			} elsif ($line =~ s/^%LAST *//) {
				$line =~ s/"/\\"/g;
				$out .= "\"$line\",\n";
				$thelast = $line;
			} else {
				$line =~ s/"/\\"/g;
				$out .= "\"$line\",\n";
			}
		}
	} elsif ($line =~ m/^%SETUP[ \t][ \t]*(.*)$/ or $line =~ m/^%S[ \t][ \t]*(.*)$/) {
		$setup .= "$1\n";
	} elsif ($insolution == 0 and $line =~ m/^%RULEWIDTH[ \t][ \t]*([0-9]*)$/) {
		$rulewidth = int($1);
	} elsif ($insolution == 0 and $line =~ m/^%NUMBER[ \t][ \t]*(.*)$/) {
		$qnum++;
		$qcheckers[$qnum-1]="ANS(\$q$qnum\->cmp());\n";
		$numbers++;
		$answer = $1;
		$rw = 20;
		if ($rulewidth > 0) {
			$rw = $rulewidth;
		}
		$out .= << "EOF";
END_TEXT
Context()->normalStrings;

\$q$qnum = Formula(\"$answer\");

Context()->texStrings;
BEGIN_TEXT
\\{ ans_rule($rw) \\}
\\{ AnswerFormatHelp("numbers") \\}
EOF
	} elsif ($insolution == 0 and $line =~ m/^%MATRIX[ \t][ \t]*(.*)$/) {
		$qnum++;
		$qcheckers[$qnum-1]="ANS(\$q$qnum\->cmp());\n";
		$matrices++;
		$answer = $1;
		$rw = 10;
		if ($rulewidth > 0) {
			$rw = $rulewidth;
		}
		$out .= << "EOF";
END_TEXT
Context()->normalStrings;

\$q$qnum = Compute(\"$answer\");

Context()->texStrings;
BEGIN_TEXT
\\{ \$q$qnum->ans_array($rw) \\}
\\{ AnswerFormatHelp("matrices") \\}
EOF
	} elsif ($insolution == 0 and $line =~ m/^%FORMULAVARS[ \t][ \t]*([a-zA-Z,]*)[ \t]*$/) {
		$vars = $1;
		$vars =~ s/,$//;
		$vars =~ s/,/=>"Real",/g;
		$vars .= "=>\"Real\"";
		$setvars = "Context()->variables->are($vars);\n"
	} elsif ($insolution == 0 and $line =~ m/^%FORMULA[ \t][ \t]*(.*)$/) {
		$qnum++;
		$qcheckers[$qnum-1]="ANS(\$q$qnum\->cmp());\n";
		$formulas++;
		$answer = $1;
		$rw = 40;
		if ($rulewidth > 0) {
			$rw = $rulewidth;
		}
		$out .= << "EOF";
END_TEXT
Context()->normalStrings;

\$q$qnum = Formula(\"$answer\");

Context()->texStrings;
BEGIN_TEXT
\\{ ans_rule($rw) \\}
\\{ AnswerFormatHelp("formulas") \\}
EOF
	} elsif ($insolution == 0 and $line =~ m/^%STRING[ \t][ \t]*(.*)$/) {
		$answer = $1;
		$answer =~ s/"/\\"/g;
		$qnum++;
		$qcheckers[$qnum-1]="ANS(str_cmp(\"$answer\"));\n";
		$rw = 40;
		if ($rulewidth > 0) {
			$rw = $rulewidth;
		}
		$out .= "\\{ ans_rule($rw) \\}\n";
	} elsif ($line eq "%SOLUTION") {
		$out .= << "EOF";
END_TEXT
Context()->normalStrings;

Context()->texStrings;
BEGIN_SOLUTION
EOF
		$insolution = 1;
	} elsif ($line eq "%") {
		# do nothing
	} elsif ($line eq "") {
		$out .= "\$PAR\n";
	} else {
		$out .= "$line\n";
	}
}


# Print header
if ($header ne "") {
	print $header;
	print "\n";
	print "######################################################\n\n";
}

print << "EOF";
DOCUMENT();

loadMacros(
 \"PGstandard.pl\",
 \"MathObjects.pl\",
 \"AnswerFormatHelp.pl\",
EOF

if ($haveproofs) {
	 print " \"draggableProof.pl\",\n";
}
if ($haveradios) {
	 print " \"parserRadioButtons.pl\",\n";
}
if ($havecheckboxes) {
	 print " \"PGchoicemacros.pl\",\n";
}

$ctx = "Numeric";
if ($matrices > 0) {
	$ctx = "Matrix";
}

print << "EOF";
 \"PGcourse.pl\",
);

TEXT(beginproblem());

###########################
# Setup

\$showPartialCorrectAnswers = $partialanswers;

Context(\"$ctx\");

$setvars
$setup
############################
# Main text

Context()->texStrings;
BEGIN_TEXT
\$PAR
EOF

# print the collected stuff
print $out;

# print "footer"
if ($insolution == 1) {
	print "\nEND_SOLUTION\n";
} else {
	print "\nEND_TEXT\n";
}
print << 'EOF';
Context()->normalStrings;

############################
# Answers

EOF

if ($nopartialcredit) {
	print("install_problem_grader(~~&std_problem_grader);\n\n");
}

for (my $i=0; $i < $qnum; $i++) {
	print($qcheckers[$i]);
}

print("\nENDDOCUMENT();\n");

close($in);
