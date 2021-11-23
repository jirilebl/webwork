# Basic Analysis Problems

A set of WeBWorK problems for courses teaching a class with the
*Basic Analysis* textbook volume I.  The idea is not to replace written
homework but to supplement it.  There is some overlap in these problems and
some of the problems in the book.  There are a lot of True/false questions and
some multiple choice questions.  Then there are many problems where a proof is
supposed to be constructed by drag and drop.  Finally there are a few problems
where a proof is taken from the book (sometimes lightly edited) and control
questions are asked throughout.

Coverage is more or less reasonable for the non-optional bits, trying to
get at least 2-3 questions per section (more for ones that take longer).
A few sections only have 1 problem (3.5, 3.6, 4.4, 6.2) and a few sections
do not yet have any problems yet (5.4, 5.5, 6.3, 7.6).

When I ran the course in Fall 2021, I covered non-optional bits of chapters
0-5 and chapter 7 (without Picard) and I had 6 problems per week the whole
semester.  Those problems have been class tested.  Note that there are a few
problems in the other sections that I didn't conver that have not been class
tested yet.

## How to use?

To use, download https://www.jirka.org/ra/rahw.tgz and upload it to your
WeBWorK course.  It should automatically unpack and create the right directory
structure.  Then in the homework editor go to import and then import sets using
the "def" files from the diffyqs-webwork directory.  Alternatively go to
library browser, look into the rahw directory, and pick problems one
by one.

The proof problems require draggableProof.pl to work (from WeBWorK 2.16
onwards this should work automatically, with an older version you
must install the draggableProof.pl macro manually).  I'm testing on 2.14
with the macro manually installed.

## Where did the problems come from?

All the problems were written from scratch.  They were for the most part
written with a simple helper script (*story-proof-template-maker.pl*).
The script and the problem can be gotten from my scratchwork webwork github
repository https://github.com/jirilebl/webwork

## Contributing

Let me know if you have any fixes, or new problems, or suggestions.
If you figure out how to modify the .in files in the repository you can
just send pull requests.