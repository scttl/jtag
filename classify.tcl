################################################################################
##
## FILE: classify.tcl
##
## DESCRIPTION: Contains methods to carry out the classification process
##              (selection of text, bucket selection etc.)
##
## CVS: $Header: /p/learning/cvs/projects/jtag/classify.tcl,v 1.10 2003-07-21 15:21:36 scottl Exp $
##
## REVISION HISTORY:
## $Log: classify.tcl,v $
## Revision 1.10  2003-07-21 15:21:36  scottl
## Implemented automatic snapping of selections to bound text based on percentage
## of non-background ink found.
##
## Revision 1.9  2003/07/18 17:58:48  scottl
## - Fixed bug whereby already classified resizes where not being updated in the
##   data array.
## - Also split AddToBucket into a helper so that the helper can be used
##   elsewhere.
##
## Revision 1.8  2003/07/16 20:51:20  scottl
## Bugfix to allow proper resizing when scrolled away from top-left corner.
##
## Revision 1.7  2003/07/16 20:28:05  scottl
## Renamed classifiers to classes to avoid confusion with the name.
##
## Revision 1.6  2003/07/16 19:08:37  scottl
## Increased default size of rectangles.
##
## Revision 1.5  2003/07/15 16:44:27  scottl
## - Renamed CheckReclassify method to get_selection and exported it for
##   availability to other namespaces
## - Implemented unbind_selection method to control bindings when opening
##   multiple images
## - Implemented remove method to cleanup data array and intelligently remove
##   elements
##
## Revision 1.4  2003/07/14 19:06:58  scottl
## Implemented "simple" mode, made resizing more robust.
##
## Revision 1.3  2003/07/14 15:09:17  scottl
## Created add procedure to update the contents of the data array and optionally
## create rectangles if neccessary.
##
## Revision 1.2  2003/07/10 19:25:12  scottl
## Get classifications from data array instead of cnfg.
## Removed temporary debugging puts outputs.
## Normailzed selection co-ordinates when stored in the data array.
##
## Revision 1.1  2003/07/08 14:57:39  scottl
## Initial revision.
##
##
################################################################################


# PACKAGE DEPENDENCIES #
########################

package require Tk 8.3
package require BLT 2.4



# NAMESPACE DECLARATION #
#########################
namespace eval ::Jtag::Classify {

    # make all public procedures declared in this namespace available
    namespace export {[a-z]*}

    # Import all the data from ::Jtag::Config into this namespace
    namespace import ::Jtag::Config::*

    # NAMESPACE VARIABLES #
    #######################

    # Lists of bucket button paths, one for the left and one for the right.
    variable lBuckets
    variable rBuckets

    # options to apply to both the left and right frame created
    variable f_attribs {-relief groove -borderwidth 3}

    # options to apply to all buttons created
    variable b_attribs {-relief groove -overrelief raised -borderwidth 3}

    # the current selection rectangle
    variable sel
    set sel(parent) {}
    set sel(tkn_label) {}
    set sel(id) {}
    set sel(modifying) 0
    set sel(pos) {}
    set sel(x1) {}
    set sel(y1) {}
    set sel(x2) {}
    set sel(y2) {}
    set sel(start_timer) 0.
    set sel(sl_time) 0.
    set sel(cl_time) 0.

    # the proximity to an exact pixel you must be
    variable pad 3

}


# PUBLIC PROCEDURES #
#####################

# ::Jtag::Classify::create_buckets --
#
#    Using information taken from the config file, sets up two frame widgets
#    and evenly places buttons representing buckets inside them.  Also sets up
#    each bucket as a drag&drop target.
#
# Arguments:
#    wl    The left parent window path.  The left frame will be a child of
#          this, and its buttons a child of the frame.
#
#    wr    The right parent window path.  The right frame will be a child of
#          this, and its buttons a child of the frame.
# Results:
#    Returns a list containing paths to the left and right frames created upon
#    success.  Otherwise an error is returned.

