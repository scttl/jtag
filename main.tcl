#!/bin/sh
# restart the shell script using the wish interpreter\
exec bltwish "$0" "$@"

################################################################################
##
## FILE: main.tcl
##
## DESCRIPTION: Point of code entry into the jtag application.
##
## CVS: $Header: /p/learning/cvs/projects/jtag/main.tcl,v 1.2 2003-07-10 19:18:27 scottl Exp $
##
## REVISION HISTORY:
## $Log: main.tcl,v $
## Revision 1.2  2003-07-10 19:18:27  scottl
## Terminate the application if UI creation fails for any reason.
##
## Revision 1.1  2003/07/02 16:16:28  scottl
## Initial revision.
##
##
################################################################################



# VERSION INFORMATION #
#######################

# NOTE: update the version manually below as new revisions are created
set jtagVersion "1.1"



# PACKAGE DEPENDENCIES #
########################

# Append the library directory to the auto_path so that packages can be found
set appdir [file dirname [info script]]
lappend auto_path [file join $appdir lib]

# Load required packages.  If any are missing, a warning will be displayed
# and the application will terminate.
package require Tk 8.3
package require Img 1.3
package require autoscroll 1.0
package require BLT 2.4

# Source the contents of all helper files
source [file join $appdir config.tcl]
namespace import ::Jtag::Config::*
source [file join $appdir file.tcl]
source [file join $appdir ui.tcl]
source [file join $appdir menus.tcl]
source [file join $appdir image.tcl]
source [file join $appdir classify.tcl]



# GLOBAL VARIABLES #
####################

# Only globals used are jtagVersion and appdir (both set above).
global jtagVersion
global appdir

# All "global" data is kept in the config.tcl file which is sourced above
# Note that that data isn't global, but falls under the Jtag::Config namespace



# GLOBAL PROCEDURES #
#####################

# main --
#
#    Point of code entry into the application
#
# Arguments:
#    argv    (optional) if specified at the command line upon application
#            startup, argv should list a path to a valid journal image file
#            for processing.
#
# Results:
#    Upon completion of successful initialization, control is passed to the 
#    internal Tk event handling procedures where events are processed until the
#    application terminates.

proc main {} {

    # declare any "local" variables
    variable Response

    # make necessary global variables available
    global argv

    # Turn on debugging information, logging to stderr
    debugOn
    #debugOn [file join $appdir debug.log]

    # Read in settings from the configuration file (if it exists)
    ::Jtag::Config::read_config

    # Attempt to validate and display the image file if passed as an arg
    # Ignore any additional args
    if {[llength $argv] != 0} {
        debug "Passed $argv as a command line argument"
        if {[catch {::Jtag::Image::create_image [lindex $argv 0]} Response]} {
            debug "Failed to validate/display passed image.  Reason:\n$Response"
        }
    }
        
    # Attempt to Render and display the UI
    if {[catch {::Jtag::UI::create} Response]} {
        debug "Failed to create the user interface.  Reason:\n$Response"
        debug "Terminating the application"
        exit -1
    }

}


# debug --
#
#    Enables logging of debug information when turned on.
#
# Arguments:
#    msg    The string to log
#
# Results:
#    If debug(enabled) is set, then the msg passed is logged to whatever is
#    set in debug(file), otherwise no output is given.  If debug(file) is not
#    set, the output will go to stderr

proc debug {msg} {

    global debug
    if ![info exists debug(enabled)] {
        # do nothing
        return
    }
    puts $debug(outFile) [concat [clock format [clock seconds] -format %c] \
                          "--" $msg]

}


# debugOn --
#
#    Turns on debugging information.
#
# Arguments:
#    file    (optional) The path and name of the file to write debug info to
#
# Results:
#    Sets debug(enabled) to allow debugging information to be written, and 
#    opens the file passed for writing.  If no file is passed, stderr is used 
#    instead.

proc debugOn {{file {}}} {

    global debug
    set debug(enabled) 1
    if {[string length $file] != 0} {
        if [catch {open $file a} fileID] {
            puts stderr [concat [clock format [clock seconds] -format %c] \
                         " -- Cannot open $file"]
            set debug(outFile) stderr
            puts stderr [concat [clock format [clock seconds] -format %c] \
                         " -- Logging debug info to stderr"]
        } else {
            set debug(outFile) $fileID
            puts $fileID [concat [clock format [clock seconds] -format %c] \
                          " -- Logging debug info to $file"]
        }
    } else {
        set debug(outFile) stderr
        puts stderr [concat [clock format [clock seconds] -format %c] \
                     " -- Logging debug info to stderr"]
    }

}


# debugOff --
#
#    Turns off debugging information.
#
# Arguments:
#
# Results:
#    Unsets debug(enabled) to prevent debugging information to be written,
#    and flushes any remaining info.

proc debugOff {} {

    global debug
    if [info exists debug(enabled)] {
        unset debug(enabled)
        flush $debug(outFile)
        if {$debug(outFile) != "stderr" && $debug(outFile) != "stdout"} {
            close $debug(outFile)
            unset debug(outFile)
        }
    }

}


######################
# C O D E  S T A R T #
######################

# simply call the main method to get the ball rolling
main
