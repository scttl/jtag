#!/bin/bash
################################################################################
##
## FILE: jmlr_rtrv.sh
##
## CVS: $Id: jmlr_rtrv.sh,v 1.1 2003-06-03 23:38:06 scottl Exp $
##
## DESCRIPTION: wget script to retrieve all the pdf papers from the 
##              jmlr.org website.
##
################################################################################

ROOT=./jmlr          # base directory in which to place journals and logs
LOGNAME=RESULTS.log  # name of output log
URL=http://www.jmlr.org/papers # base url containing links to articles

# execute the command
wget -r -nH -nd -P $ROOT -o ${ROOT}/${LOGNAME} -A "*.pdf" $URL/v1 $URL/v2 \
     $URL/v3 $URL/v4 $URL/special

