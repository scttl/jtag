################################################################################
##
## FILE: classify.tcl
##
## DESCRIPTION: Contains methods to carry out the classification process
##              (selection of text, bucket selection etc.)
##
## CVS: $Header: /p/learning/cvs/projects/jtag/classify.tcl,v 1.2 2003-07-10 19:25:12 scottl Exp $
##
## REVISION HISTORY:
## $Log: classify.tcl,v $
## Revision 1.2  2003-07-10 19:25:12  scottl
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
    set sel(id) {}
    set sel(modifying) 0
    set sel(x1) {}
    set sel(y1) {}
    set sel(x2) {}
    set sel(y2) {}
    set sel(start_timer) 0.
    set sel(sl_time) 0.
    set sel(cl_time) 0.

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

    # go through each of the configured classifiers, creating a button
    # and packing it to its frame.  Also add a drag&drop receiver for each
    # button
    set Count 1
    foreach I [array names data -regexp {(.*)(,)(colour)}] {
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
    bind $sel(parent) <B1-Motion>     {::Jtag::Classify::MotionDecide %W %x %y}
    bind $sel(parent) <ButtonRelease-1> {::Jtag::Classify::RelDecide  %W %x %y}

    # register the window passed as a drag & drop source (but don't bind any
    # buttons to it yet -- hence the 0)
    ::blt::drag&drop source $w -button 0 -packagecmd \
                 {::Jtag::Classify::PackageSel %W %t}
    ::blt::drag&drop source $w handler sel

    # create the token and its label, which will appear when we drag things
    set Token [::blt::drag&drop token $w]
    label $Token.label
    pack $Token.label

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

        # for now just do crop start
        ::Jtag::Classify::CropStart $c [$c canvasx $x] [$c canvasy $y]

    } else {
        # check if we clicked on the border (and thus allow resizing to start)
        if {[lindex $Coords 0] == $x || [lindex $Coords 1] == $y} {
            # start the resize on R, first flipping x1<->x2 and y1<->y2
            ::Jtag::Classify::ResizeStart $c $R [lindex $Coords 2] \
                                                [lindex $Coords 3] \
                                                [lindex $Coords 0] \
                                                [lindex $Coords 1]
        } elseif {[lindex $Coords 2] == $x || [lindex $Coords 3] == $y} {
            # start the resize on R (no flipping necessary)
            ::Jtag::Classify::ResizeStart $c $R [lindex $Coords 0] \
                                                [lindex $Coords 1] \
                                                [lindex $Coords 2] \
                                                [lindex $Coords 3]
        } else {
            # allow the canvas to perform drag & drop operation
            ::blt::drag&drop source $c -button 1
            
            # start the classification timer
            set sel(cl_time) 0.
            set sel(start_timer) [clock clicks -milliseconds]
        }
    }
}


# ::Jtag::Classify::MotionDecide --
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

proc ::Jtag::Classify::MotionDecide {c x y} {

    # link any namespace variables needed

    # declare any local variables needed

    # short circuit the call if we are in the middle of a drag & drop op
    if {[::blt::drag&drop active]} {
        return
    }

    # for now just do crop expand
    ::Jtag::Classify::CropExpand $c [$c canvasx $x] [$c canvasy $y]
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

    # declare any local variables needed

    if {$sel(modifying)} {
        # for now just do crop end
        ::Jtag::Classify::CropEnd $c [$c canvasx $x] [$c canvasy $y]
        return
    }

    # since we have released a drag&drop, ensure that we unbind it
    ::blt::drag&drop source $c -button 0

}


# ::Jtag::Classify::CropStart --
#
#    This procedure starts a crop mode style selection rectangle.
#
# Arguments:
#    c    The canvas upon which we are making the selection
#    x    The x co-ord of the mouse at the start of the selection
#    y    The y co-ord of the mouse at the start of the selection
#
# Results:
#    Begins the creation of the rectangle that will expand as the user drags
#    the mouse.

