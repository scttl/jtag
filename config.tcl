################################################################################
##
## FILE: config.tcl
##
## DESCRIPTION: Holds all "global" (namespace) data as well as default
##              configuration settings for the jtag application.  Also
##              contains methods to update these settings.
##
## CVS: $Header: /p/learning/cvs/projects/jtag/config.tcl,v 1.4 2003-07-15 16:40:44 scottl Exp $
##
## REVISION HISTORY:
## $Log: config.tcl,v $
## Revision 1.4  2003-07-15 16:40:44  scottl
## Removed a couple of temporary statements that should not have been in place.
##
## Revision 1.3  2003/07/14 15:11:53  scottl
## Moved classifier defaults from cnfg element to data array elements.
## Implemented ability to read config file information.
## Implemented ability to read selection information from a jtag file.
## Implemented ability to write selection information out to a jtag file.
##
## Revision 1.2  2003/07/07 19:10:33  scottl
## Renamed def_mode parameter to mode, now it will be used to hold the current
## selection mode in use by the appplication.
##
## Revision 1.1  2003/07/07 18:42:54  scottl
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
    variable config_file {.jconfig}

    # name of the configuration variable denoting the classifiers list
    variable class_name {classifiers}

    # Configuration file data array.  Note that any of the default values for
    # the settings listed below will be overwritten if found in the 
    # configuration file.
    variable cnfg

    # Default selection mode
    set cnfg(mode) {crop}

    # Window size related each value should be a list with 2 positive numerical 
    # elements width then height, and window size must be larger than canvas
    # size.
    set cnfg(window_size) {900 900}
    set cnfg(canvas_size) {620 825}
    set cnfg(bucket_size) {50 50}

    # Position related options.
    set cnfg(window_pos) {0 0}

    # Journal component classification types and colours are stored in the
    # 'data' array.

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

    # Format for the data contained in the .jtag and .jlog files
    variable hpre
    variable separator {---}
    variable btpre

    # all of the header prefixes
    set hpre(img) {img}
    set hpre(type) {type}
    set hpre(res) {resolution}
    set hpre(cksum) {cksum}

    # all of the jtag body prefixes
    set btpre(class) {class}
    set btpre(pos) {pos}
    set btpre(mode) {mode}
    set btpre(colour) {colour}

}


# PUBLIC PROCEDURES #
#####################

# ::Jtag::Config::read_config --
#
#    Attempts to locate a valid config file, then reads its contents to
#    set default values for configuration items
#
# Arguments:
#
# Results:
#    If a valid config file is found, all default configuration items are
#    set to the appropriate values declared within the file.  If any problems
#    are encountered, a set of built-in defaults are loaded instead (no errors
#    are reported back to the caller).

