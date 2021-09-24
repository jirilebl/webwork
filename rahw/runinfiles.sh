#!/bin/sh

for n in ra_* ; do
	cd $n
	echo
	echo '=================='
	echo dir $n
	if ls *.in 1> /dev/null 2>&1; then
		echo .in files found
		for m in *.in ; do
			mm=`basename $m .in`.pg
			echo baking $m into $mm
			../../story-proof-template-maker.pl $m > $mm
		done
	fi
	cd ..
done
