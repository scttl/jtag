################################################################################
##
## FILE: ui.tcl
##
## DESCRIPTION: Responsible for all things related to the user interface.
##              This includes the display of all window components and
##              responding to user generated events (key presses mouse etc.)
##
## CVS: $Header: /p/learning/cvs/projects/jtag/ui.tcl,v 1.3 2003-07-16 19:09:08 scottl Exp $
##
## REVISION HISTORY:
## $Log: ui.tcl,v $
## Revision 1.3  2003-07-16 19:09:08  scottl
## Fix to ensure both button frames maintain equal widths.
##
## Revision 1.2  2003/07/10 19:19:42  scottl
## Throw errors during UI creation problems instead of displaying a debug message
## and continuing on.
##
## Revision 1.1  2003/07/04 17:02:51  scottl
## Initial revision.
##
##
################################################################################


# PACKAGE DEPENDENCIES #
########################

package require Tk 8.3
package require autoscroll
namespace import ::autoscroll::autoscroll



# NAMESPACE DECLARATION #
#########################
namespace eval ::Jtag::UI {

    # make all public procedures declared in this namespace available
    namespace export {[a-z]*}

    # Import all the data from ::Jtag::Config into this namespace
    namespace import ::Jtag::Config::*

    # NAMESPACE VARIABLES #
    #######################

    # The title of the application
    variable title {J T A G -- Journal Image Tagger}

    # Widget paths
    # The root window (all widgets placed inside this)
    variable w_root
    # The menu and its associated buttons
    variable f_menu
    # The canvas object that houses the journal image
    variable c_img
    # The horizontal scrollbar that appears whenever the image exceeds the 
    # canvas size
    variable cs_x
    # The vertical scrollbar that appears whenever the image exceeds the 
    # canvas size
    variable cs_y
    # The list of classification buckets (one for each type of classification)
    variable f_buckets

} end namespace declaration


# PUBLIC PROCEDURES #
#####################

# ::Jtag::UI::create --
#
#    Attempts to create and arrange window components to display them in 
#    an appropriate manner to the user.
#
# Arguments:
#
# Results:
#    The complete user interface (widgets, the canvas, menu items, etc.) are
#    displayed on screen and 0 is returned, otherwise an error is thrown.

proc ::Jtag::UI::create {} {

    # link any namespace variables needed
    variable ::Jtag::Config::cnfg
    variable title
    variable w_root
    variable c_img
    variable f_menu
    variable cs_x
    variable cs_y
    variable f_buckets

    # declare any local variables needed
    # store the width and height to scale the image by to fit on screen
    variable ScaleW
    variable ScaleH

    # canvas co-ords (area viewable at any time)
    variable Left 0
    variable Top 0
    variable Right [lindex $cnfg(canvas_size) 0]
    variable Bottom [lindex $cnfg(canvas_size) 1]

    # default image size
    variable Width [lindex $cnfg(canvas_size) 0]
    variable Height [lindex $cnfg(canvas_size) 1]

    # current geometry dimensions list
    variable DimList

    # generic looping related variables
    variable I
    variable Count

    # used to layout widgets in the grid
    variable RowCount


    debug {entering ::Jtag::UI::create}

    # setup all window manager related attributes
    wm title . $title
    wm geometry . [join $cnfg(window_size) x][join [linsert \
                  [linsert $cnfg(window_pos) 1 +] 0 +] {}]

    # configure the root window
    set w_root {}

    # setup the menu and its frame
    if {[catch {::Jtag::Menus::create $w_root} f_menu]} {
        error "failed to create menu system.  Reason:\n$f_menu"
    }

    # setup the image canvas (and its autoscrollbars)
    if {[::Jtag::Image::exists]} {
        # get the right, and bottom from the image attributes
        set DimList [::Jtag::Image::get_current_dimensions]
        set Right [expr [lindex $DimList 0] - $Left]
        set Bottom [expr [lindex $DimList 1] - $Top]
    }

    if {[catch {::Jtag::Image::create_canvas $w_root $Width $Height} \
                c_img]} {
        error "failed to create image canvas.  Reason:\n$c_img"
    }

    if {[catch {::Jtag::Image::add_scrollbars \
                [list $Left $Top $Right $Bottom]} C_scrolls]} {
        error "failed to add scrollbars.  Reason:\n$C_scrolls"
    }

    set cs_x [lindex $C_scrolls 0]
    set cs_y [lindex $C_scrolls 1]

    # setup the buckets
    if {[ catch {::Jtag::Classify::create_buckets $w_root $w_root} f_buckets]} {
        error "failed to create buckets.  Reason:\n$f_buckets"
    }

    if {[::Jtag::Image::exists]} {
        # scale the image so that it fits in our viewing window
        set ScaleW [expr $Width / ($Right - $Left + 0.0)]
        set ScaleH [expr $Height / ($Bottom - $Top + 0.0)]
        ::Jtag::Image::resize [expr $ScaleW<=$ScaleH ? $ScaleW : $ScaleH]

        # bind the mouse to the canvas to allow selections
        ::Jtag::Classify::bind_selection $c_img
    }

    # layout all the widgets created in a grid
    grid $f_menu -row 0 -column 0 -columnspan 4 -sticky ew
    grid $c_img -row 1 -column 1 -sticky nsew
    grid [lindex $f_buckets 0] -row 1 -column 0 -sticky nsew
    grid [lindex $f_buckets 1] -row 1 -column 3 -sticky nsew
    grid $cs_y -row 1 -column 2 -sticky ns
    grid $cs_x -row 2 -column 1 -sticky ew

    grid columnconfigure . 0 -minsize 0 -uniform buttons
    grid columnconfigure . 1 -weight 2
    grid columnconfigure . 3 -minsize 0 -uniform buttons
    grid rowconfigure . 1 -weight 1

    autoscroll $cs_x
    autoscroll $cs_y


}



# PRIVATE PROCEDURES #
######################
