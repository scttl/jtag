#!/bin/sh
# restart the shell script using the wish interpreter\
exec wish "$0" "$@"

# remove the following line if autoscroll is on the package path
source autoscroll.tcl

 package require autoscroll
 namespace import ::autoscroll::autoscroll

 text .t -width 40 -height 24 \
     -yscrollcommand [list .y set] -xscrollcommand [list .x set] \
     -font {Courier 12} -wrap none
 scrollbar .y -orient vertical -command [list .t yview]
 scrollbar .x -orient horizontal -command [list .t xview]

 grid .t -row 0 -column 1 -sticky nsew
 grid .y -row 0 -sticky ns \
     -column 2; # change to -column 0 for left-handers
 grid .x -row 1 -column 1 -sticky ew

 grid columnconfigure . 1 -weight 1
 grid rowconfigure . 0 -weight 1

 autoscroll .x
 autoscroll .y

 for { set i 0 } { $i < 26 } { incr i } {
     .t insert end {This widget contains a lot of text, doesn't it?}
     .t insert end \n
 }
