################################################################################
##
## FILE: menus.tcl
##
## DESCRIPTION: Responsible for the creation and manipulation of menu items
##              as part of the interface for the application.
##
## CVS: $Header: /p/learning/cvs/projects/jtag/menus.tcl,v 1.1 2003-07-04 17:04:14 scottl Exp $
##
## REVISION HISTORY:
## $Log: menus.tcl,v $
## Revision 1.1  2003-07-04 17:04:14  scottl
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

    # the zoom menu
    variable zoom
    set zoom(btn) {}
    set zoom(m) {}
    set zoom(attribs) {-text Zoom -underline 0}
    set zoom(in_btn) {}
    set zoom(out_btn) {}

    # the help menu
    variable help



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
    variable zoom
    variable help

    # declare any local variables needed
    # the options to set for the frame

    debug {entering ::Jtag::Menus::create}

    # start by setting up the frame that will contain all menu items
    set f(path) $w.f
    eval frame $f(path) $f(attribs)

    # setup all the menu buttons
    set file(btn) $f(path).file
    set file(m) $file(btn).menu
    eval menubutton $file(btn) -menu $file(m) $file(attribs)

    set zoom(btn) $f(path).zoom
    set zoom(m) $zoom(btn).menu
    eval menubutton $zoom(btn) -menu $zoom(m) $zoom(attribs)
    set zoom(in_btn) $f(path).zoom_in
    button $zoom(in_btn) -text {Zoom In (+)} -relief solid -overrelief raised \
           -command {::Jtag::Image::resize 2}
    set zoom(out_btn) $f(path).zoom_out
    button $zoom(out_btn) -text {Zoom Out (-)} -relief solid -overrelief \
           raised -command {::Jtag::Image::resize 0.5}

    # pack all on left except help (on right)
    pack $file(btn) $zoom(btn) $zoom(in_btn) $zoom(out_btn) -side left
    #pack $help()

    # create the file menu and its commands
    ::Jtag::Menus::FileMenu $file(m)

    # create the zoom menu and its commands
    ::Jtag::Menus::ZoomMenu $zoom(m)

    # create the help menu and its commands

    # inform Tk that these are all menus
    tk_menuBar $f(path) $file(btn)

    # return the path of the frame back to the caller
    return $f(path)

}


# PRIVATE PROCEDURES #
######################

# ::Jtag::Menus::FileMenu --
#
# Private helper to create the File menu and bind appropriate commands to its
# items.
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

    debug {entering ::Jtag::Menus::FileMenu}

    # create the menu
    set M [menu $path]

    # now add its commands
    $M add command -label "Quit" -accelerator "<Ctrl-q>" -command {exit 0}

    # now set any global bindings (these work even outside of this widget so
    # care must be taken to ensure the bindings don't overwrite other widget
    # bindings
    bind . <Control-q> {exit 0}

}


# ::Jtag::Menus::ZoomMenu --
#
# Private helper to create the Zoom menu and bind appropriate commands to its
# items.
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

    debug {entering ::Jtag::Menus::ZoomMenu}

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
