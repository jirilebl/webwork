#!/bin/sh
for n in `ls -1d ra_* | sort -V` ; do
	printf '%-10s %2d exercises (%d from .in files)\n' "$n" `ls -1 $n/*.pg | wc -l` `ls -1 $n/*.in | wc -l`
done

echo
echo Total: `ls -1 */*.pg | wc -l` exercises
echo Total .in files: `ls -1 */*.in | wc -l` exercises