proc ::Jtag::Classify::create_buckets {wl wr} {

    # link any namespace variables needed
    variable ::Jtag::Config::data
    variable lBuckets
    variable rBuckets
    variable f_attribs
    variable b_attribs

    # declare any local variables needed
    variable I
    variable Item
    variable Count
    variable Match
    variable Name

    # the paths to the left, right frames
    variable LF
    variable RF

    set Item(path) {}
    set Item(colour) {}

    debug {entering ::Jtag::Classify::create_buckets}

    # create the left and right frames
    set LF [eval frame $wl.left $f_attribs]
    set RF [eval frame $wr.right $f_attribs]

    # go through each of the configured classes, creating a button
    # and packing it to its frame.  Also add a drag&drop receiver for each
    # button
    set Count 1
    foreach I [lsort -dictionary [array names data -regexp {(.*)(,)(colour)}]] {
        set Item(colour) $data($I)
        regexp (.*)(,)(colour) $I Match Name
        if {$Count % 2} {
            # create a button for the left frame
            set Item(path) $LF.$Name
            if { [catch {lappend lBuckets [eval button $Item(path) \
                    -activebackground $Item(colour) -foreground $Item(colour) \
                    -text $Name $b_attribs ]} lBuckets] } {
                error "Bad colour specified in config file"
            }
        } else {
            # create a button for the right frame
            set Item(path) $RF.$Name
            if { [catch {lappend rBuckets [eval button $Item(path) \
                    -activebackground $Item(colour) -foreground $Item(colour) \
                    -text $Name $b_attribs ]} rBuckets] } {
               error "Bad colour specified in config file"
            }
        }
        # register the button as a drag&drop receiver
        ::blt::drag&drop target $Item(path) handler sel \
                           {::Jtag::Classify::AddToBucket %v %W}
        set Count [expr $Count + 1]
    }

    if {[info exists lBuckets]} {
        eval pack $lBuckets -side top -fill both -expand 1
    }
    if {[info exists rBuckets]} {
        eval pack $rBuckets -side top -fill both -expand 1
    }

    # return a list containing the left and right frame
    return [list $LF $RF]

}


# ::Jtag::Classify::bind_selection --
#
#    This procedure binds the selection mechanisms to the widget passed.
#
# Arguments:
#    w    The widget to bind selection to.  Usually this will be a canvas or
#         some other widget that the user can draw on.
#
# Results:
#    Associates appropriate left mouse button actions with helper methods
#    to draw selections.

proc ::Jtag::Classify::bind_selection {w} {

    # link any namespace variables needed
    variable sel

    # declare any local variables needed
    variable Token

    debug {entering ::Jtag::Classify::bind_selection}

    # bind left mouse button selections on the widget passed to the helper 
    # methods defined below
    set sel(parent) $w

    bind $sel(parent) <ButtonPress-1> {::Jtag::Classify::PressDecide  %W %x %y}
    bind $sel(parent) <B1-Motion>   {::Jtag::Classify::B1MotionDecide %W %x %y}
    bind $sel(parent) <Motion>       {::Jtag::Classify::MotionDecide  %W %x %y}
    bind $sel(parent) <ButtonRelease-1> {::Jtag::Classify::RelDecide  %W %x %y}

    # register the window passed as a drag & drop source (but don't bind any
    # buttons to it yet -- hence the 0)
    ::blt::drag&drop source $w -button 0 -packagecmd \
                 {::Jtag::Classify::PackageSel %W %t}
    ::blt::drag&drop source $w handler sel

    # create the token and its label, which will appear when we drag things
    set Token [::blt::drag&drop token $w]
    set sel(tkn_label) [label $Token.label]
    pack $sel(tkn_label)

}


# ::Jtag::Classify::unbind_selection --
#
#    This procedure removes any and all selection bindings from the widget
#    stored in $sel(parent) (the canvas widget)
#
# Arguments:
#
# Results:
#    Removes all click and drag event bindings from the canvas, unregisters the
#    drag&drop sources and token.

proc ::Jtag::Classify::unbind_selection {} {

    # link any namespace variables needed
    variable sel

    # declare any local variables needed

    debug {entering ::Jtag::Classify::unbind_selection}

    if {$sel(parent) == ""} {
        # no selection have been bound yet
        debug {nothing to un-bind}
        return
    }

    bind $sel(parent) <ButtonPress-1>   {}
    bind $sel(parent) <B1-Motion>       {}
    bind $sel(parent) <Motion>          {}
    bind $sel(parent) <ButtonRelease-1> {}

    destroy $sel(tkn_label)

}


# ::Jtag::Classify::add --
#
#   This procedure adds the data passed to create a new entry in the data
#   array, creating and displaying a new selection on the canvas if necessary.
#
# Arguments:
#    c       The canvas upon which to add the selection.
#    class   The name of the class to which the selection is being added
#    x1      The actual image resolution normalized left edge selection pixel
#    y1      The actual image resolution normalized top edge selection pixel
#    x2      The actual image resolution normalized right edge selection pixel
#    y2      The actual image resolution normalized bottom edge selection pixel
#    mode    The selection mode used (crop or simple)
#    id      (optional) The full path to the selection rectangle if one has
#            already been created.  Specify "" to create a new one
#    sl_time (optional) The total time in seconds to create the rectangle
#    cl_time (optional) The total time in seconds to drag the selection to a
#            classification bucket
#    attmpts (optional) The number of times the selection has been
#            classified/reclassified
#
# Results:
#    Adds the data passed to the 'data' array, creating a new rectangle
#    selection if neccessary.  

