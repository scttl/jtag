#!/usr/bin/perl -w
################################################################################
##
## FILE: extract_stable.pl
##
## CVS: $Id: extract_stable.pl,v 1.2 2003-06-04 22:36:16 scottl Exp $
##
## DESCRIPTION: Perl script to exctract, convert and print a list of Stable URLs
##              found searching all html files below the $SRC directory
##
################################################################################

use strict;


## VARIABLES ##
###############

my $dirname = "./science";  # directory to start looking for html files in.
my $file;                   # current file to be looked at.
my $line;                   # current line being inspected
my $regexp = "(.*)(Stable URL: .*)(links.jstor.org.*)(</nobr>.*)";  

#go through each file in the current directory
opendir(DIR, $dirname) or die "can't opendir $dirname: $!";
while (defined($file = readdir(DIR))) {

  #open and parse the file
  open(FILE, "$dirname/$file") or die "can't open file $dirname/$file: $!";

  #parse the file looking for $regexp
  foreach $line (<FILE>) {

    if ($line =~ $regexp) {

      #$line contains $regexp, substitute it using $replace as a guide
      $_ = $line;

      s/$regexp/http:\/\/$3/;  ## \3 refers to the 3rd portion of the file.

      print STDOUT $_;

    }

  }

  close(FILE);
    
}
closedir(DIR);
