################################################################################
##
## FILE: config.tcl
##
## DESCRIPTION: Holds all "global" (namespace) data as well as default
##              configuration settings for the jtag application.  Also
##              contains methods to update these settings.
##
## CVS: $Header: /p/learning/cvs/projects/jtag/config.tcl,v 1.1 2003-07-07 18:42:54 scottl Exp $
##
## REVISION HISTORY:
## $Log: config.tcl,v $
## Revision 1.1  2003-07-07 18:42:54  scottl
## Initial revision.
##
##
################################################################################


# PACKAGE DEPENDENCIES #
########################

# We need the file package to open and read the config file
#package require File


# NAMESPACE DECLARATION #
#########################
namespace eval ::Jtag::Config {

    # make all public procedures declared in this namespace available
    namespace export {[a-z]*}


    # NAMESPACE VARIABLES #
    #######################

    # Name of the configuration file
    variable configFile {.jconfig}

    # Configuration file data array.  Note that any of the default values for
    # the settings listed below will be overwritten if found in the 
    # configuration file.
    variable cnfg

    # Default selection mode
    set cnfg(def_mode) {crop}

    # Window size related each value should be a list with 2 positive numerical 
    # elements width then height, and window size must be larger than canvas
    # size.
    set cnfg(window_size) {900 900}
    set cnfg(canvas_size) {620 825}
    set cnfg(bucket_size) {50 50}

    # Position related options.
    set cnfg(window_pos) {0 0}

    # Journal component classification types and colours
    set cnfg(classifiers) {{body_text blue}      \
                           {title green}         \
                           {equation red}        \
                           {image orange}        \
                           {graph yellow}        \
                           {pg_number brown}     \
                          }

    # Array containing all selection data.  Each element name will be a
    # classifier, and each of its element will be an array giving its colour
    # and its selections.  Each of its selections will be an array giving its
    # id, co-ordinates, and metrics.  See specifcation.txt in the associated
    # documentation directory for more info.
    variable data

    set data(body_text,colour) blue
    set data(body_text,num_sels) 0
    set data(title,colour) green
    set data(title,num_sels) 0
    set data(equation,colour) red
    set data(equation,num_sels) 0
    set data(image,colour) orange
    set data(image,num_sels) 0
    set data(graph,colour) yellow
    set data(graph,num_sels) 0
    set data(pg_number,colour) brown
    set data(pg_number,num_sels) 0

}


# PUBLIC PROCEDURES #
#####################

# ::Jtag::Config::read_config --
#
#    Attempts to locate a valid configFile, then reads its contents to
#    set default values for configuration items
#
# Arguments:
#
# Results:
#    If a valid configFile is found, all default configuration items are
#    set to the appropriate values declared within the file

proc ::Jtag::Config::read_config {} {

    # link any namespace variables needed
    variable cnfg
    variable data

    # declare any local variables needed
    variable ConfigFile ""

    # get access to tcl internal global variables
    global appdir
    global env

    debug {entering ::Jtag::Config::read_config}

    # Attempt to locate the file in the current directory (or in the users
    # home directory if not found there)
#@@ TO COMPLETE
    #puts $env(HOME)

    # Since a valid file was found, pass it off for reading
    #::Jtag::File::parse_file $ConfigFile

    # The contents of the file are returned in a big list, each element of
    # which is also a list representing a setting name and its values.

    # for each classifier found, its associated data element should also be 
    # initialized.

}


# ::Jtag::Config::read_data --
#
#    Attempts to read the contents of a jtag selection file into memory,
#    storing the results in the data array.  For a detailed description of the
#    structure of the data array, see section 6.1 of the file
#    specification.txt in the doc directory.
#
# Arguments:
#    jtag_file    The complete path and name of a jtag file to be loaded.
#
# Results:
#    Provided that the file passed exists and contains validly formatted
#    selection data, its contents are read and stored appropriately in the
#    data array.  Otherwise an error is thrown back to the caller, with the
#    appropriate reason returned.

proc ::Jtag::Config::read_data {jtag_file} {

    # link any namespace variables needed
    variable data

    # declare any local variables needed
    variable ConfigFile ""

    debug {entering ::Jtag::Config::read_data}

    # first check and see if the file passed exists
    if {! [file exists $jtag_file]} {
        error "File passed does not exist"
    }

#@@ TO COMPLETE
    # pass the file off for reading
    # ::Jtag::File::parse_file

    # now load the data array appropriately

}


# PRIVATE PROCEDURES #
######################
