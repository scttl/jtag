#!/usr/bin/perl -w
################################################################################
##
## FILE: build_td_script.pl
##
## CVS: $Id: build_td_script.pl,v 1.1 2003-09-17 18:15:27 scottl Exp $
##
## DESCRIPTION: Script that dynamically creates an input script to be used by
## MATLAB to create a working dump of training data.  You specify the
## path/name of the output script, as well as the directories containing input
## jtag/jlog files (which are used as the training data corpus).
##
## ARGUMENTS:
##    outfile - The path and name of the output script file (which can be fed
##              into MATLAB in batch mode), overwrites any existing file of
##              the same name.
##
##    dirs - The directories to search for training data.  Note that all valid
##           files in each directory found will be used.  You can specify 
##           multiple directories by listing the path to each (separated by 
##           whitespace).
##
## REQUIRES:
##    Perl interpreter
##    (optional) update_jfiles.pl script
##
################################################################################

use strict;
use File::Basename;


## VARIABLES ##
###############

my $outfile;  # path/name of output script file
my $datafile; # path/name of dumped training data file
my $dir; # current directory being inspected for training data files.
my $file; # current file being inspected for inclusion in training data
my $line; # current line being inspected for img tags
my $jtag_expn = '\.jtag'; # how to recognize a file as a jtag file.
my $img_expn = '(img)( *)(=)( *)(.+)'; # how to recognize the image tag
my $found = 0; # true if atleast one img tag has been found for inclusion.
my $update_jfiles = 1; # set this to 0 if you wish to turn off the
                       # automatic running of update_jfiles.pl (if it is found)


# ensure that the user has specified the outfile, and at least 1 input dir.
if ($#ARGV < 1) {
    print "\nUseage: build_td_script.pl <outfile> <dir1> [<dir2> ... <dirn>]\n";
    print "\nwhere\n";
    print "   <outfile> = path and name of the output script file to create\n";
    print "   <dir> = path to a directory containing tagged image files\n";
    print "           to be used for training data\n\n";
    exit -1;
} 

$outfile = shift @ARGV;
$datafile = "\'$outfile.data\'";
print "Creating training data script: $outfile\n";

# open the outfile and write header information to it
open(OUTFILE, "> $outfile") or die "can't open $outfile: $!";
print OUTFILE "% FILE: $outfile\n%\n";
print OUTFILE "% PURPOSE: Matlab script to build files listed below into a\n";
print OUTFILE "%          valid training data file\n%\n";
print OUTFILE "% USEAGE: matlab -nojvm -nosplash < $outfile > /dev/null\n";
print OUTFILE "%         where you have the jtag/matlab dir in your matlab\n";
print OUTFILE "%         path (or cd to that dir first)\n\n";
print OUTFILE "td_outfile = $datafile;\n";
print OUTFILE "imgs = {\n";

# iterate over each file in each directory, adding its tagged image files to
# the list
while (<@ARGV>) {

    # attempt to locate valid jtag files and infer their image files for
    # inclusion
    $dir = shift @ARGV;

    opendir(DIR, $dir) or die "can't opendir $dir: $!";

    print "Searching for files in dir: $dir\n";

    #call update_jfiles.pl (if it is found)
    $file = dirname($0) . '/update_jfiles.pl';
    if ($update_jfiles && -e $file) {
        print "Updating any outdated jtag files in $dir\n";
        `$file $dir`;
    }

    while (defined($file = readdir(DIR))) {

        # see if this is a valid jtag file
        if ($file =~ $jtag_expn) {
    
            open(FILE, "$dir/$file") or die;
            foreach $line (<FILE>) {
    
                # search for img tag 
                if ($line =~ $img_expn) {
                    # found, add it to our list
                    $found = 1;
                    print OUTFILE "\'$5\'\n";
                }
            }
            close(FILE);
        }
    }
    closedir(DIR);
}

# write out the rest of the script
print OUTFILE "}\n\n";
print OUTFILE "tmp_var = create_training_data(imgs);\n";
print OUTFILE "dump_training_data(tmp_var, td_outfile);\n";

close(OUTFILE);

# see if we should actually keep the file or not (img's found)
if (! $found) {
    print "No images found in the directories specified!\n";
    unlink $outfile;
}
