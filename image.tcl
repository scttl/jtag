################################################################################
##
## FILE: image.tcl
##
## DESCRIPTION: Responsible for handling all things related to journal
##              page images and the canvas upon which they are displayed.
##
## CVS: $Header: /p/learning/cvs/projects/jtag/image.tcl,v 1.1 2003-07-07 15:44:48 scottl Exp $
##
## REVISION HISTORY:
## $Log: image.tcl,v $
## Revision 1.1  2003-07-07 15:44:48  scottl
## Initial revision.
##
##
################################################################################


# PACKAGE DEPENDENCIES #
########################

package require Tk 8.3
package require Img 1.3
package require BLT 2.4


# NAMESPACE DECLARATION #
#########################
namespace eval ::Jtag::Image {

    # make all public procedures declared in this namespace available
    namespace export {[a-z]*}


    # NAMESPACE VARIABLES #
    #######################

    variable Can
    variable Img
    variable Scroll
    
    # the canvas upon which the image sits
    set Can(created) 0
    set Can(path) {}
    set Can(attribs) {-borderwidth 3 -relief groove}
    set Can(img_tag) {}

    # the scroll region for the canvas
    set Scroll(left) 0
    set Scroll(top) 0
    set Scroll(right) 0
    set Scroll(bottom) 0

    # the x and y path
    set Scroll(xpath) {}
    set Scroll(ypath) {}

    # Have scrollbars been created yet?
    set Scroll(created) 0

    # has a valid image been created yet?
    set Img(created) 0

    # the name of the file
    set Img(file_name) {}

    # its original and current resolution (in pixels)
    set Img(actual_height) 0
    set Img(actual_width) 0
    set Img(height) 0
    set Img(width) 0

    # its format (tiff, bmp etc.)
    set Img(file_format) {}

    # original image reference (used when resizing)
    set Img(orig_img) {}

    # current image reference
    set Img(img) {}

    # the current zoom factor
    set Img(zoom) 1.

}


# PUBLIC PROCEDURES #
#####################

# ::Jtag::Image::create_image --
#
#    Attempts to open, validate and create the image given by the filename
#    argument passed.
#
# Arguments:
#    file_name    The name of the file to open
#
# Results:
#    Upon any failure to open, validate, or create the image an error is
#    thrown back to the caller

proc ::Jtag::Image::create_image {file_name} {

    # link any namespace variables
    variable Img

    # declare any local variables needed

    debug {entering ::Jtag::Image::create_image}

    # attempt to create an image out of the file specified by $file_name
    # if the file is invalid (not found, not an image etc.) an error is
    # returned to the caller.

    catch {image delete $Img(orig_img)}

    set Img(orig_img) [image create photo -file $file_name]

    # open, validation and creation all succeeded, set all attribs
    set Img(file_name) $file_name
    set Img(actual_height) [image height $Img(orig_img)]
    set Img(actual_width) [image width $Img(orig_img)]
    set Img(height) $Img(actual_height)
    set Img(width) $Img(actual_width)
    set Img(file_format) [$Img(orig_img) cget -format]
    set Img(zoom) 1.0
    set Img(created) 1

}


# ::Jtag::Image::exists --
#
#    Determines whether or not a valid image has been set yet.
#
# Arguments:
#
# Results:
#    Returns 1 if an image has been set and 0 otherwise

proc ::Jtag::Image::exists {} {

    # link any namespace variables
    variable Img

    # declare any local variables needed

    debug {entering ::Jtag::Image::exists}

    return $Img(created)

}


# ::Jtag::Image::get_current_dimensions --
#
#    Returns the current width and height of the image, if one exists.  Note
#    that these dimensions change as the image is resized (zoom in and out),
#    for the original image dimensions see the get_actual_dimensions call.
#
# Arguments:
#
# Results:
#    Returns a two element list containing the width followed by the height of
#    the image currently (both numbers are in pixels).  If no image exists, an
#    error is thrown.

