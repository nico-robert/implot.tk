# Example from implot_demo.cpp
# void Demo_DragLines()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 600 -height 500

$f AddPlotCmd {
    implottk::static {
        set x1 0.2 ; set x2 0.8
        set y1 0.25 ; set y2 0.75
        set freq 0.1
        set flags 0
        set xs [implottk::doubleToPointer [lrepeat 1000 0.0]]
        set ys [implottk::doubleToPointer [lrepeat 1000 0.0]]
    }

    imgui::BulletText "%s" {string "Click and drag the horizontal and vertical lines."}
    imgui::CheckboxFlags_UintPtr "NoCursors" flags 1 ; imgui::SameLine
    imgui::CheckboxFlags_UintPtr "NoFit"     flags 2 ; imgui::SameLine
    imgui::CheckboxFlags_UintPtr "NoInput"   flags 4

    if {[implot::BeginPlot "##lines" {x -1 y -1}]} {
        implot::SetupAxesLimits 0 1 0 1
        set white {x 1 y 1 z 1 w 1}
        implot::DragLineX 0 x1 $white 1 $flags
        implot::DragLineX 1 x2 $white 1 $flags
        implot::DragLineY 2 y1 $white 1 $flags
        implot::DragLineY 3 y2 $white 1 $flags

        set lx {} ; set ly {}
        for {set i 0} {$i < 1000} {incr i} {
            lappend lx [expr {($x2 + $x1) / 2 + abs($x2 - $x1) * ($i / 1000.0 - 0.5)}]
            lappend ly [expr {($y1 + $y2) / 2 + abs($y2 - $y1) / 2 * sin($freq * $i / 10)}]
        }
        implottk::updatePointer $xs $lx
        implottk::updatePointer $ys $ly

        implot::DragLineY 120482 freq {x 1 y 0.5 z 1 w 1} 1 $flags clicked hovered held
        implot::PlotLine_doublePtrdoublePtr "Interactive Data" $xs $ys 1000 \
            [list LineWeight [expr {$hovered || $held ? 2 : 1}]]
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
