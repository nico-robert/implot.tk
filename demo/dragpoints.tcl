# Example from implot_demo.cpp
# void Demo_DragPoints()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 600 -height 500

$f AddPlotCmd {
    implottk::static {
        set flags 0
        # Control points of the Bezier curve.
        set x0 0.05 ; set y0 0.05
        set x1 0.2  ; set y1 0.4
        set x2 0.8  ; set y2 0.6
        set x3 0.95 ; set y3 0.95
        set bx [implottk::doubleToPointer [lrepeat 100 0.0]]
        set by [implottk::doubleToPointer [lrepeat 100 0.0]]
        set hx [implottk::doubleToPointer {0 0}]
        set hy [implottk::doubleToPointer {0 0}]
    }

    imgui::BulletText "%s" {string "Click and drag each point."}
    imgui::CheckboxFlags_UintPtr "NoCursors" flags 1 ; imgui::SameLine
    imgui::CheckboxFlags_UintPtr "NoFit"     flags 2 ; imgui::SameLine
    imgui::CheckboxFlags_UintPtr "NoInput"   flags 4

    set ax_flags {ImPlotAxisFlags_NoTickLabels ImPlotAxisFlags_NoTickMarks}

    if {[implot::BeginPlot "##Bezier" {x -1 y -1} ImPlotFlags_CanvasOnly]} {
        implot::SetupAxes "" "" $ax_flags $ax_flags
        implot::SetupAxesLimits 0 1 0 1

        implot::DragPoint 0 x0 y0 {x 0 y 0.9 z 0 w 1} 4 $flags c0 h0 held0
        implot::DragPoint 1 x1 y1 {x 1 y 0.5 z 1 w 1} 4 $flags c1 h1 held1
        implot::DragPoint 2 x2 y2 {x 0 y 0.5 z 1 w 1} 4 $flags c2 h2 held2
        implot::DragPoint 3 x3 y3 {x 0 y 0.9 z 0 w 1} 4 $flags c3 h3 held3

        set xs {} ; set ys {}
        for {set i 0} {$i < 100} {incr i} {
            set t  [expr {$i / 99.0}]
            set u  [expr {1 - $t}]
            set w1 [expr {$u * $u * $u}]
            set w2 [expr {3 * $u * $u * $t}]
            set w3 [expr {3 * $u * $t * $t}]
            set w4 [expr {$t * $t * $t}]
            lappend xs [expr {$w1*$x0 + $w2*$x1 + $w3*$x2 + $w4*$x3}]
            lappend ys [expr {$w1*$y0 + $w2*$y1 + $w3*$y2 + $w4*$y3}]
        }
        implottk::updatePointer $bx $xs
        implottk::updatePointer $by $ys

        implottk::updatePointer $hx [list $x0 $x1]
        implottk::updatePointer $hy [list $y0 $y1]
        implot::PlotLine_doublePtrdoublePtr "##h1" $hx $hy 2 [list \
            LineColor {x 1 y 0.5 z 1 w 1} LineWeight [expr {$h1 || $held1 ? 2 : 1}]]

        implottk::updatePointer $hx [list $x2 $x3]
        implottk::updatePointer $hy [list $y2 $y3]
        implot::PlotLine_doublePtrdoublePtr "##h2" $hx $hy 2 [list \
            LineColor {x 0 y 0.5 z 1 w 1} LineWeight [expr {$h2 || $held2 ? 2 : 1}]]

        implot::PlotLine_doublePtrdoublePtr "##bez" $bx $by 100 [list \
            LineColor {x 0 y 0.9 z 0 w 1} \
            LineWeight [expr {$h0 || $held0 || $h3 || $held3 ? 3 : 2}]]

        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
