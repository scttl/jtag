################################################################################
##
## FILE: image.tcl
##
## DESCRIPTION: Responsible for handling all things related to journal
##              page images and the canvas upon which they are displayed.
##
## CVS: $Header: /p/learning/cvs/projects/jtag/image.tcl,v 1.13 2003-09-05 14:22:17 scottl Exp $
##
## REVISION HISTORY:
## $Log: image.tcl,v $
## Revision 1.13  2003-09-05 14:22:17  scottl
## Implemented auto-prediction functionality.
##
## Revision 1.12  2003/09/03 20:23:13  scottl
## bugfix to ensure that warnings etc. are not displayed (preventing an image
## from correctly being loaded).
##
## Revision 1.11  2003/08/25 17:43:39  scottl
## Added a status bar to display status messages during certain actions.
##
## Revision 1.10  2003/07/28 19:56:19  scottl
## Implemented jlog reading/writing functionality.
##
## Revision 1.9  2003/07/21 21:33:43  scottl
## Implemented multi-page handling even when loading a middle-page first.
##
## Revision 1.8  2003/07/18 17:56:36  scottl
## Implemented multiple page functionality, by checking for a particular file
## format during image creation, and creating a go_to_pg method.
##
## Revision 1.7  2003/07/16 16:46:02  scottl
## Fixed small bug to allow scaling by height when resizing.  Also implemented
## snapping of canvas size to that of the image.
##
## Revision 1.6  2003/07/15 16:41:35  scottl
## Implemented clear_canvas method to allow opening of multiple images over the
## same session.
##
## Revision 1.5  2003/07/14 14:32:54  scottl
## Once image has been created, allow classifications to occur by binding
## selections made on the canvas.
##
## Revision 1.4  2003/07/11 21:58:23  scottl
## Reordered call dependancy between canvas and image creation.  There must now
## exist a valid canvas object before we can create an image.
##
## Revision 1.3  2003/07/09 21:11:59  scottl
## Renamed exported namespace variables Img Can and Scroll to be inline with
## coding conventions for other namespace variables.
## Implemented GetFormat proc to determine the image type if possible.
##
## Revision 1.2  2003/07/07 18:51:09  scottl
## Added ability to read in .jtag data via function call.
##
## Revision 1.1  2003/07/07 15:44:48  scottl
## Initial revision.
##
##
################################################################################


# PACKAGE DEPENDENCIES #
########################

package require Tk 8.3
package require Img 1.3
package require BLT 2.4
package require cksum 1.0.1


# NAMESPACE DECLARATION #
#########################
namespace eval ::Jtag::Image {

    # make all public procedures declared in this namespace available
    namespace export {[a-z]*}


    # NAMESPACE VARIABLES #
    #######################

    variable can
    variable img
    variable scrl
    
    # the canvas upon which the image sits
    set can(created) 0
    set can(path) {}
    set can(attribs) {-borderwidth 3 -relief groove}
    set can(img_tag) {}

    # the scroll region for the canvas
    set scrl(left) 0
    set scrl(top) 0
    set scrl(right) 0
    set scrl(bottom) 0

    # the x and y path
    set scrl(xpath) {}
    set scrl(ypath) {}

    # Have scrollbars been created yet?
    set scrl(created) 0

    # has a valid image been created yet?
    set img(created) 0

    # the name of the file
    set img(file_name) {}

    # multipage properties (turned off by default)
    set img(multi_page) 0
    set img(curr_page) 0

    # its original and current resolution (in pixels)
    set img(actual_height) 0
    set img(actual_width) 0
    set img(height) 0
    set img(width) 0

    # its format (tiff, bmp etc.)
    set img(file_format) {}

    # original image reference (used when resizing)
    set img(orig_img) {}

    # current image reference
    set img(img) {}

    # the current zoom factor
    set img(zoom) 1.

    # the checksum value for the image file
    set img(cksum) {}

    # the name of the associated jtag file for this image
    set img(jtag_name) {}