proc ::Jtag::Classify::add {c class x1 y1 x2 y2 mode {id ""} {sl_time ""} \
                            {cl_time ""} {attmpts ""}} {

    # link any namespace variables needed
    variable ::Jtag::Config::data
    variable ::Jtag::Image::img

    # declare any local variables needed

    debug {entering ::Jtag::Classify::add}

    # create rectangle if neccessary
    if {$id == ""} {
        # since co-ords are in actual image size, we must multiply them by 
        # the current zoom factor to create corect sized rectangle
        set id [$c create rectangle [expr $img(zoom) * $x1] \
                           [expr $img(zoom) * $y1] [expr $img(zoom) * $x2] \
                           [expr $img(zoom) * $y2]]
        set sl_time 0.
        set cl_time 0.
        set attmpts 1
        # hack to create transparent rectangles
        ::blt::bitmap define null1 { { 1 1 } { 0x0 } }
        $c itemconfigure $id -width 2 -activewidth 4 -fill black \
           -stipple null1 -outline $data($class,colour)
    }

    if {$sl_time == ""} {
        set sl_time 0.
    }
    if {$cl_time == ""} {
        set cl_time 0.
    }
    if {$attmpts == ""} {
        set attmpts 1
    }

    # update the data array
    set data($class,$data($class,num_sels)) [list $id $x1 $y1 $x2 $y2 \
              $mode $sl_time $cl_time $attmpts]
    incr data($class,num_sels)

}


# ::Jtag::Classify::remove --
#
#    This procedure removes the entry passed from the 'data' array, shifting
#    up any other items, and decrementing the number of selections.
#
# Arguments:
#    sel_ref  The 'data' item to be removed.  Note that it must be a string of
#             the form: "<class>,<num>"  where <class> is the name of a valid 
#             class and <num> is a valid numerical number corresponding 
#             to the selection number.  This is the same format as is returned 
#             by ::Jtag::Classify::get_selection.
#
# Results:
#    Updates the 'data' array appropriately to remove the element reference
#    passed.  Note that it is the caller's responsibility to destroy the
#    associated rectange from the canvas.

proc ::Jtag::Classify::remove {sel_ref} {

    # link any namespace variables needed
    variable ::Jtag::Config::data

    # declare any local variables needed
    variable CommaPos
    variable SelBase
    variable SelNum

    debug {entering ::Jtag::Classify::remove}

    if {[array names data -exact $sel_ref] == ""} {
        debug "trying to remove: $sel_ref a non-existent data item"
        return
    }

    # remove the entry from 'data' and decrement the number of selection
    # for the associated class.  Note that the original may not be 
    # the last element, so check this and swap the last element for the 
    # now empty space.
    set CommaPos [string last "," $sel_ref]
    set SelBase [string range $sel_ref 0 $CommaPos]
    set SelNum [string range $sel_ref [expr $CommaPos + 1] \
                             [string length $sel_ref]]
    set LastNum [expr $data(${SelBase}num_sels) - 1]
    debug "Removing $sel_ref entry: $data($sel_ref)"
    if {$SelNum != $LastNum} {
        # pop the last element contents to fill the hole in the array
        array set data [list $sel_ref $data(${SelBase}${LastNum})]
        array unset data ${SelBase}${LastNum}
    } else {
        array unset data $sel_ref
    }

    incr data(${SelBase}num_sels) -1

}


# ::Jtag::Classify::get_selection --
#
#    Searches through all selection data in the 'data' array to see if there
#    is a match for the rectangle id passed.
#
# Arguments:
#    id    the unique id returned during the creation of a rectangle that
#          exists on the canvas.
#
# Results:
#    If a match was found for id in the data array, a string is returned
#    giving the element containing its data.  Otherwise, the empty string is
#    returned.  Note that the string returned is a bit of a hack in that
#    Tcl/Tk has no real support for multi-dimensional arrays.  Since our data
#    array is of this form, the string returned is of the form "<class>,<num>"
#    where <class> is replaced with a valid class name, and <num> is
#    replaced with the appropriate selection number matching the rectangle
#    given by the id passed.  You can use the string returned to get to the
#    data as follows: data([get_selection $id]) for example.

proc ::Jtag::Classify::get_selection id {

    # link any namespace variables
    variable ::Jtag::Config::data

    # declare any local variables needed
    variable I

    debug "entering ::Jtag::Classify::get_selection"

    # iterate through each of the selections in the data array one-by-one
    foreach I [array names data -regexp {(.*)(,)([0-9])+}] {
        if {$id == [lindex $data($I) 0]} {
            # match found
            return $I
        }
    }

    return ""
}


