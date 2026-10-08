# Example from implot_demo.cpp
# void Demo_CustomDataAndGetters()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 700 -height 500

# Spiral : the point is computed from the index.
proc spiral {i} {
    set r [expr {0.9 * $i / 1000.0}]
    set a [expr {$i * 0.03}]
    return [list [expr {0.5 + $r * cos($a)}] [expr {0.5 + $r * sin($a)}]]
}

$f AddPlotCmd {
    implottk::static {
        # Data in Tcl lists.
        set xs {} ; set ys {}
        for {set i 0} {$i < 100} {incr i} {
            lappend xs [expr {$i / 99.0}]
            lappend ys [expr {0.5 + 0.4 * sin(10.0 * $i / 99.0)}]
        }
        set count [llength $xs]
    }

    imgui::BulletText "%s" {string "Getter commands give the points of PlotLineG, PlotScatterG, PlotShadedG..."}
    imgui::BulletText "%s" {string "The command is called for each index (several times by frame) :\nfor large data, the arrays (implottk::doubleToPointer) are faster."}

    if {[implot::BeginPlot "##Getters" {x -1 y -1}]} {
        implot::SetupAxesLimits 0 1 0 1

        # A proc.
        implot::PlotLineG "Spiral" spiral 1000

        # A lambda, the Tcl lists of this script ($xs, $ys are in the frame
        # of the script : the getter is called from this frame).
        implot::PlotScatterG "Lists" [list apply {{xs ys i} {
            list [lindex $xs $i] [lindex $ys $i]
        }} $xs $ys] $count {Marker ImPlotMarker_Circle MarkerSize 3}

        # Two getters : shaded area between two functions.
        implot::PlotShadedG "Shaded" \
            {apply {{i} {set x [expr {$i / 99.0}]; list $x [expr {0.2 + 0.1 * cos(6 * $x)}]}}} \
            {apply {{i} {set x [expr {$i / 99.0}]; list $x [expr {0.05 * $x}]}}} \
            100 {FillAlpha 0.5}
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
