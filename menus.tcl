################################################################################
##
## FILE: menus.tcl
##
## DESCRIPTION: Responsible for the creation and manipulation of menu items
##              as part of the interface for the application.
##
## CVS: $Header: /p/learning/cvs/projects/jtag/menus.tcl,v 1.3 2003-07-18 18:01:36 scottl Exp $
##
## REVISION HISTORY:
## $Log: menus.tcl,v $
## Revision 1.3  2003-07-18 18:01:36  scottl
## - Fixed bug in OpenCmd where 'data' array elements not being removed properly
## - Implemented multiple page previous and next buttons.
##
## Revision 1.2  2003/07/15 16:45:56  scottl
## Created an edit menu.  Implemented the Quit, Open, and Delete commands.
##
## Revision 1.1  2003/07/04 17:04:14  scottl
## Initial (incomplete) revision.
##
##
################################################################################


# PACKAGE DEPENDENCIES #
########################

package require Tk 8.3


# NAMESPACE DECLARATION #
#########################
namespace eval ::Jtag::Menus {

    # make all public procedures declared in this namespace available
    namespace export {[a-z]*}


    # NAMESPACE VARIABLES #
    #######################

    # the path to the frame containing all menu items
    variable f
    set f(path) {}
    set f(attribs) {-relief raised -borderwidth 3}

    # the file menu
    variable file
    set file(btn) {}
    set file(m) {}
    set file(attribs) {-text File -underline 0}

    # the edit menu
    variable edit
    set edit(btn) {}
    set edit(m) {}
    set edit(attribs) {-text Edit -underline 0}
    set edit(next_btn) {}
    set edit(prev_btn) {}

    # the zoom menu
    variable zoom
    set zoom(btn) {}
    set zoom(m) {}
    set zoom(attribs) {-text Zoom -underline 0}
    set zoom(in_btn) {}
    set zoom(out_btn) {}

    # the help menu
    variable help
    set help(btn) {}
    set help(m) {}
    set help(attribs) {-text Help -underline 0}

    # the default filetypes to show in the open dialog
    variable types { {{jtag image formats} \
                      {.tif .tiff .jpg .jpeg .png .gif} \
                     } }
     

}


# PUBLIC PROCEDURES #
#####################

# ::Jtag::Menus::create --
#
#    Attempts to add all the necessary menus and buttons inside the window
#    passed.  Also creates any keyboard/mouse bindings required for
#    interfacing with the menus.
#
# Arguments:
#    w    The parent widget (window) within which the menus will sit.  Usually
#         this window will be the root window.
#
# Results:
#    Returns the full path of the frame created to house all the menus upon
#    success.  If there is a problem at any point during the creation or
#    binding, then an error is returned.

proc ::Jtag::Menus::create {w} {

    # link any namespace variables needed
    variable f
    variable file
    variable edit
    variable zoom
    variable help

    # declare any local variables needed
    variable I

    debug {entering ::Jtag::Menus::create}

    # start by setting up the frame that will contain all menu items
    set f(path) $w.f
    eval frame $f(path) $f(attribs)

    # setup all the menu buttons
    foreach I {file edit zoom help} {
        set ${I}(btn) $f(path).$I
        eval set ${I}(m) $${I}(btn).menu
        eval menubutton $${I}(btn) -menu $${I}(m) [subst $${I}(attribs)]
    }

    set zoom(in_btn) $f(path).zoom_in
    button $zoom(in_btn) -text {Zoom In (+)} -relief solid -overrelief raised \
           -command {::Jtag::Image::resize 2}
    set zoom(out_btn) $f(path).zoom_out
    button $zoom(out_btn) -text {Zoom Out (-)} -relief solid -overrelief \
           raised -command {::Jtag::Image::resize 0.5}

    # pack all on left except help (on right)
    pack $file(btn) $edit(btn) $zoom(btn) $zoom(in_btn) $zoom(out_btn) \
         -side left
    pack $help(btn) -side right

    # create the file menu
    ::Jtag::Menus::FileMenu $file(m)

    # create the edit menu
    ::Jtag::Menus::EditMenu $edit(m)

    # create the zoom menu
    ::Jtag::Menus::ZoomMenu $zoom(m)

    # create the help menu and its commands

    # return the path of the frame back to the caller
    return $f(path)

}