proc ::Jtag::Classify::CropStart {c x y} {

    # link any namespace variables needed
    variable sel

    # declare any local variables needed

    # create a rectangle at the origin:
    set sel(id) [$c create rectangle $x $y $x $y]
    # remember origin:
    set sel(x1) $x
    set sel(y1) $y
    set sel(x2) $x
    set sel(y2) $y
    # set flag to declare that we are modifying our selection rectangle
    set sel(modifying) 1
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
#    x1    The x co-ord of the anchor position (won't be resized)
#    y1    The y co-ord of the anchor position (won't be resized)
#    x2    The x co-ord of the mouse (resizing position)
#    y2    The y co-ord of the mouse (resizing position)
#
# Results:
#    Begins the modification of the rectangle that will expand/contract anchored
#    about (x1,y1) as the user drags the mouse.

proc ::Jtag::Classify::ResizeStart {c r x1 y1 x2 y2} {

    # link any namespace variables needed
    variable sel

    # declare any local variables needed

    # create a rectangle at the origin:
    set sel(id) $r
    # remember origin:
    set sel(x1) $x1
    set sel(y1) $y1
    set sel(x2) $x2
    set sel(y2) $y2
    # set flag to declare that we are modifying our selection rectangle
    set sel(modifying) 1
    # record current time (in seconds) to determine selection time
    set sel(start_timer) [clock clicks -milliseconds]
}


# ::Jtag::Classify::CropExpand --
#
#    Expands an existing crop mode style selection rectangle
#
# Arguments:
#    c    The canvas upon which we are making the selection
#    x    The x co-ord of the mouse currently
#    y    The y co-ord of the mouse currently
# 
# Results:
#    The rectangle size is increased to that of the current mouse position

proc ::Jtag::Classify::CropExpand {c x y} {

    # link any namespace variables needed
    variable sel

    # declare any local variables needed

    # set the opposite corner of the selection rectangle
    # to the current cursor location:
    set sel(x2) $x
    set sel(y2) $y
    $c coords $sel(id) $sel(x1) $sel(y1) $sel(x2) $sel(y2)
}


# ::Jtag::Classify::CropEnd --
#
#    Finishes an existing crop mode style selection rectangle 
#
# Arguments:
#    c    The canvas upon which we are making the selection
#    x    The x co-ord of the mouse currently
#    y    The y co-ord of the mouse currently
#  
# Results:
#   Completes the rectangle (drawn in black)

proc ::Jtag::Classify::CropEnd {c x y} {

    #link any namespace variables
    variable sel

    # declare any local variables
    # the amount of pixels used for thresholds during selection creation
    # (min*2 is actual number of pixels)
    variable Min 2

    # stop the clock timer and adjust to seconds
    set sel(sl_time) [expr ($sel(sl_time) + \
                     [expr [clock click -milliseconds] - $sel(start_timer)]) \
                      / 1000.]

    # first ensure that the selection area is larger than a minimum threshold
    if {$sel(x1) >= $x - $Min && $sel(x1) <= $x + $Min && \
        $sel(y1) >= $y - $Min && $sel(y1) <= $y + $Min} {
       # cancel the selection (area selected too small)
       $c delete $sel(id)
       set sel(modifying) 0
       return
    }

    # adjust selection rectangle to the current position:
    CropExpand $c $x $y

    # hack to create transparent rectangles
    ::blt::bitmap define null1 { { 1 1 } { 0x0 } }

    # set options (ex outline colour etc.)
    $c itemconfigure $sel(id) -activewidth 2 -fill black -stipple null1

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
    variable sel
    variable ::Jtag::Config::data
    variable ::Jtag::Config::cnfg
    variable ::Jtag::Image::img

    # declare any local variables
    variable Class [string range $b [expr 1+ [string last "." $b]] \
                   [string length $b]]
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

    # ensure that the button belongs to a valid classifier
    if {$Class == ""} {
        debug {SERIOUS ERROR!}
        debug {Unable to extract classifier name from button.  Exiting}
        exit -1
    }

    # check if we are making a new classification or a reclassification

    set  ReclassRef [::Jtag::Classify::CheckReclassify $sel(id)]
    if {$ReclassRef != ""} {
        # reclassification attempt
        set SelTime [lindex $data($ReclassRef) 6]
        set ClsTime [lindex $data($ReclassRef) 7]
        set Attmpt  [lindex $data($ReclassRef) 8]

        # remove the original entry and decrement the number for this type
        # note that the original may not be the last element, so check this
        # and swap the last element for the now empty space.
        set CommaPos [string last "," $ReclassRef]
        set ReclassBase [string range $ReclassRef 0 $CommaPos]
        set ReclassNum [string range $ReclassRef [expr $CommaPos + 1] \
                              [string length $ReclassRef]]
        set LastNum [expr $data(${ReclassBase}num_sels) - 1]
        if {$ReclassNum != $LastNum} {
            # pop the last element contents to fill the hole in the array
            array set data [list $ReclassRef \
                                 $data(${ReclassBase}${LastNum})]
            array unset data ${ReclassBase}${LastNum}
        } else {
            array unset data $ReclassRef
        }
        incr data(${ReclassBase}num_sels) -1
    }

    # update metrics
    set SelTime [expr $SelTime + $sel(sl_time)]
    set ClsTime [expr $ClsTime + $sel(cl_time)]
    set Attmpt [expr $Attmpt + 1]

    # now update the data structure to reflect our new classification
    set data($Class,$data($Class,num_sels)) [list $sel(id) \
              [expr $sel(x1) / $img(zoom)] [expr $sel(y1) / $img(zoom)] \
              [expr $sel(x2) / $img(zoom)] [expr $sel(y2) / $img(zoom)] \
              $cnfg(mode) $SelTime $ClsTime $Attmpt]
    set data($Class,num_sels) [expr $data($Class,num_sels) + 1]

    #puts [parray data]

    # highlight the selection in the classifiers colour
    $c itemconfigure $sel(id) -outline [$b cget -foreground]
}


# ::Jtag::Classify::CheckReclassify --
#
#    Searches through all selection data in the 'data' array to see if there
#    is a match for the rectangle id passed (and thus a reclassification is
#    occuring).
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
#    where <class> is replaced with a valid classifier name, and <num> is
#    replaced with the appropriate selection number matching the rectangle
#    given by the id passed.  You can use the string returned to get to the
#    data as follows: data([CheckReclassify $id]) for example.

proc ::Jtag::Classify::CheckReclassify id {

    # link any namespace variables
    variable ::Jtag::Config::data

    # declare any local variables needed
    variable I

    # iterate through each of the selections in the data array one-by-one
    foreach I [array names data -regexp {(.*)(,)([0-9])+}] {
        if {$id == [lindex $data($I) 0]} {
            # match found
            return $I
        }
    }

    return ""
}
