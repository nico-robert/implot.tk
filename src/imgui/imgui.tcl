# Copyright (c) 2022-2026 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval ::implottk {

    oo::class create imgui {
        variable _cmdimgui
            
        method AddGuiCmd {args} {
            lappend _cmdimgui [lindex $args 0]
            my redraw
        }
        
        method DrawGuiCmd {} {
            foreach cmd $_cmdimgui {
                my Eval $cmd
            }
        }

        export AddGuiCmd DrawGuiCmd
    }
}