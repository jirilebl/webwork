#!/bin/sh
find $1 -name '*.pg' -exec ./test-pg-file.pl '{}' ';'

