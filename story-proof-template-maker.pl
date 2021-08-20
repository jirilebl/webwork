#!/usr/bin/perl
#
# See storyexample.in for an example.  Then run
# ./story-proof-template-maker.pl storyexample.in > out.pg
#

open(my $in, '<', $ARGV[0]) or die $!;

$qnum = 0;

print << 'EOF';
DOCUMENT();

loadMacros(
 "PGstandard.pl",
 "MathObjects.pl",
 "AnswerFormatHelp.pl",
 "draggableProof.pl",
 "parserRadioButtons.pl",
 "PGcourse.pl",
);

TEXT(beginproblem());

###########################
# Setup

$showPartialCorrectAnswers = 1;

Context("Numeric");

############################
# Main text

Context()->texStrings;
BEGIN_TEXT
EOF

while ($line = <$in>) {
	chomp($line);
	if ($line =~ m/^%PROOF/) {
		if ($line =~ m/^%PROOFHINT/) {
			$hint = 1;
		} else {
			$hint = 0;
		}
		$qnum++;
		print << "EOF";
END_TEXT
Context()->normalStrings;

\$q$qnum = DraggableProof([
EOF
		$gotextra = 0;
		while ($line = <$in>) {
			chomp($line);
			if ($line =~ m/^%EXTRA/) {
				$gotextra = 1;
				print("],\n[\n");
			} elsif ($line =~ m/^%END/) {
				if ($gotextra == 0) {
					print("],\n[");
				}
				print << "EOF";
],

SourceLabel => \"Choose from these statements\",
TargetLabel =>  \"The proof\",
);

Context()->texStrings;
BEGIN_TEXT

EOF
				if ($hint) {
					print << "EOF";
\$BITALIC (Drag \\{ \$q$qnum->numNeeded \\} statements from the left column
to the right, putting them in the correct order.) \$EITALIC
EOF
				} else {
					print << "EOF";
\$BITALIC (Drag the statements from the left column
to the right, putting them in the correct order.  There could be extras.) \$EITALIC
EOF
				}
				print << "EOF";

\\{ \$q$qnum\->Print \\}

EOF
				last;
			} else {
				print("\"$line\",\n");
			}
		}
	} elsif ($line =~ m/^%RADIO/) {
		$qnum++;
		$correct = "";
		print << "EOF";
END_TEXT
Context()->normalStrings;

\$q$qnum = RadioButtons([
EOF
		while ($line = <$in>) {
			chomp($line);
			if ($line =~ s/^%CORRECT *//) {
				print("\"$line\",\n");
				$correct = $line;
			} elsif ($line =~ m/^%BEGINRANDOM/) {
				print("[\n");
			} elsif ($line =~ m/^%ENDRANDOM/) {
				print("],\n");
			} elsif ($line =~ m/^%END/) {
				print << "EOF";
],
\"$correct\",
);
Context()->texStrings;
BEGIN_TEXT
\\{ \$q$qnum\->buttons \\}

EOF
				last;
			} else {
				print("\"$line\",\n");
			}
		}
	} elsif ($line eq "%BR") {
		print("\$BR\n");
	} elsif ($line eq "") {
		print("\n\$PAR\n\n");
	} else {
		print("$line\n");
	}
}

print << 'EOF';

END_TEXT
Context()->normalStrings;

##############################################################
#  Answers

EOF

for (my $i=1; $i <= $qnum; $i++) {
	print("ANS(\$q$i\->cmp());\n");
}

print("\nENDDOCUMENT();\n");
