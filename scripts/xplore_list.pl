#!/usr/bin/perl -w
################################################################################
##
## FILE: xplore_list.pl
##
## CVS: $Id: xplore_list.pl,v 1.1 2003-06-06 18:08:19 scottl Exp $
##
## DESCRIPTION: Perl script to extract download links to every issue of a
##              particular journal given by its pu number (will span multiple 
##              years if req.).
##
##              - Requires a valid pu number (used on the site to identify a
##                given journal).
##              - As it finds the links, it outputs them to STDOUT
##
## USEAGE: xplore_list.pl <pu_number>
##
################################################################################

## PRAGMAS ##
#############

use strict;

use LWP::UserAgent;
use HTTP::Cookies;

use IO::Handle;                        # to flush output right away
use LWP::Debug(qw(+));                # use when debugging only - very verbose



## VARIABLES ##
###############

my $out_dir = ".";                    # where to save the downloaded html
my $log_file = $out_dir . "/RESULTS.log";  # where to write result information

my $ua;                               # LWP::UserAgent object
my $rua;                              # UserAgent object reference
my $resp;                             # HTTP::Response object
my $rresp;                            # Response object reference
my $req;                              # HTTP::Request object
my $cookie_jar;                       # HTTP::Cookies object manages cookies

my $base_url = "http://ieeexplore.ieee.org";
my $issue_url = $base_url . "/xpl/RecentIssue.jsp?puNumber=";
my $toc_url = $base_url . "/xpl/tocresult.jsp?isNumber=";

# Pattern representing the table of contents link to download.  Want $2 and $3
my $toc_regex = '(<a href=")(/xpl/tocresult.jsp?)(.*?)(">)';

# Pattern representing an issue link.  Should be followed to get toc.  Want $2
# and $3
my $issue_regex = '(<a href=")(/xpl/RecentIssue.jsp?)(.*?)(">)';

# Pattern representing a single article PDF link.  Want $2
my $pdf_regex = '(<A HREF=")(.*?)(">\[PDF Full\-Text)';

my $agent = 'Mozilla/10.001 (OS; U; blah; en-ca) Gecko/25250101'; # identity

my $pu;
my @file;
my $line;
my $issue;
my @issues;
my $url_count = 0;



########################
## C O D E  S T A R T ##
########################

START: 

# setup the user agent connection, response object, and cookie jar
$ua = new LWP::UserAgent;
$ua->agent($agent);
$rua = \$ua;
$resp = new HTTP::Response;
$rresp = \$resp;
$cookie_jar = new HTTP::Cookies;
$ua->cookie_jar($cookie_jar);

# create a file handle and use that to to store all logging information
open(LOG, "> $log_file") or die "Unable to open log file: " . $log_file . "\n";
LOG->autoflush(1);
print LOG localtime() . ": S T A R T  U R L  P R O C E S S I N G\n" .
     "-----------------------------------------------------------------\n\n";

# Ensure the user passed exactly one numerical argument
$pu = shift @ARGV;
if(! $pu || $pu =~ /\D/) {
    # argument is not numerical
    print LOG "You must pass a single numerical argument representing the " .
              "journal you wish to acquire\n";
}

# Attempt to retrieve the webpage specified by the pu number given
$req = new HTTP::Request('GET', $issue_url . $pu);
$resp = $ua->request($req);
if(! $resp->is_success) {
    # failed to access the URL for some reason (poss. bad pu # given)
    print LOG "Unable to access URL: " . $issue_url . $pu . "\nReason: " .
              $resp->message . "\n";
    print LOG "\n" . localtime() . ": E N D  U R L  P R O C E S S I N G\n";

    undef $req;
    undef $resp;
    undef $ua;

    close(LOG);

    exit(-1);
}

# Since a valid page was found, break the content up into individual
# lines and search each for issue links.  Must be sure to add the current
# URL since it may contrain toc links as well.
push(@issues,$issue_url . $pu);

@file = split /\n/,$resp->content();

foreach $line (@file) {
    # check if we have found an issue link, and if so extract and store it 
    # for later processing
    if($line =~ $issue_regex) {
        # issue link found
        push(@issues,$base_url . $2 . $3);
    }
}

