#!/usr/bin/perl -w
################################################################################
##
## FILE: jstor_rtrv.pl
##
## CVS: $Id: jstor_rtrv.pl,v 1.1 2003-06-03 23:38:06 scottl Exp $
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


## VARIABLES ##
###############

# the format of article to retrieve. Poss. legal values are:
# hqpdf - high quality pdf
# epdf  - low quality pdf
# tiff  - tiff format
# ps    - postscript format
my $format = tiff;

my $ua;  # the useragent


########################
## C O D E  S T A R T ##
########################

# setup the user agent connection and cookie
$ua = LWP::UserAgent->new;

# while we still have URL's to read

# @@ TO COMPLETE @@
