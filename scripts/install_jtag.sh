#!/bin/bash
################################################################################
##
## FILE: install_jtag.sh
##
## CVS: $Id: install_jtag.sh,v 1.1 2003-08-29 18:57:01 scottl Exp $
##
## DESCRIPTION: Script used to control installation of the jtag application
##              and any dependancies
##
## ARGUMENTS:
##
## REQUIRES:
##
################################################################################

INS_TCL=true
INS_BLT=true

IN=$0
ROOT=${IN%install_jtag.sh}".."

TMP_DIR="/tmp"

TCL_BASE="ActiveTcl8.4.4.0-linux-ix86"
TCL_INSTALL=$TCL_BASE"/install.sh"
TCL_TAR=$ROOT/src/$TCL_BASE".tar.gz"

BLT_BASE="blt2.4z"
BLT_TAR=$ROOT/src/"BLT2.4z.tar.gz"
BLT_PATCH=$ROOT/src/"blt2.4z-patch-2"

# Check which dependancies are already on the system

echo "Checking for valid 8.4 Tcl interpreter"
which wish8.4 > /dev/null 2>&1
if [ $? == 0 ]; then
    INS_TCL=false
    echo ".....OK"
else
    echo ".....NOT FOUND!"
fi

echo "Checking for valid 2.4 Blt interpreter"
which bltwish24 > /dev/null 2>&1
if [ $? == 0 ]; then
    INS_BLT=false
    echo ".....OK"
 else
    echo ".....NOT FOUND!"
fi

echo
echo

if [ $INS_TCL == false ] && [ $INS_BLT == false ]; then
    echo "It appears you have everything installed...."
    echo "Type main.tcl from the root unpacked dir to use the JTAG application"
    echo
    echo
    exit 0
fi

if [ $INS_TCL == true ]; then
    echo "Attempting to locate ActiveTcl tarball"
    if [ ! -f $TCL_TAR ]; then
        echo ".....NOT FOUND!"
        echo
        echo "Ensure the following files are in place and try again:"
        echo "$TCL_TAR"
        exit -1
    else
        echo ".....OK"
    fi

    echo "Unpacking TCL sources to $TMP_DIR"
    OLD_DIR=`pwd`
    cd $TMP_DIR
    tar -zxvf $OLD_DIR/$TCL_TAR
    if [ $? == 0 ]; then
        echo ".....OK"
    else
        echo
        echo "Problem untarring TCL sources"
        echo
        exit -1
    fi

    echo "Launching TCL installer"
    $TCL_INSTALL
    if [ $? != 0 ]; then
        echo
        echo "Problem running the ActiveTcl installer"
        echo
        exit -1
    fi
    echo ".....OK"
    echo "TCL now installed .... cleaning up"
    rm -rf $TCL_BASE
    cd $OLD_DIR
fi


if [ $INS_BLT == true ]; then
    echo "Attempting to locate BLT tarball and patch file"
    if [ ! -f $BLT_TAR ] || [ ! -f $BLT_PATCH ]; then
        echo ".....NOT FOUND!"
        echo
        echo "Ensure the following files are in place and try again:"
        echo "$BLT_TAR"
        echo "$BLT_PATCH"
        exit -1
    else
        echo ".....OK"
    fi

    echo "Unpacking BLT sources to $TMP_DIR"
    OLD_DIR=`pwd`
    cd $TMP_DIR
    tar -zxvf $OLD_DIR/$BLT_TAR
    if [ $? == 0 ]; then
        echo ".....OK"
    else
        echo
        echo "Problem untarring BLT sources"
        echo
        exit -1
    fi

    echo "Applying Patch to 2.4z BLT sources"
    patch -p0 < $OLD_DIR/$BLT_PATCH
    if [ $? == 0 ]; then
        echo ".....OK"
    else
        echo
        echo "Problem patching BLT sources"
        echo
        exit -1
    fi

    echo "Attempting to determine location of Tcl/Tk installation"
    which wish8.4 > /dev/null 2>&1
    if [ $? == 0 ]; then
        BIN_PATH=`which wish8.4`
        ROOT_PATH=${BIN_PATH%/bin/wish8.4}
        LIB_PATH=$ROOT_PATH/lib
        if [ -f $LIB_PATH/libtcl8.4.a ] || [ -f $LIB_PATH/libtcl8.4.so ]; then
            echo ".....FOUND at $ROOT_PATH"
        else
            ROOT_PATH=""
        fi
    fi

    if [ ! $ROOT_PATH ] || [ $ROOT_PATH == "" ]; then
        echo ".....NOT FOUND"
        echo "Enter the full path to your Tcl/Tk installation"
        echo "ex. /usr/local/ActiveTcl"
        read ROOT_PATH
    fi

    echo "Enter the install path for BLT: [ $ROOT_PATH ]"
    read INS_PATH

    if [ ! $INS_PATH ]; then
        INS_PATH=$ROOT_PATH
    fi

    echo "Beginning BLT install..."
    cd $BLT_BASE
    ./configure --with-tcl=$ROOT_PATH --prefix=$INS_PATH
    if [ $? != 0 ]; then
        echo "Problems with configure script"
        echo
        exit -1
    fi

    make

    if [ $? != 0 ]; then
        echo "Problems running Make"
        echo
        exit -1
    fi

    make install

    if [ $? != 0 ]; then
        echo "Problems running make install"
        echo
        exit -1
    fi

    echo "BLT now installed ... cleaning up"
    cd ..
    rm -rf $BLT_BASE
    cd $OLD_DIR
fi

exit 0
