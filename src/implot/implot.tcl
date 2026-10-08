# Copyright (c) 2022-2026 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval ::implottk {

    oo::class create plot {
        variable _cmdplot ; # list commands plot

        method AddPlotCmd {args} {
            # Adds an ImPlot script, evaluated at each frame (see Eval).
            # Without 'implot::BeginPlot' in the script, the surface calls
            # BeginPlot / EndPlot around it (options -title, -axisName).
            #
            # args - script
            #
            # Returns nothing
            lappend _cmdplot [lindex $args 0]
            my redraw

            return {}
        }

        method DrawPlotCmd {} {
            foreach cmd $_cmdplot {
                my Eval $cmd
            }
        }

        export AddPlotCmd DrawPlotCmd
    }
}
