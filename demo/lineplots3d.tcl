# Example from implot3d_demo.cpp
# void DemoLinePlots()
# void DemoScatterPlots()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 900 -height 450

# Animation : the surface is rendered all the time.
$f SetOptions -idleFps 60

$f AddPlotCmd {
    implottk::static {
        set n1 1001
        set xs1 {}
        for {set i 0} {$i < $n1} {incr i} {lappend xs1 [expr {$i * 0.001}]}
        set pxs1 [implottk::doubleToPointer $xs1]
        set pys1 [implottk::doubleToPointer $xs1]
        set pzs1 [implottk::doubleToPointer $xs1]

        set xs2 {} ; set ys2 {} ; set zs2 {}
        for {set i 0} {$i < 20} {incr i} {
            set x [expr {$i / 19.0}]
            lappend xs2 $x
            lappend ys2 [expr {$x * $x}]
            lappend zs2 [expr {$x * $x * $x}]
        }
        set xs2 [implottk::doubleToPointer $xs2]
        set ys2 [implottk::doubleToPointer $ys2]
        set zs2 [implottk::doubleToPointer $zs2]

        expr {srand(0)}
        set sx1 {} ; set sy1 {} ; set sz1 {}
        for {set i 0} {$i < 100} {incr i} {
            set x [expr {$i * 0.01}]
            lappend sx1 $x
            lappend sy1 [expr {$x + 0.1 * rand()}]
            lappend sz1 [expr {$x + 0.1 * rand()}]
        }
        set sx2 {} ; set sy2 {} ; set sz2 {}
        for {set i 0} {$i < 50} {incr i} {
            lappend sx2 [expr {0.25 + 0.2 * rand()}]
            lappend sy2 [expr {0.50 + 0.2 * rand()}]
            lappend sz2 [expr {0.75 + 0.2 * rand()}]
        }
        foreach v {sx1 sy1 sz1 sx2 sy2 sz2} {
            set $v [implottk::doubleToPointer [set $v]]
        }
    }

    # Data changed at each frame.
    set t [expr {[imgui::GetTime] / 10.0}]
    set ys1 {} ; set zs1 {}
    foreach x $xs1 {
        lappend ys1 [expr {0.5 + 0.5 * cos(50 * ($x + $t))}]
        lappend zs1 [expr {0.5 + 0.5 * sin(50 * ($x + $t))}]
    }
    implottk::updatePointer $pys1 $ys1
    implottk::updatePointer $pzs1 $zs1

    set size [imgui::GetContentRegionAvail]
    set w [expr {[dict get $size x] / 2 - 4}]

    if {[implot3d::BeginPlot "Line Plots" [list x $w y -1]]} {
        implot3d::SetupAxes "x" "y" "z"
        implot3d::PlotLine_doublePtr "f(x)" $pxs1 $pys1 $pzs1 $n1
        implot3d::PlotLine_doublePtr "g(x)" $xs2 $ys2 $zs2 20 {
            Marker ImPlot3DMarker_Circle
            Flags  ImPlot3DLineFlags_Segments
        }
        implot3d::EndPlot
    }

    imgui::SameLine

    if {[implot3d::BeginPlot "Scatter Plots" {x -1 y -1}]} {
        implot3d::PlotScatter_doublePtr "Data 1" $sx1 $sy1 $sz1 100
        set color [implot3d::GetColormapColor 1]
        implot3d::PlotScatter_doublePtr "Data 2" $sx2 $sy2 $sz2 50 [list \
            Marker          ImPlot3DMarker_Square \
            MarkerSize      6 \
            MarkerLineColor $color \
            MarkerFillColor $color \
            FillAlpha       0.25]
        implot3d::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