proc ::Jtag::Config::read_config {} {

    # link any namespace variables needed
    variable config_file
    variable class_name
    variable cnfg
    variable data

    # declare any local variables needed
    variable ConfigPath ""
    variable Result
    variable ElemList
    variable Name

    # get access to tcl internal global variables
    global appdir
    global env

    debug {entering ::Jtag::Config::read_config}

    # Attempt to locate the file in the current directory (or in the users
    # home directory if not found there)
    if {[file exists $env(PWD)/$config_file]} {
        set ConfigPath $env(PWD)/
    } elseif {[file exists $env(HOME)/$config_file]} {
        set ConfigPath $env(HOME)/
    } else {
        debug "No config file found in the current or home directory."
        debug "Loading hard-coded dafaults instead"
        return
    }
        
    # Since a valid file was found, pass it off for reading
    if {[catch {::Jtag::File::parse ${ConfigPath}$config_file} Result]} {
        debug "Problems reading ${ConfigPath}$config_file.  Reason:\n$Result"
        debug "Loading hard-coded defaults instead"
        return
    }

    # The contents of the file are returned in a big list (Result), each 
    # element of which is also a list representing a setting name element
    # followed by one or more value elements.
    foreach ElemList $Result {
        set Name [string tolower [lindex $ElemList 0]]

        if {$Name == $class_name} {
            # classifiers are handled differently in that their information is
            # stored in the 'data' array instead of the 'cnfg' array

            # elements of the list after the name should be in pairs, the
            # first element gives the classifier name and the second its
            # colour.

            # ensure that there are an even number of elements for pairing
            if {! [llength [lrange $ElemList 1 end]] %2} {
                debug "Found classifier with no colour pair specified"
                debug "Loading ard-coded classifier defaults instead"
                return
            }

            # add the new classifier and colour to the list
            for {set I 1} {$I < [llength $ElemList]} {incr I 2} {
                set data([lindex $ElemList $I],colour) \
                                           [lindex $ElemList [expr $I + 1]]
                set data([lindex $ElemList $I],num_sels) 0
            }

        } else {
            set cnfg($Name) [lrange $ElemList 1 end]
        }
    }
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
    variable ::Jtag::Image::img
    variable ::Jtag::Image::can
    variable btpre

    # declare any local variables needed
    variable ConfigFile ""
    variable Result
    variable ElemList
    variable I
    variable Class
    variable Canvas
    variable X1
    variable Y1
    variable X2
    variable Y2
    variable Mode
    variable Colour


    debug {entering ::Jtag::Config::read_data}

    # first check and see if the file passed exists
    if {! [file exists $jtag_file]} {
        error "File passed does not exist"
    }

    # ensure there's an image and canvas upon which to add selections
    if { ! [::Jtag::Image::exists]} {
        error "Trying to add selections for a non-existent image"
    } elseif {! $can(created)} {
        error "Trying to add selections to a non-existent canvas"
    }

    set Canvas $can(path)

    # pass the file off for reading
    if {[catch {::Jtag::File::parse $jtag_file} Result]} {
        error "Problems reading $jtag_file  Reason:\n$Result"
    }

    # ensure that the data read matches the file in memory (cksum's)
    if { ! [::Jtag::Image::exists] || 
         $img(cksum) != [lindex [lindex $Result 3] 1]} {
       error "$jtag_file specifies data for a different or non-existent image"
    }

    # ensure that the total number of elements returned is a multiple of 4
    # the first 4 fields are headers (like cksum etc.) and then each multiple
    # of 4 after that specifies a complete selection
    if {[llength $Result] % 4 } {
        error "$jtag_file has an incorrect number of fields"
    }

    for {set I 4} {$I < [llength $Result]} {incr I 4} {
        set ElemList [lindex $Result $I]
        if {[llength $ElemList] != 2 || \
            [lindex $ElemList 0] != $btpre(class)} {
            error "Corrupt data in file $jtag_file at line:\n$ElemList"
        } elseif {[array names data -exact [lindex $ElemList 1],num_sels] \
                                            == ""} {
            debug "Classifier: [lindex $ElemList 1] unknown. Selection ignored"
            continue
        } else {
            set Class [lindex $ElemList 1]
        }

        set ElemList [lindex $Result [expr $I + 1]]

        if {[llength $ElemList] != 5 || \
            [lindex $ElemList 0] != $btpre(pos)} {
            error "Corrupt data in file $jtag_file at line:\n$ElemList"
        } else {
            set X1 [lindex $ElemList 1]
            set Y1 [lindex $ElemList 2]
            set X2 [lindex $ElemList 3]
            set Y2 [lindex $ElemList 4]
        }

        set ElemList [lindex $Result [expr $I + 2]]

        if {[llength $ElemList] != 2 || \
            [lindex $ElemList 0] != $btpre(mode)} {
            error "Corrupt data in file $jtag_file at line:\n$ElemList"
        } else {
            set Mode [lindex $ElemList 1]
        }

        set ElemList [lindex $Result [expr $I + 3]]

        if {[llength $ElemList] != 2 || \
            [lindex $ElemList 0] != $btpre(colour)} {
            error "Corrupt data in file $jtag_file at line:\n$ElemList"
        } elseif {$data($Class,colour) != [lindex $ElemList 1]} {
            debug \
               "Overwriting selection colour since it doesn't match classifier"
        }

        # since everything was found ok, add the selection
        ::Jtag::Classify::add $Canvas $Class $X1 $Y1 $X2 $Y2 $Mode

    }

}


