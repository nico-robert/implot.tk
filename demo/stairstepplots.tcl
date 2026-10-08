# Example from implot_demo.cpp
# void Demo_StairstepPlots()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 600 -height 450

$f AddPlotCmd {
    implottk::static {
        set ys1 {} ; set ys2 {}
        for {set i 0} {$i < 21} {incr i} {
            lappend ys1 [expr {0.75 + 0.2 * sin(10 * $i * 0.05)}]
            lappend ys2 [expr {0.25 + 0.2 * sin(10 * $i * 0.05)}]
        }
        set ys1 [implottk::doubleToPointer $ys1]
        set ys2 [implottk::doubleToPointer $ys2]
        set flags 0
    }

    imgui::CheckboxFlags_UintPtr "ImPlotStairsFlags_Shaded" flags 2048

    if {[implot::BeginPlot "Stairstep Plot" {x -1 y -1}]} {
        implot::SetupAxes "x" "f(x)"
        implot::SetupAxesLimits 0 1 0 1

        set gray {LineColor {x 0.5 y 0.5 z 0.5 w 1}}
        implot::PlotLine_doublePtrInt "##1" $ys1 21 0.05 0 $gray
        implot::PlotLine_doublePtrInt "##2" $ys2 21 0.05 0 $gray

        implot::PlotStairs_doublePtrInt "Post Step (default)" $ys1 21 0.05 0 \
            [list Flags $flags FillAlpha 0.25 Marker ImPlotMarker_Auto]
        # ImPlotStairsFlags_PreStep = 1024
        implot::PlotStairs_doublePtrInt "Pre Step" $ys2 21 0.05 0 \
            [list Flags [expr {$flags | 1024}] FillAlpha 0.25 Marker ImPlotMarker_Auto]

        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
