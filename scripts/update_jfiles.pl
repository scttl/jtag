#!/usr/bin/perl -w
################################################################################
##
## FILE: update_jfiles.pl
##
## CVS: $Id: update_jfiles.pl,v 1.2 2006-01-25 20:23:53 scottl Exp $
##
## DESCRIPTION: script that attempts to convert the img tag in jtag and jlog
## files by replacing it with its full path if it is found in the same directory
## as the jtag/jlog file.  If the image file specified can not be found in the
## current directory the file is not updated.
##
## ARGUMENTS:
##    dir   - (Optional) the directory containing jtag and jlog files to
##            update.
##
## REQUIRES:
##
################################################################################

use strict;
use Cwd;
use Cwd 'abs_path';


## VARIABLES ##
###############

my $root;                              # where to find the j* files
my $jfile;                             # current file being examined
my $line;                              # current line being examined
my $jfile_expn = '\.j((tag)|(log))';   # how to recognize a jtag/jlog file
my $img_expn = '(img)( *)(=)( *)(.+)'; # how to recognize an img tag
my $found = 0;                         # used to determine when a file needs
                                       # updating
my $sub;
my $orig_line;

# ensure that the root dir passed is valid
if ($#ARGV < 0) {
    print "Searching current directory for j* files.\n";
    print "Specify the search dir as an argument to change this.\n";
    $root = cwd();
} else {
    $root = $ARGV[0];
    if (substr($root,0,1) ne "/") {
        # relative path provided
        $root = abs_path(cwd() . "/" . $root);
    }
}

# go through each jtag and jlog file in $root one by one
opendir(DIR, $root) or die "can't opendir $root: $!";
while (defined($jfile = readdir(DIR))) {

    # see if this is a valid jtag file
    if ($jfile =~ $jfile_expn) {

        $found = 0;

        open(FILE, "$root/$jfile") or die;
        foreach $line (<FILE>) {

           # search for img tag 
           if ($line =~ $img_expn) {

               # does img file exist?
               # don't check this anymore since we sometimes copy files to
               # new directories
               #if (! -e $5) {

                   #see if filename can be found in curr dir
                   $_ = $5;
                   /(.*)\/(.+)/;
                   $sub = "$root/$2";
                   if (-e $sub) {
                       # found.  Update the original file
                       $orig_line = $line;
                       $found = 1;
                       last;
                   }
               #}
           }
        }
        close(FILE);
        if ($found) {
            print "Updating: $root/$jfile\n";
            $sub = "img = $sub\n";
            local($^I, @ARGV) = ('.orig', "$root/$jfile");
            while (<>) {
                s/$orig_line/$sub/;
                print;
                close ARGV if eof;
            }
            unlink "$root/$jfile.orig";
        }
    }
}
closedir(DIR);
