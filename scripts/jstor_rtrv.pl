#!/usr/bin/perl -w
################################################################################
##
## FILE: jstor_rtrv.pl
##
## CVS: $Id: jstor_rtrv.pl,v 1.3 2003-06-05 15:56:45 scottl Exp $
##
## DESCRIPTION: Perl script to parse a list of Stable URL's taken from
##              STDIN  and download the appropriate format of article.
##
##              - Requires use of LWP to select forms.
##              - Defaults to downloading articles in the current directory
##
## USEAGE: jstor_rtrv.pl < <input_url_list>
##
################################################################################

## PRAGMAS ##
#############

use strict;

use LWP::UserAgent;
use HTTP::Cookies;

use IO::Handle;                        # to flush output right away
#use LWP::Debug(qw(+));                # use when debugging only - very verbose



## VARIABLES ##
###############

my $out_dir = ".";                    # where to save the downloaded articles
my $log_file = $out_dir . "/RESULTS.log";  # where to write result information

my $ua;                               # LWP::UserAgent object
my $rua;                              # UserAgent object reference
my $resp;                             # HTTP::Response object
my $rresp;                            # Response object reference

# the format of article to retrieve. Poss. legal values are:
# pdf - high quality pdf
# tif  - tiff format
# ps    - postscript format
my $format = "tif";

my $base_url = "http://www.jstor.org";        # needed when followin dl link
my $dl_regex = '(.*)(HREF=")(.*)(">DOWNLOAD<)(.*)';  # what to match
my $link_regex = "(.*)(/)(.*)(\.$format)(.*)";  # to extract filename
my $agent = 'Mozilla/10.001 (OS; U; blah; en-ca) Gecko/25250101'; # identity

my $cookie_jar;                                  # Cookie jar object
my $ck_key = "JSTOR_DownloadPreferences";  # name of the cookie
my $ck_val;                                 # value for the cookie
my $ck_path = "/";
my $ck_dom = "www.jstor.org";

my $url_count = 0;
my $fail_count = 0;



########################
## C O D E  S T A R T ##
########################

# setup the user agent connection, response object, and cookie
$ua = new LWP::UserAgent;
$ua->agent($agent);
$rua = \$ua;
$resp = new HTTP::Response;
$rresp = \$resp;

# JSTOR requires a single cookie to store the format of the article to
# download.  Here we create a cookie jar that will save this value.
$ck_val = get_dl_val();
$cookie_jar = new HTTP::Cookies;
$cookie_jar->set_cookie(undef, $ck_key, $ck_val, $ck_path, $ck_dom, 
                        undef, 0, 0, 60*60, 0);
$ua->cookie_jar($cookie_jar);

# create a file handle and use that to to store all logging information
open(LOG, ">> $log_file") or die "Unable to open log file: " . $log_file . "\n";
LOG->autoflush(1);
print LOG localtime() . ": S T A R T  U R L  P R O C E S S I N G\n" .
     "----------------------------------------------------------\n\n";

# while we still have URL's to read
START: while (<STDIN>) {

    $url_count += 1;

    # acquire and process each one
    chomp $_;
    if(! process_url($rua, $rresp, $_)) {
        $fail_count += 1; 
        print LOG "Failed to Process URL: " . $_ . "\n";
    }


} # end main processing loop

# print summary 
print LOG "\n" . localtime() . ": E N D  U R L  P R O C E S S I N G\n" .
      "------------------------------------------------------------\n" .
      "   # of URL failures = " . $fail_count . "\n" .
      "   # of URL's successfully processed = " . $url_count-$fail_count . "\n";

close(LOG);

# cleanup declared objects
undef $cookie_jar;
undef $resp;
undef $ua;



################################################################################
## SUB: process_url
## This procedure attempts to download a single stable URL from the JSTOR
## site.
## Arguments: LWP::UserAgent ref, HTTP::Response ref, URL string
## Preconds: UserAgent and Response initialized, URL not empty
## Returns: 1 on successful download and 0 otherwise
################################################################################
sub process_url {

    # get arguments
    my $rua = shift;
    my $rresp = shift;
    my $url = shift;

    # declcare any local variables needed
    my $req;       # the HTTP::Request object used to access pages
    my $html;      # the HTML content returned by the URL
    my $link = ""; # the string representation of the link to follow to dl.
    my $file = ""; # the name of the file to save

    # attempt to get the URL passed
    $req = new HTTP::Request('GET', $url);
    $$rresp = $$rua->request($req);
    if(! $$rresp->is_success) {
    
        # failed to access URL for some reason
        print "Unable to access URL: " . $url . 
              "\nReason: " . $$rresp->message . "\n";
        undef $req;
        return 0;

    }

    # parse the response to ensure we can find and extract the link to the
    # download page
    $html = $$rresp->content();
    if($html =~ $dl_regex) {

        $_ = $html;
        s/$dl_regex/$3/;  #@@ NOTE: $3 should be changed as $dl_regex changes
        $link = $base_url . $3;

    } else {

        # failed to find the link to the download page
        print "URL did not contain appropriate download link\n";
        undef $req;
        return 0;

    }

    # extract the filename from the link based on what is in $format
    if($link =~ $link_regex) {
        $_ = $link;
        #s/$link_regex/$3/;  #@@ NOTE: $3 should be changed as $link_regex change
        $file = $out_dir . "/" . $3 . $4;
    } else {

        # failed to find the filename in the link
        print "Download link didn't list a proper filename\n";
        undef $req;
        return 0;

    }

    # attempt to download the document by GET'ting the download link
    $req = new HTTP::Request('GET', $link);
    $$rresp = $$rua->request($req);

    if(! $$rresp->is_success) {

        # failed to download the link for some reason
        print "Unable to download file.\nReason: " . $$rresp->message . "\n";
        undef $req;
        return 0;
    }

    # write the contents out to $file
    open(OUT, "> $file") or die "can't open file $file: $!";
    print OUT $$rresp->content();
    close(OUT);

    return 1;

} # end process_url



################################################################################
## SUB: get_dl_val
## This procedure constructs the download cookie value string based on what
## is set in $format
## Arguments: none
## Preconds: $format is set to one of the 4 poss. legal values on call
## Returns: Valid cookie value string
################################################################################
sub get_dl_val {

    # declare any local variables needed
    my $val = "";   # the value string to be constructed

    $_ = $format;

    SWITCH: {
        if(/^tif/) {
            $val = "dwnld_hqpdf=off/dwnlod_epdf=off/dwnld_tiff=on/dwnld_ps=off";
            last SWITCH;
        }
        if(/^pdf/) {
            $val = "dwnld_hqpdf=on/dwnlod_epdf=off/dwnld_tiff=off/dwnld_ps=off";
            last SWITCH;
        }
        if(/^ps/) {
            $val = "dwnld_hqpdf=off/dwnlod_epdf=off/dwnld_tiff=off/dwnld_ps=on";
            last SWITCH;
        }
    }

    return $val;

} # end get_ck_val
