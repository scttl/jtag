################################################################################
##
## FILE: file.tcl
##
## DESCRIPTION: Responsible for all things file related within the application
##
## CVS: $Header: /p/learning/cvs/projects/jtag/file.tcl,v 1.2 2003-07-10 16:22:06 scottl Exp $
##
## REVISION HISTORY:
## $Log: file.tcl,v $
## Revision 1.2  2003-07-10 16:22:06  scottl
## Implemented write and parse methods.
##
## Revision 1.1  2003/07/07 18:43:12  scottl
## Initial revision.
##
##
################################################################################


# PACKAGE DEPENDENCIES #
########################



# NAMESPACE DECLARATION #
#########################
namespace eval ::Jtag::File {

    # make all public procedures declared in this namespace available
    namespace export {[a-z]*}


    # NAMESPACE VARIABLES #
    #######################


}


# PUBLIC PROCEDURES #
#####################

# ::Jtag::File::parse --
#
#    Attempts to open and read all the contents of the file given by the
#    name passed.
#
# Arguments:
#    fileToRead    The fully qualified path and name of the file to be read
#
# Results:
#    Returns a list containing list elements, each represents a single
#    non-comment line in the file (its elements are the string words of that
#    line separated by spaces.  Exceptions to this include grouping multiple
#    lines if they contain the '(' and ')' characters.  If there is a 
#    problem either locating, opening, or reading the file an appropriate 
#    error is returned.

proc ::Jtag::File::parse {fileToRead} {

    # declare any local variables needed
    variable FID
    variable Line
    variable Data {}
    variable CommentPos
    variable MultiOn 0
    variable MultiData {}
    variable Match
    variable Name
    variable Vals
    variable Vals2

    debug {entering ::Jtag::File::parse}

    # open the file for reading
    set FID [open $fileToRead r]

    # loop over each line, one at a time
    while {! [eof $FID]} {
        set Line [string trimleft [gets $FID]]
        set CommentPos [string first "#" $Line]
        if {$CommentPos != -1} {
            set Line [string range $Line 0 [expr $CommentPos -1]]
        }
        if {$Line == ""} {
            # emtpy line (or removed comment line)
            continue
        } elseif {! $MultiOn && 
                  [regexp ^(.+)=(.*)\\((.*)$ $Line Match Name Vals Vals2]} {
            # multi-line start
            lappend MultiData [string trim $Name]
            set Vals [string trim $Vals]
            if {$Vals != ""} {
                set MultiData [concat $MultiData [SplitTrim $Vals]]
            }
            set Vals2 [string trim $Vals2]
            if {$Vals2 != ""} {
                set MultiData [concat $MultiData [SplitTrim $Vals2]]
            }
            set MultiOn 1
        } elseif {$MultiOn} {
            if {[regexp ^(.*)(\\))(.*)$ $Line Match Vals]} {
                # multi-line end
                set Vals [string trim $Vals]
                if {$Vals != ""} {
                    set MultiData [concat $MultiData [SplitTrim $Vals]]
                }
                lappend Data $MultiData
                set MultiOn 0
                set MultiData {}
            } else {
                # multi-line continue
                set Line [string trim $Line]
                if {$Line != ""} {
                    set MultiData [concat $MultiData [SplitTrim $Line]]
                }
            }
        } elseif {! $MultiOn && [regexp ^(.+)=(.+)$ $Line Match Name Vals]} {
            # normal, valid single line
            set Vals [string trim $Vals]
            lappend Data [concat [string trim $Name] [SplitTrim $Vals]]
        } else {
            error "Invalid config file line:\n$Line"
        }
    }

    if {$MultiOn} {
        error "Could not find closing ')' during parse"
    }

    return $Data

}


# ::Jtag::File::write --
#
#    Writes the contents passed to the filename passed.  The contents should
#    be in the form of a list whereby each element represents a line to be
#    written.
#
# Arguments:
#    fileToWrite    The fully qualified path and name of the file to write
#    data           The list containing the contents to write
#
# Results:
#    If the file specified by fileToWrite does not exist, a new file is
#    attempted to be created and the contents of data are written to it.  If
#    it does exist, its contents are overwritten with that in data (which may
#    be empty).  If there is a problem opening or writing to fileToWrite an
#    error is returned.

proc ::Jtag::File::write {fileToWrite data} {

    # declare any local variables needed
    variable FID
    variable Line

    debug {entering ::Jtag::File::write}

    # open the file for writing
    set FID [open $fileToWrite w]

    # loop over each element in data, writing it as a single line
    foreach Line $data {
        puts $FID $Line
    }

    # flush and close the file
    close $FID

}
# PRIVATE PROCEDURES #
######################


# ::Jtag::File::SplitTrim --
#
#    Helper function identical to the internal Tcl/Tk split command except
#    that this command does not add any empty elements in the case of matching
#    multiple adjacent split characters (they are ignored)
#
# Arguments:
#    s         The input string to split
#    splits    (optional) The list of characters to use for splitting.
#              Defaults to whitespace if not specified
#
# Results:
#    Returns a single list created by splitting s at each character in splits
#    if it is specified.  Empty list elements are not included in the returned
#    list.

proc ::Jtag::File::SplitTrim {s {splits " \t\n"}} {

    # declare any local variables needed
    variable List
    variable I

    set List [split $s $splits]

    # remove any empty elements
    for {set I 0} {$I < [llength $List]} {incr I} {
        if {[lindex $List $I] == ""} {
            set List [lreplace $List $I $I]
            # since we shift each element up, we must make sure we keep I the
            # same so as to check the next element
            set I [expr $I - 1]
        }
    }

    return $List

}
