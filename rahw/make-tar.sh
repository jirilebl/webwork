#!/bin/sh

rm -i rahw.tgz
cd ..
#GZIP=-9 tar cvzf rahw.tgz --sort=name --exclude=".*" --exclude="*.in" --exclude="make-defs.sh" --exclude="make-tar.sh" --exclude="runinfiles.sh" rahw/
GZIP=-9 tar cvzf rahw.tgz --sort=name --exclude=".*" rahw/
mv rahw.tgz rahw/
