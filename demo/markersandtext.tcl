# Example from implot_demo.cpp
# void Demo_MarkersAndText()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 600 -height 550

$f AddPlotCmd {
    implottk::static {
        set markerSize   4.0
        set markerWeight 1.0
        set xs [implottk::doubleToPointer {0 0}]
        set ys [implottk::doubleToPointer {0 0}]
        set count [cffi::enum value ::implot::ImPlotMarker_ ImPlotMarker_COUNT]
    }

    imgui::DragFloat "Marker Size"   markerSize   0.1  2.0 10.0 "%.2f px"
    imgui::DragFloat "Marker Weight" markerWeight 0.05 0.5 3.0  "%.2f px"

    if {[implot::BeginPlot "##MarkerStyles" {x -1 y -1} ImPlotFlags_CanvasOnly]} {
        implot::SetupAxes "" "" ImPlotAxisFlags_NoDecorations ImPlotAxisFlags_NoDecorations
        implot::SetupAxesLimits 0 10 0 12

        # filled markers (left) and open markers (right)
        foreach {x0 x1 label alpha} {1 4 "##Filled" 1.0  6 9 "##Open" 0.0} {
            for {set m 0} {$m < $count} {incr m} {
                imgui::PushID_Int $m
                implottk::updatePointer $xs [list $x0 $x1]
                implottk::updatePointer $ys [list [expr {10 - $m}] [expr {11 - $m}]]
                implot::PlotLine_doublePtrdoublePtr $label $xs $ys 2 [list \
                    Marker $m MarkerSize $markerSize LineWeight $markerWeight FillAlpha $alpha]
                imgui::PopID
            }
        }

        implot::PlotText "Filled Markers" 2.5 6.0
        implot::PlotText "Open Markers"   7.5 6.0

        implot::PushStyleColor_Vec4 ImPlotCol_InlayText {x 1 y 0 z 1 w 1}
        implot::PlotText "Vertical Text" 5.0 6.0 {x 0 y 0} {Flags ImPlotTextFlags_Vertical}
        implot::PopStyleColor

        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
