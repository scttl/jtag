#!/usr/bin/perl -w
################################################################################
##
## FILE: AddCatScript.pl
##
## Written by Kevin Laven
##
## DESCRIPTION: Script that adds a new bucket (class) to all jtag files in
## the specified directories.  You specify the name of the new bucket, as
## well as the directories containing hte jtag files.
##
##
## ARGUMENTS:
##    bucket -  The name of the new bucket
##
##    dirs - The directories to search for training data.  Note that all valid
##           files in each directory found will be used.  You can specify 
##           multiple directories by listing the path to each (separated by 
##           whitespace).
##
## REQUIRES:
##    Perl interpreter
##
################################################################################

use strict;
use File::Basename;


## VARIABLES ##
###############

my $bucketName;  # name of new bucket
my $lineCount = 0;

# my $outFile;  # output file for when copying data
# my $datafile; # path/name of dumped training data file

my $dir; # current directory being inspected for training data files.
my $file; # current file being inspected for inclusion in training data
my $oldFile; # backup copy of old file
my $line; # current line being inspected for img tags
my $jtag_expn = '\.jtag'; # how to recognize a file as a jtag file.
my $old_expn = '\.old'; # how to regognize a backup file.
my $img_expn = '(img)( *)(=)( *)(.+)'; # how to recognize the image tag
my $class_expn = '( *)(classes)( *)(=)( *)(\()'; # start of classes list
my $found = 0; # true if atleast one img tag has been found for inclusion.
my $update_jfiles = 0; # set this to 0 if you wish to turn off the
                       # automatic running of update_jfiles.pl (if it is found)


# ensure that the user has specified the outfile, and at least 1 input dir.
if ($#ARGV < 1) {
    print "\nUseage: AddCatScript.pl <bucket> <dir1> [<dir2> ... <dirn>]\n";
    print "\nwhere\n";
    print "   <bucket> = name of the new bucket / class\n";
    print "   <dir> = path to a directory containing tagged image files\n";
    print "           to have the bucket added to them\n\n";
    exit -1;
} 

#$outfile = shift @ARGV;
$bucketName = shift @ARGV;

#$datafile = "\'$outfile.data\'";
print "New bucket name: $bucketName\n";

# open the outfile and write header information to it
#open(OUTFILE, "> $outfile") or die "can't open $outfile: $!";
#print OUTFILE "% FILE: $outfile\n%\n";
#print OUTFILE "% PURPOSE: Matlab script to build files listed below into a\n";
#print OUTFILE "%          valid training data file\n%\n";
#print OUTFILE "% USEAGE: matlab -nojvm -nosplash < $outfile > /dev/null\n";
#print OUTFILE "%         where you have the jtag/matlab dir in your matlab\n";
#print OUTFILE "%         path (or cd to that dir first)\n\n";
#print OUTFILE "td_outfile = $datafile;\n";
#print OUTFILE "imgs = {\n";

# Iterate over each file in each directory, adding bucketName to its list of
# buckets.
while (<@ARGV>) {

    # attempt to locate valid jtag files
    $dir = shift @ARGV;

    opendir(DIR, $dir) or die "can't opendir $dir: $!";

    print "Searching for files in dir: $dir\n";

    # call update_jfiles.pl (if it is found)
    $file = dirname($0) . '/update_jfiles.pl';
    if ($update_jfiles && -e $file) {
        print "Updating any outdated jtag files in $dir\n";
        `$file $dir`;
    }

    while (defined($file = readdir(DIR))) {

        # see if this is a valid jtag file
        if (($file =~ $jtag_expn) & !($file =~ $old_expn)) {
	    $lineCount = 0;
	    
	    $oldFile = "$file.old"; 
	    rename("$dir/$file", "$dir/$oldFile") or die "can't rename $dir/$file to $oldFile:$!";

	    open(OLDFILE, "< $dir/$oldFile") or die "can't open $dir/$oldFile for input";
            open(FILE, "> $dir/$file") or die;

	    while (defined($line = <OLDFILE>)) {
	        print FILE $line;
 
#            foreach $line (<FILE>) {
#		$lineCount = $lineCount + 1;
#    
                # search for img tag 
                # if ($line =~ $img_expn) {
		if ($line =~ $class_expn) {
                    # found, add the new bucket
                    $found = 1;
		    # print "Found target at ", tell(FILE), "\n";
		    # if (seek(FILE, tell(FILE), 0)) {
			#  print "Trying to output to line ", tell(FILE), "\n";
                        print FILE "    eq_number #A37C90\n";
		    # } else {
			# print "Seek failed.\n";
		    # }

                    # found, add it to our list
                    # $found = 1;
                    # print OUTFILE "\'$5\'\n";
                }
            }
            close(FILE);
	    close(OLDFILE);
        }
    }
    closedir(DIR);
}

# write out the rest of the script
#print OUTFILE "}\n\n";
#print OUTFILE "tmp_var = create_training_data(imgs);\n";
#print OUTFILE "dump_training_data(tmp_var, td_outfile);\n";

#close(OUTFILE);

# see if we should actually keep the file or not (img's found)
if (! $found) {
    print "No images found in the directories specified!\n";
#    unlink $outfile;
}
