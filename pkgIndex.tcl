# Copyright (c) 2022-2026 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

package ifneeded implot.tk 1.0 [list apply {dir {

    source [file join $dir implottk.tcl]

    # imgui
    source [file join $dir src imgui imgui.tcl]
    source [file join $dir src imgui alias.tcl]
    source [file join $dir src imgui enums.tcl]
    source [file join $dir src imgui structs.tcl]
    source [file join $dir src imgui funcs.tcl]

    # implot
    source [file join $dir src implot implot.tcl]
    source [file join $dir src implot alias.tcl]
    source [file join $dir src implot enums.tcl]
    source [file join $dir src implot structs.tcl]
    source [file join $dir src implot funcs.tcl]

    # implot3d
    source [file join $dir src implot3d enums.tcl]
    source [file join $dir src implot3d structs.tcl]
    source [file join $dir src implot3d funcs.tcl]

    # src 
    source [file join $dir src utils.tcl]
    source [file join $dir src tkfont.tcl]
    source [file join $dir src input.tcl]
    source [file join $dir src surface.tcl]

}} $dir]