proc ::Jtag::Image::get_current_dimensions {} {

    # link any namespace variables
    variable Img

    # declare any local variables needed

    debug {entering ::Jtag::Image::get_current_dimensions}

    if {! $Img(created)} {
        error {Can't get dimensions of a non-existent image}
    }

    return [list $Img(width) $Img(height)]

}


# ::Jtag::Image::get_actual_dimensions --
#
#    Returns the real dimensions of the image, if one exists.
#
# Arguments:
#
# Results:
#    Returns a two element list containing the true image width followed by the
#    true image height (both numbers are in pixels).  If no image exists, an
#    error is thrown.

proc ::Jtag::Image::get_actual_dimensions {} {

    # link any namespace variables
    variable Img

    # declare any local variables needed

    debug {entering ::Jtag::Image::get_actual_dimensions}

    if {! $Img(created} {
        error {Can't get dimensions of a non-existent image}
    }

    return [list $Img(actual_width) $Img(actual_height)]

}


# ::Jtag::Image::create_canvas --
#
#    Creates a canvas widget and associated bindings upon which the image will
#    be displayed.
#
# Arguments:
#    w           The parent widget upon which the canvas will be created.
#    width       The width of the canvas
#    height      The height of the canvas
#    args        (optional) Any additional arguments pertaining to things like
#                scrolling etc.  See the "options" Tk manpage and the "canvas"
#                Tk manpage for what valid arguments are.  Must be a string of
#                the form: -<option_0> <value_0> ... -<option_n> <value_n>
#
# Results:
#    Upon success, the full path of the newly created canvas is returned to the
#    caller.  Otherwise, an error is returned with an appropriate error
#    message set.
#    

proc ::Jtag::Image::create_canvas {w width height {args {}}} {

    # link any namespace variables
    variable Img
    variable Can

    # declare any local variables needed
    variable Name {c}

    debug {entering ::Jtag::Image::create_canvas}

    # do some sanity checking on the height and width passed
    #@@ to do 

    # create the canvas
    set Can(path) $w.$Name
    eval canvas $Can(path) -width $width -height $height $Can(attribs) $args

    # see if there is an image to add to the canvas
    if {$Img(created)} {
        set Can(img_tag) [$Can(path) create image 0 0 -image $Img(img) \
                          -anchor nw]
    } else {
        # create a dummy image for now??@@
        set Can(img_tag) [$Can(path) create image 0 0 -image {} -anchor nw]
    }

    # make this namespace aware that a canvas has been created
    set Can(created) 1

    # return the path of the canvas to the caller
    return $Can(path)
    
}


# ::Jtag::Image::add_scrollbars --
#
#    Adds a horizontal and vertical scrollbar to the canvas that will perform
#    scrolling over the scroll region passed.
#
# Arguments:
#    region   A list containing 4 pixel location specifying the left, top,
#             right and bottom regions to scroll
#
# Results:
#    Provided that a canvas has already been created, two scrollbar widgets
#    will be added to the heirarchy at the same depth as the canvas.
#    The widget paths will be returned as elements in a list.  If no canvas 
#    widget exists or there is another problem, an error is returned.

proc ::Jtag::Image::add_scrollbars {region} {

    # link any namespace variables
    variable Can
    variable Scroll

    # declare any local variables needed
    variable PrePath

    debug {entering ::Jtag::Image::add_scrollbars}

    # first ensure that a canvas widget exists
    if {! $Can(created)} {
        error {No canvas to add scrollbars to}
    }

    # now ensure that region passed is a list of exactly 4 integer variables
    if {[llength $region] != 4} {
        error {Scrollbar region argument must be a list containing 4 integers}
    }

    set Scroll(left)   [lindex $region 0]
    set Scroll(top)    [lindex $region 1]
    set Scroll(right)  [lindex $region 2]
    set Scroll(bottom) [lindex $region 3]

    # the path to the scrollbars is the same as that to the canvas widget, 
    # minus the canvas widgets name, plus the addition of cs_x or cs_y 
    # depending on which scrollbar we are dealing with
    set PrePath [string range $Can(path) 0 [string last "." $Can(path)]]
    set Scroll(xpath) [join "$PrePath cs_x" {}]
    set Scroll(ypath) [join "$PrePath cs_y" {}]

    # update the canvas to prepare it for the scrollbars
    $Can(path) configure -xscrollcommand [list $Scroll(xpath) set] \
                         -yscrollcommand [list $Scroll(ypath) set] \
                         -confine 1 -scrollregion $region

    # create the horizontal and vertical scrollbars
    scrollbar $Scroll(xpath) -orient horizontal \
              -command [list $Can(path) xview]
    scrollbar $Scroll(ypath) -orient vertical \
              -command [list $Can(path) yview]

    set Scroll(created) 1

    # return the scrollbars created as a list
    return [list $Scroll(xpath) $Scroll(ypath)]

}


# ::Jtag::Image::resize --
#
#    Attempts to resize the image by the factor given.  If no image has yet
#    been created, an error is thrown.
#
# Arguments:
#    factor    (optional) Non-zero floating point number that specifies the
#              scaling factor.  If not given defaults to 1.0 (no scale)
#
# Results:
#    If no previous image exists, or the factor specified is 0.0, an error is 
#    thrown, otherwise sets Img(img) to contain a reference to the newly 
#    scaled image, and updates Img(height) and Img(width) to reflect 
#    the new image resolution.  actual_height and actual_width remain unchanged.

proc ::Jtag::Image::resize {{factor 1.}} {

    # link any namespace variables
    variable Can
    variable Img
    variable Scroll

    # declare any local variables needed
    variable OldZoom $Img(zoom)
    variable ShrinkZoom
    variable NextItem {}

    debug {entering ::Jtag::Image::resize}

    # Since the resize operation may be time intensive, prevent clicks and 
    # keyboard bindings with busy (from the BLT package)
    ::blt::busy hold .

    if {! $Img(created) } {
        error {Trying to resize a non-existent image}
    }

    # set the new zoom factor 
    set Img(zoom) [expr {$Img(zoom) * $factor}]

    # delete the previous image (if one exists)
    if {$Img(img) != ""} {
        if {$Can(created)} {
            # first see if we can locate an item above the image
            set NextItem [$Can(path) find above $Can(img_tag)]
            $Can(path) delete $Img(img)
        }
        image delete $Img(img)
    }

    # create the new image
    set Img(img) [image create photo -format $Img(file_format)]

    # resize and copy the original one to the new
    if {$Img(zoom) == 0.} {
        set $Img(zoom) $OldZoom
        error {Trying to resize to infinity}
    } elseif {$Img(zoom) >= 1.} {
        # zoom in to magnify image
        set ShrinkZoom [expr int($Img(zoom))]
        set Img(zoom) $ShrinkZoom
        debug "magnifying original image by a factor of $Img(zoom)"
        $Img(img) copy $Img(orig_img) -zoom $ShrinkZoom $ShrinkZoom
    } else {
        # zoom out to shrink image
        set ShrinkZoom [expr round(1./$Img(zoom))]
        set Img(zoom) [expr 1. / $ShrinkZoom]
        debug "shrinking original image by a factor of $Img(zoom)"
        $Img(img) copy $Img(orig_img) -subsample $ShrinkZoom $ShrinkZoom
    }

    # set the new image attributes
    set Img(height) [image height $Img(img)]
    set Img(width) [image width $Img(img)]
    if {$Can(created)} {
        set Can(img_tag) [$Can(path) create image 0 0 -image $Img(img) \
                          -anchor nw]
        # scale the canvas (and everything on it) to fit the new image
        # first restore the original scale
        $Can(path) scale all 0 0 [expr 1.0 / $OldZoom] [expr 1.0 / $OldZoom]
        # now rescale to the new image size
        $Can(path) scale all 0 0 $Img(zoom) $Img(zoom)
        # put the image as low on the canvas as possible
        if {$NextItem != ""} {
            $Can(path) lower $Can(img_tag) $NextItem
        }
        if {$Scroll(created)} {
            # reset the scroll region to that of the new image
            set Scroll(right) [expr $Img(width) - $Scroll(left)]
            set Scroll(bottom) [expr $Img(height) - $Scroll(top)]
            $Can(path) configure -scrollregion [list $Scroll(left) \
                       $Scroll(top) $Scroll(right) $Scroll(bottom)]
        }
    }

    # allow clicks and binding events again
    ::blt::busy release .
}



# PRIVATE PROCEDURES #
######################
