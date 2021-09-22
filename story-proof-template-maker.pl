#!/usr/bin/perl
#
# See storyexample.in for an example.  Then run
# ./story-proof-template-maker.pl storyexample.in > out.pg
#

open(my $in, '<', $ARGV[0]) or die $!;

$qnum = 0;

$partialanswers = 1;
$nopartialcredit = 0;

$haveproofs = 0;
$haveradios = 0;

$formulas = 0;
$numbers = 0;

$out = "";

$setvars = "";
$setup = "";

while ($line = <$in>) {
	chomp($line);
	if ($line =~ m/^%NOPARTIALANSWERS/) {
		$partialanswers = 0;
	} elsif ($line =~ m/^%NOPARTIALCREDIT/) {
		$nopartialcredit = 1;
	} elsif ($line =~ m/^%PROOF/) {
		$haveproofs = 1;
		if ($line =~ m/^%PROOFHINT/) {
			$hint = 1;
		} else {
			$hint = 0;
		}
		$qnum++;
		$out .= << "EOF";
END_TEXT
Context()->normalStrings;

\$q$qnum = DraggableProof([
EOF
		$gotextra = 0;
		while ($line = <$in>) {
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
			} else {
				$out .= "\"$line\",\n";
			}
		}
	} elsif ($line =~ m/^%RADIO/) {
		$qnum++;
		$haveradios = 1;
		$correct = "";
		$out .= << "EOF";
END_TEXT
Context()->normalStrings;

\$q$qnum = RadioButtons([
EOF
		while ($line = <$in>) {
			chomp($line);
			if ($line =~ s/^%CORRECT *//) {
				$out .= "\"$line\",\n";
				$correct = $line;
			} elsif ($line =~ m/^%BEGINRANDOM/) {
				$out .= "[\n";
			} elsif ($line =~ m/^%ENDRANDOM/) {
				$out .= "],\n";
			} elsif ($line =~ m/^%END/) {
				$out .= << "EOF";
],
\"$correct\",
);
Context()->texStrings;
BEGIN_TEXT
\\{ \$q$qnum\->buttons \\}

EOF
				last;
			} else {
				$out .= "\"$line\",\n";
			}
		}
	} elsif ($line =~ m/^%SETUP[ \t]*(.*)$/) {
		$setup .= "$1\n";
	} elsif ($line =~ m/^%NUMBER [ \t]*(.*)$/) {
		$qnum++;
		$numbers++;
		$answer = $1;
		$out .= << "EOF";
END_TEXT
Context()->normalStrings;

\$q$qnum = Formula(\"$answer\");

Context()->texStrings;
BEGIN_TEXT
\\{ ans_rule(20) \\}
\\{ AnswerFormatHelp("numbers") \\}
EOF
	} elsif ($line =~ m/^%FORMULAVARS ([a-zA-Z,]*)[ \t]*$/) {
		$vars = $1;
		$vars =~ s/,$//;
		$vars =~ s/,/=>"Real",/g;
		$vars .= "=>\"Real\"";
		$setvars = "Context()->variables->are($vars);\n"
	} elsif ($line =~ m/^%FORMULA [ \t]*(.*)$/) {
		$qnum++;
		$formulas++;
		$answer = $1;
		$out .= << "EOF";
END_TEXT
Context()->normalStrings;

\$q$qnum = Formula(\"$answer\");

Context()->texStrings;
BEGIN_TEXT
\\{ ans_rule(40) \\}
\\{ AnswerFormatHelp("formulas") \\}
EOF
	} elsif ($line eq "%BR") {
		$out .= "\$BR\n";
	} elsif ($line eq "") {
		$out .= "\$PAR\n";
	} else {
		$out .= "$line\n";
	}
}


# Print header
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

print << "EOF";
 \"PGcourse.pl\",
);

TEXT(beginproblem());

###########################
# Setup

\$showPartialCorrectAnswers = $partialanswers;

Context(\"Numeric\");

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

#print "footer"
print << 'EOF';

END_TEXT
Context()->normalStrings;

##############################################################
#  Answers

EOF

if ($nopartialcredit) {
	print("install_problem_grader(~~&std_problem_grader);\n\n");
}

for (my $i=1; $i <= $qnum; $i++) {
	print("ANS(\$q$i\->cmp());\n");
}

print("\nENDDOCUMENT();\n");
