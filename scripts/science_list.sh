#!/bin/bash
################################################################################
##
## FILE: science_list.sh
##
## CVS: $Id: science_list.sh,v 1.1 2003-06-03 23:38:06 scottl Exp $
##
## DESCRIPTION: wget script to retrieve a list of Stable URL's for issues of
##              the Science journal from the jstor website.
##
################################################################################

ROOT=./science      # base directory in which to place list of URL's
LOGNAME=LIST.log     # name of output log
URL='http://www.jstor.org/browse/00368075/3.271-3.278?config=jstor&frame=noframe&userID=80640381@utoronto.ca/01cc9933410050d82082&dpi=3'

# execute the command
# Note that we must go exactly 2 levels deep (-l2) to get to the Stable URLS
# Finally, we must ignore robots.txt and issue a fake useragent string since
# jstor, will issue a 403 otherwise.
wget -r -U "Mozilla" -o ${ROOT}/${LOGNAME} -l2 -np -nH -nd -P $ROOT \
     $URL
