# Example from implot_demo.cpp
# void Demo_ScatterPlots()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 600 -height 450

$f AddPlotCmd {
    implottk::static {
        expr {srand(0)}
        set xs1 {} ; set ys1 {}
        for {set i 0} {$i < 100} {incr i} {
            set x [expr {$i * 0.01}]
            lappend xs1 $x
            lappend ys1 [expr {$x + 0.1 * rand()}]
        }
        set xs2 {} ; set ys2 {}
        for {set i 0} {$i < 50} {incr i} {
            lappend xs2 [expr {0.25 + 0.2 * rand()}]
            lappend ys2 [expr {0.75 + 0.2 * rand()}]
        }
        set xs1 [implottk::doubleToPointer $xs1]
        set ys1 [implottk::doubleToPointer $ys1]
        set xs2 [implottk::doubleToPointer $xs2]
        set ys2 [implottk::doubleToPointer $ys2]
    }

    if {[implot::BeginPlot "Scatter Plot" {x -1 y -1}]} {
        implot::PlotScatter_doublePtrdoublePtr "Data 1" $xs1 $ys1 100
        set color [implot::GetColormapColor 1]
        implot::PlotScatter_doublePtrdoublePtr "Data 2" $xs2 $ys2 50 [list \
            Marker     ImPlotMarker_Square \
            MarkerSize 6 \
            LineColor  $color \
            FillColor  $color \
            FillAlpha  0.25]
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
