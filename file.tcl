################################################################################
##
## FILE: file.tcl
##
## DESCRIPTION: Responsible for all things file related within the application
##
## CVS: $Header: /p/learning/cvs/projects/jtag/file.tcl,v 1.1 2003-07-07 18:43:12 scottl Exp $
##
## REVISION HISTORY:
## $Log: file.tcl,v $
## Revision 1.1  2003-07-07 18:43:12  scottl
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
#    lines if they contain the '[' and ']' characters.  If there is a 
#    problem either locating, opening, or reading the file an appropriate 
#    error is returned.

proc ::Jtag::File::parse {fileToRead} {

    #@@ to complete
    debug {entering ::Jtag::File::parse}
}


# PRIVATE PROCEDURES #
######################