# ::Jtag::Menus::multi_page_functions --
#
#    Enables or disables the ability to perform commands and display buttons
#    related to multiple documents (that meet the form described in the
#    specifications.txt document)
#
# Arguments:
#    on    Set to 1 if we are enabling mutiple page functionality, all other
#          values assume we are disabling functionality
#
# Results:
#    If on is set to 1 we enable the user to flip between consecutive pages of
#    a multi-page document by displaying buttons and menu commands to do so.
#    Otherwise we remove this buttons and commands from the menu

proc ::Jtag::Menus::multi_page_functions {on} {

    # link any namespace variables necessary
    variable f
    variable edit
    variable ::Jtag::Image::img

    # declare any local variables necessary

    debug {entering ::Jtag::Menus::multi_page_functions}

    if {$on && $img(multi_page)} {
        if {$f(path) == ""} {
            debug "No generated menus present, can't enable multi_page"
            return
        }

        set edit(next_btn) $f(path).next
        set edit(prev_btn) $f(path).prev

        # remove the buttons if they already exist
        destroy $edit(next_btn) $edit(prev_btn)

        button $edit(next_btn) -text {Next Page} -relief solid \
              -overrelief raised -command \
                          {::Jtag::Image::go_to_pg \
                          [expr $::Jtag::Image::img(curr_page) + 1]}
        button $edit(prev_btn) -text {Prev Page} -relief solid \
              -overrelief raised -command \
                          {::Jtag::Image::go_to_pg \
                          [expr $::Jtag::Image::img(curr_page) - 1]}

        bind . <Next> {::Jtag::Image::go_to_pg \
                       [expr $::Jtag::Image::img(curr_page) + 1]}
        bind . <Prior> {::Jtag::Image::go_to_pg \
                       [expr $::Jtag::Image::img(curr_page) - 1]}

        pack $edit(next_btn) $edit(prev_btn) -side left

    } else {
        destroy $edit(next_btn)
        destroy $edit(prev_btn)
    }
}



# PRIVATE PROCEDURES #
######################

# ::Jtag::Menus::FileMenu --
#
#    Private helper to create the File menu and bind appropriate commands to 
#    its items.
#
# Arguments:
#    path    The full Tk widget heirarchy path where this widget will be
#            created within.
#
# Results:
#    An error is returned if there is a problem at any point during menu
#    creation or binding, otherwise nothing is returned.

proc ::Jtag::Menus::FileMenu {path} {

    # link any namespace variables needed

    # declare any local variables needed
    # the menu reference
    variable M

    # create the menu
    set M [menu $path]

    # now add its commands
    $M add command -label "Open" -accelerator "<Ctrl-o>" -command \
                              {::Jtag::Menus::OpenCmd}
    $M add command -label "Quit" -accelerator "<Ctrl-q>" -command \
                              {::Jtag::Menus::QuitCmd}

    # now set any global bindings (these work even outside of this widget so
    # care must be taken to ensure the bindings don't overwrite other widget
    # bindings
    bind . <Control-q> {::Jtag::Menus::QuitCmd}
    bind . <Control-o> {::Jtag::Menus::OpenCmd}

}


# ::Jtag::Menus::EditMenu --
#
#    Private helper to create the Edit menu and bind appropriate commands to 
#    its items.
#
# Arguments:
#    path    The full Tk widget heirarchy path where this widget will be
#            created within.
#
# Results:
#    An error is returned if there is a problem at any point during menu
#    creation or binding, otherwise nothing is returned.

proc ::Jtag::Menus::EditMenu {path} {

    # link any namespace variables needed

    # declare any local variables needed
    # the menu reference
    variable M

    # create the menu
    set M [menu $path]

    # now add its commands
    $M add command -label "Delete" -accelerator "<Ctrl-x>" -command \
                               {::Jtag::Menus::DeleteCmd}

    bind . <Control-x> {::Jtag::Menus::DeleteCmd}

    # next page (if multi-page)

    # previous page (if multi-page)

}