# ::Jtag::Config::write_data --
#
#    Attempts to dump the contents of the 'data' array and some header
#    information out to the appropriate jtag file.
#
# Arguments:
#
# Results:
#    Provided that an image has been created already, its information,
#    configuration information, and all selection information in the data
#    array are written out to disk in a jtag file created by renaming the
#    extension of the image to jtag.  If the image has not been created yet,
#    nothing is written but no error is returned.  In all other cases, an
#    error is returned to the caller.

proc ::Jtag::Config::write_data {} {

    # link any namespace variables needed
    variable ::Jtag::Image::img
    variable data

    # declare any local variables needed
    variable DList {}
    variable FileName
    variable hpre
    variable separator
    variable btpre
    variable CommentPre {# }


    debug {entering ::Jtag::Config::write_data}

    # first check and see if an image has been created
    if {! [::Jtag::Image::exists]} {
        debug {no image to write}
        return
    }

    # create the header
    if {$img(jtag_name) == ""} {
        error {jtag file is empty}
    }
    set TmpDims [join [::Jtag::Image::get_actual_dimensions] x]
    set FileHeader "FILE: $img(jtag_name)"
    set TimeStamp "DUMPED: [clock format [clock seconds] -format %c]"
    #set User  "BY: []"
    set ImageHeader "IMAGE INFO:"
    lappend DList ${CommentPre}$FileHeader \
                  ${CommentPre}$TimeStamp \
                  "" \
                  ${CommentPre}$ImageHeader \
                  "${hpre(img)} = $img(file_name)" \
                  "${hpre(type)} = $img(file_format)" \
                  "${hpre(res)} = $TmpDims" \
                  "${hpre(cksum)} = $img(cksum)" \
                  ""

    # now add commented out version of the config data used
    set ConfigHeader {CONFIGURATION INFO:}
    lappend DList ${CommentPre}$ConfigHeader
    set DList [concat $DList [::Jtag::Config::DumpConfig $CommentPre]]
    lappend DList ""

    # now add the selection data
    set SelectionHeader {CLASSIFICATION INFO:}
    lappend DList ${CommentPre}$SelectionHeader
    foreach I [array names data -regexp {(.*)(,)([0-9]+)}] {
        regexp {(.*)(,)([0-9]+)} $I M Class Comma Num
        set Pos [join [lrange $data($I) 1 4] " "]
        set Mode [lindex $data($I) 5]
        set Colour $data($Class,colour)
        lappend DList $separator \
                      "${btpre(class)} = $Class" \
                      "${btpre(pos)} = $Pos" \
                      "${btpre(mode)} = $Mode" \
                      "${btpre(colour)} = $Colour"
    }

    # now send the data off to the file for writing (catching any errors)
    ::Jtag::File::write $img(jtag_name) $DList

}


# PRIVATE PROCEDURES #
######################

# ::Jtag::Config::DumpConfig --
#
#    Dumps all the current configuration data (taken from the array cnfg) to a
#    list, giving one element name and value pair per element.
#
# Arguments:
#    pre    (optional) A prefix string to put in front of every element.
#           Defaults to nothing (the empty string).
#
# Results:
#    Returns a list of elements, each of which represents one name-value pair
#    taken from the cnfg array.

proc ::Jtag::Config::DumpConfig {{pre ""}} {

    # link any namespace variables
    variable cnfg
    variable data
    variable class_name

    # declare any local variables
    variable List {}
    variable DataList {}
    variable Name
    variable I

    # loop over each item in the cnfg array, adding its name and value to
    # the List.
    foreach I [array names cnfg] {
        lappend List "$pre $I = $cnfg($I)"
    }

    # output all the names and colours in the data array, adding as a single
    # list
    foreach I [array names data -regexp {(.*)(,)(colour)}] {
        regexp {(.*)(,)(colour)} $I Dummy Name
        lappend DataList "$pre    $Name $data($I)"
    }

    if {$DataList != ""} {
        lappend List "$pre $class_name = \("
        set List [concat $List $DataList]
        lappend List "$pre \)"
    }
    return $List

}