# now we iterate through each item in our @issues list, extracting and saving
# the toc html page.
foreach $issue (@issues) {
    # attempt to retrieve the webpage specified by this link
    $req = new HTTP::Request('GET', $issue);
    $resp = $ua->request($req);
    if(! $resp->is_success) {
        # failed to access the URL for this issue
        print LOG "Unable to access Issue URL: " . $issue . "\nReason: " .
            $resp->message . "\n";
    } else {
        $rresp = \$resp;
        print LOG localtime() . " - Extracting toc links from Issue: " .
                                $issue . "\n";
        $url_count += extract_tocs($rua, $rresp);
    }
}

# print summary 
print LOG "\n" . localtime() . ": E N D  U R L  P R O C E S S I N G\n" .
      "------------------------------------------------------------\n" .
      "   # of URL's successfully processed = " . $url_count . "\n";

close(LOG);

# cleanup declared objects
undef $resp;
undef $ua;



################################################################################
## SUB: extract_tocs
## This procedure attempts to find and download all the valid toc links from
## the html content in the response object reference passed.
## Arguments: LWP::UserAgent ref, HTTP::Response Ref
## Preconds: None
## Returns: Number of toc links found.
################################################################################
sub extract_tocs {

    # get arguments
    my $rua = shift;
    my $rresp = shift;

    # declcare any local variables needed
    my $toc_count = 0;
    my @file = split /\n/,$$rresp->content();
    my $line;

    # loop through each line in the content to see if it matches a valid
    # toc link
    foreach $line (@file) {
        if($line =~ $toc_regex) {
            # toc link found, so extract and download it
            if(! extract_toc($rua, $rresp, $base_url . $2 . $3)) {
                print LOG localtime() . " failed to extract a valid toc: " .
                    $base_url . $2 . $3 . "\n";
            } else {
                print LOG " Successfully extracted toc: " . $base_url . $2 .
                    $3 . "\n";
                $toc_count += 1;
            }
        }
    }

    return $toc_count;

} # end extract_tocs



################################################################################
## SUB: extract_toc
## This procedure attempts to download the single toc link passed to a file.
## the html content in the response object reference passed.
## Arguments: LWP::UserAgent ref, HTTP::Response Ref, $url
## Preconds: None
## Returns: 1 on successful download, and 0 otherwise
################################################################################
sub extract_toc {

    # get arguments
    my $rua = shift;
    my $rresp = shift;
    my $url = shift;

    # declare any local variables needed
    my $req;
    my @file;
    my $line;


    # attempt to get the URL passed
    $req = new HTTP::Request('GET', $url);
    $$rresp = $$rua->request($req);
    if(! $$rresp->is_success) {

        # failed to access URL for some reason
        print LOG "Unable to access URL: " . $url .
                  "\nReason: " . $$rresp->message . "\n";
        undef $req;
        return 0;
    }

    # loop through each line in the content to see if it matches a valid
    # toc line
    @file = split /\n/,$$rresp->content();

    foreach $line (@file) {
        if($line =~ $pdf_regex) {
            # pdf link found, so download it to $out_dir
            if(! dl_pdf($rua, $rresp, $base_url . $2)) {
                print LOG "Failed to Download PDF at link: " . $base_url .
                           $2 . "\n";
            }
        }
    }

    undef $req;
    return 1;

} # end extract_toc



################################################################################
## SUB: dl_pdf
## This procedure attempts to download a pdf file, given a valid URL link to
## it.
## Arguments: LWP::UserAgent ref, HTTP::Response Ref, $url
## Preconds: None
## Returns: 1 on successful download, and 0 otherwise
################################################################################
sub dl_pdf {

    # get arguments
    my $rua = shift;
    my $rresp = shift;
    my $url = shift;

    # declare any local variables needed
    my $req;
    my $file;

    # attempt to get the URL passed
    $req = new HTTP::Request('GET', $url);
    $$rresp = $$rua->request($req);
    if(! $$rresp->is_success) {

        # failed to access URL for some reason
        print LOG "Unable to access URL: " . $url .
                  "\nReason: " . $$rresp->message . "\n";
        undef $req;
        return 0;
    }

    # Determine the name of the file - everything between the last slash and
    # .pdf in the URL
    $_ = $url;
    s/(.*)(\/)(.*?)(.pdf)(.*)/$3$4/;

    $file = $out_dir . "/" . $_;

    # write the contents to the file
    open(OUT, "> $file") or die "can't open file $file: $!";
    print OUT $$rresp->content();
    close(OUT);
    
    print LOG "Successfully wrote file: " . $file . "\n";
    undef $req;
    return 1;

} # end dl_pdf