# ::Jtag::Menus::ZoomMenu --
#
#    Private helper to create the Zoom menu and bind appropriate commands to 
#    its items.
#
# Arguments:
#    path    The full Tk widget heirarchy path where this widget will be
#            created within.
#
# Results:
#    An error is returned if there is a problem at any point during menu
#    creation or binding, otherwise nothing is returned.

proc ::Jtag::Menus::ZoomMenu {path} {

    # link any namespace variables needed
    variable zoom

    # declare any local variables needed
    # the menu reference
    variable M

    # create the menu
    set M [menu $path]

    # now add its commands
    $M add command -label "In" -accelerator "<+>" \
                   -command "$zoom(in_btn) invoke"
    $M add command -label "Out" -accelerator "<->" \
                   -command "$zoom(out_btn) invoke"

    # now set any global bindings (these work even outside of this widget so
    # care must be taken to ensure the bindings don't overwrite other widget
    # bindings
    bind . + "$zoom(in_btn) invoke"
    bind . - "$zoom(out_btn) invoke"

}


# ::Jtag::Menus::QuitCmd --
#
#    Method that will perform any cleanup operations and terminate the
#    application gracefully when called.
#
# Arguments:
#
# Results:
#    All current selection information is written out to the appropriate jtag
#    and jlog files, then the application is terminated.

proc ::Jtag::Menus::QuitCmd {} {

    # link any namespace variables needed

    # declare any local variables needed
    variable Result

    # write out selection information
    if {[ catch {::Jtag::Config::write_data} Result]} {
        debug "Failed to write out selection information.  Reason:\n$Result"
        exit -1
    }

    # terminate the application
    exit 0

}


# ::Jtag::Menus::OpenCmd --
#
#    Method that will open a new image file (and its associated jtag file) i
#    after saving the existing file and its selections (if any)
#
# Arguments:
#
# Results:
#    After the user selects a file from a browser dialog, the existing file
#    selections are written out, and the new file is attempted to be opened.
#    If the open is successful, its jtag file is searched out, and any
#    selections listed for it are created and added.

proc ::Jtag::Menus::OpenCmd {} {

    # link any namespace variables needed
    variable types
    variable ::Jtag::Config::data

    # declare any local variables needed
    variable File
    variable Response
    variable Rects

    # open a file browser
    set File [tk_getOpenFile -filetypes $types]

    # write out and remove the current selections and array data
    if {[ catch {::Jtag::Config::write_data} Response]} {
        debug "Failed to write old selection information.  Reason:\n$Response"
    }
    while {[array names data -regexp {(.*)(,)([0-9])+}] != ""} {
        ::Jtag::Classify::remove [lindex \
             [array names data -regexp {(.*)(,)([0-9])+}] 0]
    }
    ::Jtag::Image::clear_canvas

    # load the new image and jtag data
    if {[catch {::Jtag::Image::create_image $File} Response]} {
        debug "Failed to validate/display new image.  Reason:\n$Response"
    }
}


# ::Jtag::Menus::DeleteCmd --
#
#    Method that will delete the rectangle that the mouse is over (if it is
#    currently over a rectangle) and update the data array appropriately.
#
# Arguments:
#
# Results:
#    If the mouse is over a rectangle, then it is removed and the 'data' array
#    is updated.  Otherwise nothing happens

proc ::Jtag::Menus::DeleteCmd {} {

    # link any namespace variables needed
    variable ::Jtag::Image::can

    # declare any local variables needed
    variable Rect
    variable SelRef

    if {! $can(created)} {
        return
    }

    set Rect [$can(path) find withtag current]
    if {$Rect == "" || $Rect == $can(img_tag)} {
        return
    }

    set SelRef [::Jtag::Classify::get_selection $Rect]

    # delete the item from the canvas
    $can(path) delete $Rect

    # update the 'data' array to reflect this if necessary
    if {$SelRef != ""} {
        ::Jtag::Classify::remove $SelRef
    }

}