# ::Jtag::Classify::snap_selection --
#
#    Given a selection id, this procedure tightens the bounding rectangle
#    represented by this id using ink thresholds as appropriate
#
# Arguments:
#    id    The unique id returned during the creation of a rectangle that
#          exists on the canvas
#
# Results:
#    The image is shrunk down on all 4 sides (if mode is crop) or top and
#    bottom side (if mode is simple) until each side of the bounding box
#    contains a certain threshold of non-background pixels

proc ::Jtag::Classify::snap_selection id {

    # link any namespace variables
    variable ::Jtag::Config::cnfg
    variable ::Jtag::Image::can
    variable ::Jtag::Image::img
    variable ::Jtag::Config::data

    # declare any local variables needed
    variable Threshold .02 ;# % of pixels on a side that must be non-background
    variable Background {#ffffff}  ;# background colour (RGB format)
    variable Simple {simple}
    variable Data
    variable NumPixels
    variable InkCount
    variable I
    variable J

    # current rectangle bounds
    variable X1
    variable Y1
    variable X2
    variable Y2

    # set to 1 when we've met the bound for that side
    variable X1Done 0
    variable Y1Done 0
    variable X2Done 0
    variable Y2Done 0


    debug {entering ::Jtag::Classify::snap_selection}

    # ensure that an image exists to snap to
    if {! [::Jtag::Image::exists]} {
        debug "no image to snap selection to"
        return
    }

    # ensure that the id refers to a created rectangle
    set Y2 [$can(path) coords $id]
    if {[llength $Y2] != 4} {
        debug "no rectangle belonging to id $id passed"
        return
    }

    # change the cursor since this may take a bit of time (depending on sel
    # size and error), and prevent other operations 
    ::blt::busy hold .

    set X1 [expr round([lindex $Y2 0] / $img(zoom))]
    set Y1 [expr round([lindex $Y2 1] / $img(zoom))]
    set X2 [expr round([lindex $Y2 2] / $img(zoom))]
    set Y2 [expr round([lindex $Y2 3] / $img(zoom))]

    # if we are in simple mode, explicitly set X1 and X2 to be the width of
    # the image (rounding may make it larger than the image, causing problems 
    # below)
    if {$cnfg(mode) == $Simple} {
        set X1 0
        set X2 [lindex [::Jtag::Image::get_actual_dimensions] 0]
    }

    # loop over all sides, moving them in one pixel at a time until done
    while {! ($X1Done && $Y1Done && $X2Done && $Y2Done)} {

        if {$X1 >= $X2 || $Y1 >= $Y2} {
            debug "no ink found in selection"
            # now allow people to interact and handle events again
            ::blt::busy release .
            return
        }

        if {! $X1Done} {
            set Data [$img(orig_img) data -grayscale \
                                          -from $X1 $Y1 [expr $X1+1] $Y2]
            set NumPixels [llength $Data]
            set InkCount 0
            foreach I $Data {
                if {$I != $Background} {
                        incr InkCount
                }
            }
            if {$InkCount >= [expr $NumPixels * $Threshold]} {
                set X1Done 1
            } else {
                incr X1
            }
        } ;# end X1 checks

        if {! $Y1Done} {
            set Data [$img(orig_img) data -grayscale \
                                          -from $X1 $Y1 $X2 [expr $Y1+1]]
            set NumPixels [llength [lindex $Data 0]]
            set InkCount 0
            foreach I [lindex $Data 0] {
                if {$I != $Background} {
                        incr InkCount
                }
            }
            if {$InkCount >= [expr $NumPixels * $Threshold]} {
                set Y1Done 1
            } else {
                incr Y1
            }
        } ;# end Y1 checks

        if {! $X2Done} {
            set Data [$img(orig_img) data -grayscale \
                                          -from [expr $X2 -1] $Y1 $X2 $Y2]
            set NumPixels [llength $Data]
            set InkCount 0
            foreach I $Data {
                if {[lindex $I 0] != $Background} {
                        incr InkCount
                }
            }
            if {$InkCount >= [expr $NumPixels * $Threshold]} {
                set X2Done 1
            } else {
                incr X2 -1
            }
        } ;# end X2 checks

        if {! $Y2Done} {
            set Data [$img(orig_img) data -grayscale \
                                          -from $X1 [expr $Y2 -1] $X2 $Y2]
            set NumPixels [llength [lindex $Data 0]]
            set InkCount 0
            foreach I [lindex $Data 0] {
                if {$I != $Background} {
                        incr InkCount
                }
            }
            if {$InkCount >= [expr $NumPixels * $Threshold]} {
                set Y2Done 1
            } else {
                incr Y2 -1
            }
        } ;# end Y2 checks

    } ;# end while

    if {$cnfg(mode) == $Simple} {
        # explicitly set the X widths back to the image width 
        set X1 0
        set X2 [lindex [::Jtag::Image::get_actual_dimensions] 0]
    }

    # now set the rectangle co-ords to the new value
    $can(path) coords $id [expr $X1 * $img(zoom)] [expr $Y1 * $img(zoom)] \
                          [expr $X2 * $img(zoom)] [expr $Y2 * $img(zoom)]

    # now allow people to interact and handle events again
    ::blt::busy release .

}



# PRIVATE PROCEDURES #
######################

# ::Jtag::Classify::PressDecide --
#
#    Determines course of action to take when the user presses the left mouse
#    button inside the canvas
#
# Arguments:
#    c    The canvas upon which we have clicked
#    x    The current x co-ord of the mouse (relative to visible window)
#    y    The current y co-ord of the mouse (relative to visible window)
#    
# Results:
#    Appropriate helper is called depending on the mode, and where we clicked

proc ::Jtag::Classify::PressDecide {c x y} {

    # link any namespace variables needed
    variable ::Jtag::Config::cnfg
    variable sel

    # declare any local variables needed
    variable R
    variable Coords

    # check to see if we are clicking on/inside a rectangle
    set R [$c find withtag current]
    set Coords [$c coords $R]

    if {[llength $Coords] != 4} {
        # outside a rectangle, start a selection in the appropriate mode,
        # first converting x,y into canvas co-ords
        ::Jtag::Classify::SelStart $c [$c canvasx $x] [$c canvasy $y] \
                                   $cnfg(mode)
    } else {
        # check if we clicked on the border (and thus allow resizing to start)
        set Pos [eval ::Jtag::Classify::DeterminePos [join $Coords] \
                                        [$c canvasx $x] [$c canvasy $y]]
        if {$Pos != ""} {
            ::Jtag::Classify::ResizeStart $c $R $Pos
        } else {
            # allow the canvas to perform drag & drop operation
            ::blt::drag&drop source $c -button 1
            
            # start the classification timer
            set sel(cl_time) 0.
            set sel(start_timer) [clock clicks -milliseconds]
        }
    }
}


# ::Jtag::Classify::B1MotionDecide --
#
#    Determines course of action to take when the user has the left mouse
#    button depressed and drags the mouse over the canvas
#
# Arguments:
#    c    The canvas upon which we have clicked
#    x    The current x co-ord of the mouse (relative to visible window)
#    y    The current y co-ord of the mouse (relative to visible window)
#    
# Results:
#    Appropriate helper is called depending on the mode, and if we are in the
#    middle of a drag & drop

proc ::Jtag::Classify::B1MotionDecide {c x y} {

    # link any namespace variables needed
    variable ::Jtag::Config::cnfg

    # declare any local variables needed

    # short circuit the call if we are in the middle of a drag & drop op
    if {[::blt::drag&drop active]} {
        return
    }

    ::Jtag::Classify::SelExpand $c [$c canvasx $x] [$c canvasy $y] $cnfg(mode)

}


# ::Jtag::Classify::MotionDecide --
#
#    Determines the course of action to take when the user moves the mouse
#    over the canvas.
#
# Arguments:
#    c    The canvas upon which we have clicked
#    x    The current x co-ord of the mouse (relative to visible window)
#    y    The current y co-ord of the mouse (relative to visible window)
#
# Results:
#    If we are over the edge of a selection window the appropriate cursor
#    image is displayed, to ease with resizing

proc ::Jtag::Classify::MotionDecide {c x y} {
    
    # link any namespace variables needed
    variable pad
    
    # declare any local variables needed
    variable R
    variable Coords
    variable X1
    variable Y1
    variable X2
    variable Y2

    set R [$c find withtag current]
    set Coords [$c coords $R]

    if {[llength $Coords] == 4} {
        #inside a rectangle
        set X1 [lindex $Coords 0]
        set Y1 [lindex $Coords 1]
        set X2 [lindex $Coords 2]
        set Y2 [lindex $Coords 3]
        $c configure -cursor [::Jtag::Classify::DeterminePos $X1 $Y1 $X2 $Y2 \
                              [$c canvasx $x] [$c canvasy $y]]
    } else {
        $c configure -cursor left_ptr
    }
}



# ::Jtag::Classify::RelDecide --
#
#    Determines course of action to take when the user releases the left mouse
#    button inside the canvas
#
# Arguments:
#    c    The canvas upon which we have clicked
#    x    The current x co-ord of the mouse (relative to visible window)
#    y    The current y co-ord of the mouse (relative to visible window)
#    
# Results:
#    Appropriate helper is called depending on the mode, and where we released

proc ::Jtag::Classify::RelDecide {c x y} {

    # link any namespace variables needed
    variable sel
    variable ::Jtag::Config::cnfg

    # declare any local variables needed

    if {$sel(modifying)} {
        ::Jtag::Classify::SelEnd $c [$c canvasx $x] [$c canvasy $y] $cnfg(mode)
        return
    }

    # since we have released a drag&drop, ensure that we unbind it
    ::blt::drag&drop source $c -button 0

}


# ::Jtag::Classify::SelStart --
#
#    This procedure starts creation of a selection rectangle in the mode
#    passed.
#
# Arguments:
#    c    The canvas upon which we are making the selection
#    x    The x co-ord of the mouse at the start of the selection
#    y    The y co-ord of the mouse at the start of the selection
#    m    The mode (must be a string containing either "crop" or "simple"
#
# Results:
#    Begins the creation of the rectangle that will expand as the user drags
#    the mouse.

proc ::Jtag::Classify::SelStart {c x y m} {

    # link any namespace variables needed
    variable sel

    # declare any local variables needed

    # create a rectangle at the origin:
    set sel(y1) $y
    set sel(y2) $y
    if {$m == "crop"} {
        set sel(x1) $x
        set sel(x2) $x
    } elseif {$m == "simple"} {
        set sel(x1) 0.
        set sel(x2) [lindex [::Jtag::Image::get_current_dimensions] 0]
    } else {
        debug "Unknown selection mode passed. Ignoring creation of rectangle"
        return
    }

    set sel(id) [$c create rectangle $sel(x1) $sel(y1) $sel(x2) $sel(y2)]

    # set flag to declare that we are modifying our selection rectangle
    set sel(modifying) 1
    set sel(pos) ""
    # record current time (in seconds) to determine selection time
    set sel(start_timer) [clock clicks -milliseconds]
    set sel(sl_time) 0.
}


# ::Jtag::Classify::ResizeStart --
#
#    This procedure starts to resize a selection rectangle.
#
# Arguments:
#    c    The canvas upon which we are making the resize
#    r    The rectangle we are resizing
#    pos  The corner/side to resize (anchor all other co-ords)
#
# Results:
#    Begins the modification of the rectangle that will expand/contract anchored
#    about (x1,y1) as the user drags the mouse.

proc ::Jtag::Classify::ResizeStart {c r pos} {

    # link any namespace variables needed
    variable sel

    # declare any local variables needed
    variable Coords [$c coords $r]

    # create a rectangle at the origin:
    set sel(id) $r
    # remember origin:
    set sel(x1) [lindex $Coords 0]
    set sel(y1) [lindex $Coords 1]
    set sel(x2) [lindex $Coords 2]
    set sel(y2) [lindex $Coords 3]
    set sel(pos) $pos
    # set flag to declare that we are modifying our selection rectangle
    set sel(modifying) 1
    # record current time (in seconds) to determine selection time
    set sel(start_timer) [clock clicks -milliseconds]
}


# ::Jtag::Classify::SelExpand --
#
#    Expands an existing selection rectangle appropriately depending on the
#    mode passed.
#
# Arguments:
#    c    The canvas upon which we are making the selection
#    x    The x co-ord of the mouse currently
#    y    The y co-ord of the mouse currently
#    m    The mode (must be a string containing either "crop" or "simple"
# 
# Results:
#    The rectangle size is increased to that of the current mouse position in
#    height (and in width if mode is "crop")

proc ::Jtag::Classify::SelExpand {c x y m} {

    # link any namespace variables needed
    variable sel

    # declare any local variables needed

    # set the opposite corner of the selection rectangle
    # to the current cursor location:
    if {$sel(pos) == ""} {
        # not a resize
        if {$m == "crop"} {
            set sel(x2) $x
            set sel(y2) $y
        } elseif {$m == "simple"} {
            set sel(y2) $y
        } else {
            debug "Mode passed is invalid.  Ignoring expand."
            return
        }
    } elseif {$sel(pos) == "top_left_corner"} {
        set sel(x1) $x
        set sel(y1) $y
    } elseif {$sel(pos) == "top_side"} {
        set sel(y1) $y
    } elseif {$sel(pos) == "top_right_corner"} {
        set sel(x2) $x
        set sel(y1) $y
    } elseif {$sel(pos) == "right_side"} {
        set sel(x2) $x
    } elseif {$sel(pos) == "bottom_right_corner"} {
        set sel(x2) $x
        set sel(y2) $y
    } elseif {$sel(pos) == "bottom_side"} {
        set sel(y2) $y
    } elseif {$sel(pos) == "bottom_left_corner"} {
        set sel(x1) $x
        set sel(y2) $y
    } elseif {$sel(pos) == "left_side"} {
        set sel(x1) $x
    }

    $c coords $sel(id) $sel(x1) $sel(y1) $sel(x2) $sel(y2)
}


# ::Jtag::Classify::SelEnd --
#
#    Finishes creation of an existing selection rectangle.
#
# Arguments:
#    c    The canvas upon which we are making the selection
#    x    The x co-ord of the mouse currently
#    y    The y co-ord of the mouse currently
#    m    The mode (must be a string containing either "crop" or "simple")
#  
# Results:
#   Completes the rectangle (drawn in black)

proc ::Jtag::Classify::SelEnd {c x y m} {

    #link any namespace variables
    variable sel
    variable ::Jtag::Config::data

    # declare any local variables
    # the amount of pixels used for thresholds during selection creation
    variable Min 6
    variable ResizeRef
    variable Class
    variable Coords

    # stop the clock timer and adjust to seconds
    set sel(sl_time) [expr ($sel(sl_time) + \
                     [expr [clock click -milliseconds] - $sel(start_timer)]) \
                      / 1000.]

    # first ensure that the selection area is larger than a minimum threshold
    # only check in the y direction since we may using "simple" mode
    if {(abs ($sel(y2) - $sel(y1))) <= $Min} {
       # cancel the selection (area selected too small)
       $c delete $sel(id)
       set sel(modifying) 0
       return
    }

    # adjust selection rectangle to the current position:
    SelExpand $c $x $y $m

    # snap our selection
    ::Jtag::Classify::snap_selection $sel(id)

    # update our sel(x1) ... sel(y2) co-ords to the now snapped co-ords
    set Coords [$c coords $sel(id)]
    set sel(x1) [lindex $Coords 0]
    set sel(y1) [lindex $Coords 1]
    set sel(x2) [lindex $Coords 2]
    set sel(y2) [lindex $Coords 3]

    # check if we have just finished resizing a classified rectangle
    set ResizeRef [::Jtag::Classify::get_selection $sel(id)]

    if {$ResizeRef == ""} {
        # create a new selection rectangle
        # hack to create transparent rectangles
        ::blt::bitmap define null1 { { 1 1 } { 0x0 } }

        # set options (ex outline colour etc.)
        $c itemconfigure $sel(id) -width 2 -activewidth 4 -fill black \
                                  -stipple null1
    } else {
       # update the data array to give the new dimensions of the rectangle
       set Class [string range $ResizeRef 0 [expr \
                                    [string last "," $ResizeRef] -1]]
       ::Jtag::Classify::AddToClass $c $Class $data($Class,colour)
    }

    # set flag to end the modification of the selection rectangle
    set sel(modifying) 0

} 


# ::Jtag::Classify::PackageSel --
#
#    Sets up the data that will be sent to a drag&drop target after a
#    selection has been completed
#
# Arguments:
#    c    Valid canvas widget, that has been setup as a drag&drop source
#    t    The token that will house the data.
#
# Results:
#    co-ords of selection rectangle as well as its id are stored in sel, and
#    the co-ords are also written in the token.

proc ::Jtag::Classify::PackageSel {c t} {
    
    # link any namespace variables
    variable sel

    # declare any local variables
    variable Coords
    variable TokenText {selection}

    # setup the data to be sent to the target
    set Coords [::blt::drag&drop location]
    set sel(id) [$c find withtag current]
    set Coords [$c coords $sel(id)]
    set sel(x1) [lindex $Coords 0]
    set sel(y1) [lindex $Coords 1]
    set sel(x2) [lindex $Coords 2]
    set sel(y2) [lindex $Coords 3]

    # display the rectangle co-ords in the token
    $t.label configure -text $TokenText

    return $c

}


# ::Jtag::Classify::AddToBucket --
#
#    Classifies the selection made as the type of bucket passed
#
# Arguments:
#    c    Canvas widget upon which we made our selection (drag&drop source)
#    b    Bucket button widget that will determine the type of classification
#
# Results:
#   The rectangle defined currently by sel(id) is added to the list of 
#   classifications currently made for bucket type b.  The rectangle is 
#   updated to exhibit the same colour as b, and it no longer becomes an active 
#   drag&drop source (must be reactivated by clicking on it)

proc ::Jtag::Classify::AddToBucket {c b} {

    # link any namespace variables

    # declare any local variables
    variable Class [string range $b [expr 1 + [string last "." $b]] \
                   [string length $b]]

    # let the AddToClass helper do all the work
    ::Jtag::Classify::AddToClass $c $Class [$b cget -foreground]

}


# ::Jtag::Classify::AddToClass --
#
#    Classifies the selection made as the type of class passed
#
# Arguments:
#    c        Canvas widget upon which we made our selection (drag&drop source)
#    class    A valid class name (same as that which appears in the data array)
#    colour   The colour to make the rectangle
#
# Results:
#   The rectangle defined currently by sel(id) is added to the list of 
#   classifications currently made for class class.  The rectangle is 
#   updated to exhibit the colour passed, and it no longer becomes an active 
#   drag&drop source (must be reactivated by clicking on it)
proc ::Jtag::Classify::AddToClass {c class colour} {

    # link any namespace variables
    variable sel
    variable ::Jtag::Config::data
    variable ::Jtag::Config::cnfg
    variable ::Jtag::Image::img

    # declare any local variables
    variable ReclassRef
    variable ReclassBase
    variable CommaPos
    variable ReclassNum
    variable LastNum
    variable SelTime 0.
    variable ClsTime 0.
    variable Attmpt 0

    # stop the classification timer, and adjust to seconds
    set sel(cl_time) [expr ($sel(cl_time) + [expr [clock clicks -milliseconds] \
                      - $sel(start_timer)]) / 1000.]

    # ensure that the button belongs to a valid class
    if {$class == ""} {
        debug {SERIOUS ERROR!}
        debug {Unable to extract class name from button.  Exiting}
        exit -1
    }

    # check if we are making a new classification or a reclassification

    set  ReclassRef [::Jtag::Classify::get_selection $sel(id)]
    if {$ReclassRef != ""} {
        # reclassification attempt
        set SelTime [lindex $data($ReclassRef) 6]
        set ClsTime [lindex $data($ReclassRef) 7]
        set Attmpt  [lindex $data($ReclassRef) 8]

        # remove the original's 'data' entry
        ::Jtag::Classify::remove $ReclassRef
    }

    # update metrics
    set SelTime [expr $SelTime + $sel(sl_time)]
    set ClsTime [expr $ClsTime + $sel(cl_time)]
    set Attmpt [expr $Attmpt + 1]

    # highlight the selection in the classes colour
    $c itemconfigure $sel(id) -outline $colour

    # now update the data structure to reflect our new classification
    ::Jtag::Classify::add $c $class [expr $sel(x1) / $img(zoom)] \
               [expr $sel(y1) / $img(zoom)] [expr $sel(x2) / $img(zoom)] \
               [expr $sel(y2) / $img(zoom)] $cnfg(mode) $sel(id) \
               $SelTime $ClsTime $Attmpt

    # uncomment the following line to dump the data array contents (for
    # debugging purposes)
    #puts [parray data]

}



# ::Jtag::Classify::DeterminePos --
#
#    Helper that determines what corner/side the x and y co-ords passed are
#    closest to given that they lie within the rectangle passed.
#
# Arguments:
#    rx1    The left rectangle co-ordinate
#    ry1    The top rectangle co-ordinate
#    rx2    The right rectangle co-ordinate
#    ry2    The bottom rectangle co-ordinate
#    x      The x position to determine (must be canvas relative)
#    y      The y position to determine (must be canvas relative)
#
# Results:
#    Returns one of: top_left_corner, top_side, top_right_corner, right_side,
#    bottom_right_corner, bottom_side, bottom_left_corner, left_side, ""
#    depending on what best fits the x and y co-ords passed.  If x or y lies
#    outside of the rectangle "" is returned.  Makes use of the namespace
#    variable pad to allow for proximity matches

proc ::Jtag::Classify::DeterminePos {rx1 ry1 rx2 ry2 x y} {

    # link any namespace variables
    variable pad

    # declare any local variables

    if {($rx1 + $pad >= $x && $rx1 - $pad <= $x) &&
        ($ry1 + $pad >= $y && $ry1 - $pad <= $y)} {
        # upper-left corner
        return top_left_corner
    } elseif {($rx1 + $pad >= $x && $rx1 - $pad <= $x) &&
              ($ry2 + $pad >= $y && $ry2 - $pad <= $y)} {
        # bottom-left corner
        return bottom_left_corner
    } elseif {($rx2 + $pad >= $x && $rx2 - $pad <= $x) &&
              ($ry1 + $pad >= $y && $ry1 - $pad <= $y)} {
        # upper-right corner
        return top_right_corner
    } elseif {($rx2 + $pad >= $x && $rx2 - $pad <= $x) &&
              ($ry2 + $pad >= $y && $ry2 - $pad <= $y)} {
        # bottom-right corner
        return bottom_right_corner
    } elseif {($rx1 + $pad >= $x && $rx1 - $pad <= $x)} {
        # left side
        return left_side
    } elseif {($ry1 + $pad >= $y && $ry1 - $pad <= $y)} {
        # top side
        return top_side
    } elseif {($rx2 + $pad >= $x && $rx2 - $pad <= $x)} {
        # right side
        return right_side
    } elseif {($ry2 + $pad >= $y && $ry2 - $pad <= $y)} {
        # bottom side
        return bottom_side
    } else {
        # either x and y are in the middle of the selection or at least one of
        # x or y lies outside of the selection.
        return ""
    }
}
