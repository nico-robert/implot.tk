# Copyright (c) 2022-2026 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval ::implottk {}

proc ::implottk::rgbaToVec4 {rgb {a 255}} {
    # Transform rgb colors to struct.ImVec4 format.
    #
    # rgb - list colors rgb
    # a   - alpha state
    #
    # Returns A struct.ImVec4
    set rgba [linsert $rgb end $a]

    foreach value {x y z w} color $rgba {
        lappend vec4 $value [expr {$color / double(255)}]
    }
    
    return $vec4
}

proc ::implottk::arrayToFloat {data} {
    # Transform list data to cffi array float.
    #
    # data - list
    #
    # Returns A pointer
    set len [llength $data]
    return [cffi::memory new float\[$len\] $data]
}

proc ::implottk::doubleToPointer {data} {
    # Transform list data to cffi array double.
    #
    # data - list
    #
    # Returns A pointer.double
    set len [llength $data]
    return [cffi::memory new double\[$len\] $data ::implot::double]
}

proc ::implottk::uintToPointer {data} {
    # Transform list data to cffi array unsigned int (indices of
    # implot3d::PlotMesh).
    #
    # data - list
    #
    # Returns A pointer.uint
    set len [llength $data]
    return [cffi::memory new uint\[$len\] $data ::implot3d::uint]
}

proc ::implottk::updatePointer {pointer data} {
    # Writes list data in an array created by implottk::doubleToPointer
    # (data changed at each frame, without allocating memory).
    #
    # pointer - pointer.double (its array must hold at least the values)
    # data    - list
    #
    # Returns the pointer.
    cffi::memory set $pointer double\[[llength $data]\] $data
    return $pointer
}

proc ::implottk::isWindows {} {
    # Checks if running on Windows platform.
    #
    # Returns true if platform is Windows, false otherwise.
    return [expr {$::tcl_platform(platform) eq "windows"}]
}

proc ::implottk::static {args} {
    # Initializes the variables of a surface script (AddGuiCmd, AddPlotCmd)
    # only the first time, like the 'static' variables of C : the scripts
    # of a surface are evaluated in the same frame at each frame, so their
    # variables are kept from one frame to the next.
    #
    # args - a script, evaluated only the first time,
    #        or pairs 'name value' (value set if the variable doesn't exist).
    #
    # Returns nothing.
    if {[llength $args] == 1} {
        set script [lindex $args 0]
        upvar 1 {#static} done
        if {[info exists done($script)]} {return}
        uplevel 1 $script
        set done($script) 1
    } elseif {[llength $args] % 2 == 0} {
        foreach {name value} $args {
            upvar 1 $name var
            if {![info exists var]} {set var $value}
        }
    } else {
        error "wrong # args: should be \"implottk::static script\"\
               or \"implottk::static name value ?name value ...?\""
    }
    return
}
