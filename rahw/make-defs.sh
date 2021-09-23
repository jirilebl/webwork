#!/bin/sh

for n in ra_* ; do
	echo "openDate = 01/01/19, 0600" > "set$n.def"
	echo "dueDate = 01/01/29, 2359" >> "set$n.def"
	echo "answerDate = 01/01/29, 2359" >> "set$n.def"
	echo "problemList =" >> "set$n.def"
	for m in `ls $n/*.pg` ; do
		echo "rahw/$m,	1" >> "set$n.def"
	done
done