    # the name of the associated jlog file for this image
    set img(jlog_name) {}

}


# PUBLIC PROCEDURES #
#####################

# ::Jtag::Image::create_image --
#
#    Attempts to open, validate and create the image given by the filename
#    argument passed.  Also attempts to load any selection data from an
#    associated jtag file.  Also checks whether the file is the first page in
#    an already split multi-page document (by looking for 
#    <base_name>.aa.<suffix> as the file name.  If so, it sets additional
#    attributes.
#
# Arguments:
#    file_name    The name of the file to open
#
# Results:
#    Upon any failure to open, validate, or create the image an error is
#    thrown back to the caller

proc ::Jtag::Image::create_image {file_name} {

    # link any namespace variables
    variable img
    variable can
    variable ::Jtag::Config::jtag_ext
    variable ::Jtag::Config::jlog_ext

    # declare any local variables needed
    variable FileBase {}
    variable DotPos
    variable Response
    variable ScaleW
    variable ScaleH
    variable A1
    variable A2

    debug {entering ::Jtag::Image::create_image}

    # attempt to create an image out of the file specified by $file_name
    # if the file is invalid (not found, not an image etc.) an error is
    # returned to the caller.

    if {! $can(created) } {
        error "No canvas to add the image to"
    }

    catch {image delete $img(orig_img)}

    set img(orig_img) [image create photo -file $file_name]

    # open, validation and creation all succeeded, set all attribs
    set img(file_name) $file_name
    set img(actual_height) [image height $img(orig_img)]
    set img(actual_width) [image width $img(orig_img)]
    set img(height) $img(actual_height)
    set img(width) $img(actual_width)
    set img(zoom) 1.0
    set img(created) 1
    set img(cksum) [::crc::cksum -file $file_name]
    ::Jtag::UI::status_text "Creating image $img(file_name)"

    set img(file_format) [::Jtag::Image::GetFormat $file_name]
    if {$img(file_format) == 0} {
        set img(file_format) {}
    }

    # see if we are dealing with the first page of a multi-page image
    set DotPos [string last "." $file_name]
    if {$DotPos == -1} {
        set FileBase $file_name
        set img(multi_page) 0
        ::Jtag::Menus::multi_page_functions 0
    } else {
        set FileBase [string range $file_name 0 [expr $DotPos - 1]]
        set DotPos [string last "." $FileBase]
        if {$DotPos != -1 && [string length [string range $FileBase \
                             [expr $DotPos + 1] end]] == 2} {
            # enable mutiple page functionality
            if {! $img(multi_page)} {
                set img(multi_page) 1
                ::Jtag::Menus::multi_page_functions 1
            }

            # determine the current page by converting its chars to ints
            # appropriately
            set A1 [expr [scan [string index $FileBase [expr $DotPos + 1]] \
                          %c] - 96]
            set A2 [expr [scan [string index $FileBase [expr $DotPos + 2]] \
                          %c] - 96]
            set img(curr_page) [expr (26 * ($A1 - 1)) + $A2]
        } else {
            set img(multi_page) 0
            ::Jtag::Menus::multi_page_functions 0
        }
    }

    # attempt to add auto-prediction functionality buttons
    ::Jtag::Menus::auto_prediction

    # scale and add the image to the canvas
    set ScaleW [expr [$can(path) cget -width] / ($img(actual_width) + 0.0)]
    set ScaleH [expr [$can(path) cget -height] / ($img(actual_height) + 0.0)]
    ::Jtag::Image::resize [expr $ScaleW <= $ScaleH ? $ScaleW : $ScaleH]

    # allow classifications to be performed on the image/canvas
    ::Jtag::Classify::bind_selection $can(path)

    # check and see if a valid jtag file exists for this image
    set img(jtag_name) ${FileBase}$jtag_ext
    set img(jlog_name) ${FileBase}$jlog_ext

    # open and read the selection (and poss. config) data into the 'data' var
    if {[catch {::Jtag::Config::read_data $img(jtag_name) $img(jlog_name)} \
        Response]} {
        debug "Failed to read contents of jtag/jlog file.  Reason:\n$Response"
    }

    ::Jtag::UI::status_text "Image: $img(file_name)"
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
    variable img

    # declare any local variables needed

    debug {entering ::Jtag::Image::exists}

    return $img(created)

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
    variable img

    # declare any local variables needed

    debug {entering ::Jtag::Image::get_current_dimensions}

    if {! $img(created)} {
        error {can't get dimensions of a non-existent image}
    }

    return [list $img(width) $img(height)]

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
    variable img

    # declare any local variables needed

    debug {entering ::Jtag::Image::get_actual_dimensions}

    if {! $img(created)} {
        error {can't get dimensions of a non-existent image}
    }

    return [list $img(actual_width) $img(actual_height)]

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
    variable img
    variable can

    # declare any local variables needed
    variable Name {c}

    debug {entering ::Jtag::Image::create_canvas}

    # do some sanity checking on the height and width passed
    if {$height <= 0 || $width <= 0} {
        error "Non-positive height or width specified for canvas size"
    }

    # create the canvas
    set can(path) $w.$Name
    eval canvas $can(path) -width $width -height $height $can(attribs) $args

    # make this namespace aware that a canvas has been created
    set can(created) 1

    # return the path of the canvas to the caller
    return $can(path)
    
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
    variable can
    variable scrl

    # declare any local variables needed
    variable PrePath

    debug {entering ::Jtag::Image::add_scrollbars}

    # first ensure that a canvas widget exists
    if {! $can(created)} {
        error {No canvas to add scrollbars to}
    }

    # now ensure that region passed is a list of exactly 4 integer variables
    if {[llength $region] != 4} {
        error {scrlbar region argument must be a list containing 4 integers}
    }

    set scrl(left)   [lindex $region 0]
    set scrl(top)    [lindex $region 1]
    set scrl(right)  [lindex $region 2]
    set scrl(bottom) [lindex $region 3]

    # the path to the scrollbars is the same as that to the canvas widget, 
    # minus the canvas widgets name, plus the addition of cs_x or cs_y 
    # depending on which scrollbar we are dealing with
    set PrePath [string range $can(path) 0 [string last "." $can(path)]]
    set scrl(xpath) [join "$PrePath cs_x" {}]
    set scrl(ypath) [join "$PrePath cs_y" {}]

    # update the canvas to prepare it for the scrollbars
    $can(path) configure -xscrollcommand [list $scrl(xpath) set] \
                         -yscrollcommand [list $scrl(ypath) set] \
                         -confine 1 -scrollregion $region

    # create the horizontal and vertical scrollbars
    scrollbar $scrl(xpath) -orient horizontal \
              -command [list $can(path) xview]
    scrollbar $scrl(ypath) -orient vertical \
              -command [list $can(path) yview]

    set scrl(created) 1

    # return the scrollbars created as a list
    return [list $scrl(xpath) $scrl(ypath)]

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
#    thrown, otherwise sets img(img) to contain a reference to the newly 
#    scaled image, and updates img(height) and img(width) to reflect 
#    the new image resolution.  actual_height and actual_width remain unchanged.

proc ::Jtag::Image::resize {{factor 1.}} {

    # link any namespace variables
    variable can
    variable img
    variable scrl

    # declare any local variables needed
    variable OldZoom $img(zoom)
    variable ShrinkZoom
    variable NextItem {}

    debug {entering ::Jtag::Image::resize}

    # Since the resize operation may be time intensive, prevent clicks and 
    # keyboard bindings with busy (from the BLT package)
    ::blt::busy hold .

    if {! $img(created) } {
        error {Trying to resize a non-existent image}
    }

    # set the new zoom factor 
    set img(zoom) [expr {$img(zoom) * $factor}]

    # delete the previous image (if one exists)
    if {$img(img) != ""} {
        if {$can(created)} {
            # first see if we can locate an item above the image
            set NextItem [$can(path) find above $can(img_tag)]
            $can(path) delete $img(img)
        }
        image delete $img(img)
    }

    # create the new image
    set img(img) [image create photo -format $img(file_format)]

    # resize and copy the original one to the new
    if {$img(zoom) == 0.} {
        set $img(zoom) $OldZoom
        error {Trying to resize to infinity}
    } elseif {$img(zoom) >= 1.} {
        # zoom in to magnify image
        set ShrinkZoom [expr int($img(zoom))]
        set img(zoom) $ShrinkZoom
        debug "magnifying original image by a factor of $img(zoom)"
        $img(img) copy $img(orig_img) -zoom $ShrinkZoom $ShrinkZoom
    } else {
        # zoom out to shrink image
        set ShrinkZoom [expr round(1./$img(zoom))]
        set img(zoom) [expr 1. / $ShrinkZoom]
        debug "shrinking original image by a factor of $img(zoom)"
        $img(img) copy $img(orig_img) -subsample $ShrinkZoom $ShrinkZoom
    }

    # set the new image attributes
    set img(height) [image height $img(img)]
    set img(width) [image width $img(img)]
    if {$can(created)} {
        set can(img_tag) [$can(path) create image 0 0 -image $img(img) \
                          -anchor nw]
        # scale the canvas (and everything on it) to fit the new image
        # first restore the original scale
        $can(path) scale all 0 0 [expr 1.0 / $OldZoom] [expr 1.0 / $OldZoom]
        # now rescale to the new image size
        $can(path) scale all 0 0 $img(zoom) $img(zoom)
        # put the image as low on the canvas as possible
        if {$NextItem != ""} {
            $can(path) lower $can(img_tag) $NextItem
        }
        # see if we can snap the canvas width or height down to that of the
        # image
        if {$img(height) < [$can(path) cget -height]} {
            $can(path) configure -height $img(height)
        }
        if {$img(width) < [$can(path) cget -width]} {
            $can(path) configure -width $img(width)
        }
        if {$scrl(created)} {
            # reset the scroll region to that of the new image
            set scrl(right) [expr $img(width) - $scrl(left)]
            set scrl(bottom) [expr $img(height) - $scrl(top)]
            $can(path) configure -scrollregion [list $scrl(left) \
                       $scrl(top) $scrl(right) $scrl(bottom)]
        }
    }

    # display a message in the status bar
    ::Jtag::UI::status_text "Resized image by a factor of $img(zoom)"

    # allow clicks and binding events again
    ::blt::busy release .
}


# ::Jtag::Image::clear_canvas --
#
#    Removes all items that currently exist on the canvas (images, rectangles,
#    etc.) so that the canvas is completely blank.  Also prohibits selections
#    from occuring on it.
#
# Arguments:
#
# Results:
#    Everything on the canvas is destroyed

proc ::Jtag::Image::clear_canvas {} {

    # link any namespace variables
    variable can

    # declare any local variables

    debug "entering ::Jtag::Image::clear_canvas"

    if {! $can(created)} {
        debug "trying to clear a non-existent canvas"
        return
    }

    $can(path) delete all

    ::Jtag::Classify::unbind_selection

    ::Jtag::UI::status_text "Cleared all items from canvas"

}


# ::Jtag::Image::go_to_pg --
#
#    Attempts to load the page number passed from a multi-page image into the
#    canvas for display.  
#
# Arguments:
#    pg    A positive number specifying the page number we are attempting to 
#          access
#
# Results:
#    The next image is loaded into memory and displayed on the canvas (along
#    with its selections), provided that the next page image exists.  Note
#    that this call has no affect if either the canvas or image has not yet 
#    been created, or the image name is not in valid multi-page format.

proc ::Jtag::Image::go_to_pg {pg} {

    # link any namespace variables
    variable img
    variable can
    variable ::Jtag::Config::data

    # declare any local variables
    variable Result
    variable A1 ;# the first char. of the 2 char page prefix A1=a & A2=a --> 1
    variable A2 ;# the second char. of the 2 char page prefix.
    variable CurrPg
    variable NextPgSuffix
    variable NextPg

    debug {entering ::Jtag::Image::go_to_pg}

    if {! $can(created) || ! $img(created) || ! $img(multi_page) || $pg < 1} {
        debug "Either the canvas/image does not exist or is not multiple pages"
        return
    }

    # save the current pages data
    if {[ catch {::Jtag::Config::write_data} Result]} {
        debug "Failed to write out current pages selections.  Reason:\n$Result"
    }

    # determine the next page
    set img(curr_page) $pg
    set A2 [expr $img(curr_page) % 26]
    if {$A2 == 0} {
        set A2 26
    }
    set A1 [expr ($img(curr_page) / 26) + 1]
    if {$A2 == 26} {
        incr A1 -1
    }
    # to get the unecode values from decimal, we must add 96 
    incr A1 96
    incr A2 96

    set NextPgSuffix [format "%c%c" $A1 $A2]

    set CurrPg $img(file_name)
    set LastCommaPos [string last "." $img(file_name)]
    set NextPg [string range $img(file_name) 0 [expr $LastCommaPos - 3]]
    set NextPg ${NextPg}$NextPgSuffix[string range $img(file_name) \
                                      $LastCommaPos end]


    # remove previous selections from the screen and arrays
    while {[array names data -regexp {(.*)(,)([0-9])+}] != ""} {
        ::Jtag::Classify::remove [lindex \
             [array names data -regexp {(.*)(,)([0-9])+}] 0]

    } 

    ::Jtag::Image::clear_canvas

    # now open the new page
    if {[catch {::Jtag::Image::create_image $NextPg} Result]} {
        debug "Failed to open page $pg.  Reason:\n$Result"
        ::Jtag::Image::create_image $CurrPg
    }

}



# PRIVATE PROCEDURES #
######################


# ::Jtag::Image::GetFormat --
#
#    Attempts to determine the format of a valid image passed in by file name.
#
# Arguments:
#    file_name    The name of the file pointing to the image to identify.
#
# Results:
#    Returns a string giving the image format if it could be found, otherwise
#    returns 0.

proc ::Jtag::Image::GetFormat {file_name} {

    # link the appdir global variable
    global appdir

    # declare any local variables necessary
    variable IdentPath $appdir/bin/identify
    variable IdentArg1 {-format}
    variable IdentArg2 {"%m"}
    variable IdentArg3 {2>/dev/null}
    variable DotPos
    variable Extn

    # check to see if the 'identify' program exists in the appropriate dir.
    if {[file executable $IdentPath]} {
        # use the tool to determine the image type
        set Result [exec $IdentPath $IdentArg1 $IdentArg2 $IdentArg3 $file_name]

        switch -regexp -- $Result {
            TIFF|TIF {
                return "tiff"
            }
            BMP {
                return "bmp"
            }
            JPEG|JPG {
                return "jpeg"
            }
            PNG {
                return "png"
            }
            GIF|GIF87 {
                return "gif"
            }
            XBM {
                return "xbm"
            }

        }
    }

    # attempt to get the format from the filename extension
    set DotPos [string last "." $file_name]
    if {$DotPos != -1} {
        set Extn [string range $file_name [expr $DotPos + 1] end]

        switch -regexp -- $Extn {
            (t|T)(i|I)(f|F){1,2} {
                return "tiff"
            }
            (b|B)(m|M)(p|P) {
                return "bmp"
            }
            (j|J)(p|P)(g|G) {
                return "jpeg"
            }
            (p|P)(n|N)(g|G) {
                return "png"
            }
            (g|G)(i|I)(f|F) {
                return "gif"
            }
            (x|X)(b|B)(m|M) {
                return "xbm"
            }
        }
    }

    # can't determine image format
    return 0

}
