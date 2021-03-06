#!/bin/bash
################################################################################
##
## FILE: ps_to_tiff.sh
##
## CVS: $Id: ps_to_tiff.sh,v 1.1 2003-09-19 18:16:15 scottl Exp $
##
## DESCRIPTION: script that takes as input a directory containing ps files,
##              and converts each of them into multiple tiff files (one per
##              page) in another directory.
##
## ARGUMENTS:
##    dir   - The path to the directory containing the ps files.  Note that
##            the script seaches that directory only (non-recursive).
##
## REQUIRES:
##    ghostscript   - available at: http://www.cs.wisc.edu/~ghost/
##    tiffsplit     - comes with libtiff.so
##
################################################################################

ROOT=$1                     # where to find the pdf files
OUTDIR=${ROOT}/READY_TO_TAG # default output directory
PS_EXTN=ps                  # suffix of files to look for
TIFF_EXTN=tif               # suffix to place on the tiff file created
GS_CMD=gs                   # ghostscript command to use for the conversion
TIFF_DEVICE=tiffg4          # device to use for ghostscript
USE_SPLIT=true              # default to split multipage files
RM_ORIG_TIFF=true           # default action to remove the multipage tiff
                            # after split
SPLIT_CMD=tiffsplit         # command to split multipage tiff files

# ensure that the root dir passed is valid and contains pdf files
if [ ! $1 ]; then
    echo "useage: pdf_to_tiff.sh <pdf_dir> [ <output_dir> ]"
    exit -1
fi

if [ ! -d $ROOT ]; then
    echo "pdf_dir passed is not a directory"
    exit -1
fi

# check if they passed an output dir name, and if so ensure we can write to it
if [ $2 ]; then
    if [ -e $2 ] && [ ! -d $2 ]; then
        echo "output_dir pased is not a directory"
        exit -1
    fi
    mkdir -p $2
    if [ ! -w $2 ]; then
        echo "can't write to output_dir"
        exit -1
    fi
    OUTDIR=$2
fi

# create the output directory if it doesn't already exist
mkdir -p $OUTDIR

# ensure that our ghostscript command is valid
which $GS_CMD > /dev/null 2>&1
if [ $? != 0 ]; then
    echo "ghostscript command: $GS_CMD is invalid"
    exit -1
fi

# check if the split command is valid
which $SPLIT_CMD > /dev/null 2>&1
if [ $? != 0 ]; then
    echo "warning, split command: $SPLIT_CMD is invalid"
    USE_SPLIT=false
    RM_ORIG_TIFF=false
fi

# go through each pdf in $ROOT one by one, processing it to a tiff
for curr in `ls ${ROOT}/*.${PS_EXTN}`; do
    outfile=${OUTDIR}/`basename $curr $PS_EXTN`$TIFF_EXTN

    # perform the conversion to tiff
    $GS_CMD -sDEVICE=${TIFF_DEVICE} -dBATCH -q -dNOPAUSE \
              -sOutputFile=$outfile $curr

    # split into multiple files (one page per file)
    if [ $USE_SPLIT == true ]; then
        $SPLIT_CMD $outfile ${OUTDIR}/`basename $curr $PS_EXTN`
    fi

    # remove the original multipage tiff
    if [ $USE_SPLIT == true ] && [ $RM_ORIG_TIFF == true ]; then
        rm -f $outfile
    fi

    echo "Successfully converted $curr --> $outfile"
done

exit 0
