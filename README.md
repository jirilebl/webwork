# Basic Analysis problems

In the *rahw/* directory, there are problems for the *Basic Analysis* textbook volume I.  Read the *README.md* in that directory.

# Webwork problems

These are problems that for whatever reason I am not pushing into the OPL Contrib directory, templates for my own use (though of course feel free to use them), and a few scripts for working with webwork.

There are no guarantees here

*test-pg-file.pl* is a very rudimentary check that a pg file contains some of the most basic elements it should.  Prints out the name of the file if it fails.

*test-pg-files.sh* run the above in all the subdirectories of the given directory.  Just a simple find command, needs to be run from the same directory as the one that contains the above .pl file.  Prints out the names of the offending files.

*convert-to-webwork.pl* is a script that converts the D2L grade export into something that can be imported into webwork.
It probably requires modification if you want to use it yourself as it depends on exactly how you export with what fields, etc...
