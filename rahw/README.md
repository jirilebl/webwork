# Basic Analysis Problems

A set of WeBWorK problems for courses teaching a class with the
*Basic Analysis* textbook volume I (and a few for volume II).  The idea is not
to replace written homework but to supplement it.  There is some overlap in
these problems and some of the problems in the book.  There are a lot of
True/false questions and some multiple choice questions.  Then there are many
problems where a proof is supposed to be constructed by drag and drop.  Finally
there are a few problems where a proof is taken from the book (sometimes
lightly edited) and control questions are asked throughout.

For volume I, coverage is more or less reasonable for the non-optional bits,
with at least 2-3 questions per section (more for ones that take longer).
A couple of sections only have 1 problem (3.6, 4.4, 5.4, 5.5).

When I ran the course in Fall 2021, I covered non-optional bits of chapters 0-5
and chapter 7 (without Picard) and I had 6 of these problems per week the whole
semester, and I am doing almost the same thing in Fall 2022.  The problems
in those sections have been class tested, and the feedback from students has
been positive.  There are a few problems in the sections I did not cover that
have not been class tested yet.  So use with a bit of care.

Volume II problems are quite a bit more sparse and kind of a work in progress,
I have used them in Spring 2022 (with an extremely small class) and 
I am using them (and writing a few new ones) in Spring 2023 (with a larger
class).

## How to use?

To use, download https://www.jirka.org/ra/rahw.tgz and upload it to your
WeBWorK course.  It should automatically unpack and create the right directory
structure.  Then in the homework editor go to import and then import sets using
the "def" files from the diffyqs-webwork directory.  Alternatively go to
library browser, look into the rahw directory, and pick problems one
by one.

The proof problems require draggableProof.pl to work (from WeBWorK 2.16 onwards
this should work automatically, with an older version you must install the
draggableProof.pl macro manually).  I first tested on 2.14 with the macro
manually installed, and now I'm testing with 2.17.

## Where did the problems come from?

All the problems were written from scratch.  They were all written using a
simple helper script (*story-proof-template-maker.pl*) which takes an input
file (the .in files) and produces the WebWorK problem file (.pg file).  The
script and the problems can be gotten from my scratchwork webwork github
repository https://github.com/jirilebl/webwork

## Contributing

Let me know if you have any fixes, new problems, or suggestions.
If you figure out how to modify the .in files in the repository you can
just send pull requests.
