# Example from implot_demo.cpp
# void Demo_BubblePlots()
# void Demo_PolygonPlots()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 650 -height 650

$f AddPlotCmd {
    implottk::static {
        # Bubbles : x, y and size of each bubble.
        expr {srand(0)}
        set xs {} ; set ys1 {} ; set ys2 {} ; set szs1 {} ; set szs2 {}
        for {set i 0} {$i < 20} {incr i} {
            lappend xs  [expr {$i * 0.1}]
            lappend ys1 [expr {rand()}]
            lappend ys2 [expr {rand()}]
            lappend szs1 [expr {0.02 + 0.08 * rand()}]
            lappend szs2 [expr {0.02 + 0.08 * rand()}]
        }
        foreach name {xs ys1 ys2 szs1 szs2} {
            set $name [implottk::doubleToPointer [set $name]]
        }

        # Polygons : triangle and pentagon (convex), star (concave).
        set pi [expr {acos(-1)}]
        set tri_xs [implottk::doubleToPointer {0.5 1.0 0.0}]
        set tri_ys [implottk::doubleToPointer {1.0 0.0 0.0}]
        set pxs {} ; set pys {}
        for {set i 0} {$i < 5} {incr i} {
            set angle [expr {$i * 2 * $pi / 5 - $pi / 2}]
            lappend pxs [expr {3.0 + 0.8 * cos($angle)}]
            lappend pys [expr {0.5 + 0.8 * sin($angle)}]
        }
        set pent_xs [implottk::doubleToPointer $pxs]
        set pent_ys [implottk::doubleToPointer $pys]
        set sxs {} ; set sys {}
        for {set i 0} {$i < 10} {incr i} {
            set angle  [expr {$i * 2 * $pi / 10 - $pi / 2}]
            set radius [expr {$i % 2 == 0 ? 0.8 : 0.3}]
            lappend sxs [expr {5.5 + $radius * cos($angle)}]
            lappend sys [expr {0.5 + $radius * sin($angle)}]
        }
        set star_xs [implottk::doubleToPointer $sxs]
        set star_ys [implottk::doubleToPointer $sys]
    }

    if {[implot::BeginPlot "Bubble Plot" {x -1 y 300} ImPlotFlags_Equal]} {
        implot::PlotBubbles_doublePtrdoublePtrdoublePtr "Data 1" $xs $ys1 $szs1 20 {FillAlpha 0.5}
        implot::PlotBubbles_doublePtrdoublePtrdoublePtr "Data 2" $xs $ys2 $szs2 20 \
            {FillAlpha 0.5 LineColor {x 0 y 0 z 0 w 0}}
        implot::EndPlot
    }

    if {[implot::BeginPlot "Polygon Plot" {x -1 y -1} ImPlotFlags_Equal]} {
        implot::PlotPolygon_doublePtr "Triangle" $tri_xs $tri_ys 3 {FillAlpha 0.5}
        implot::PlotPolygon_doublePtr "Pentagon" $pent_xs $pent_ys 5 \
            {FillAlpha 0.5 FillColor {x 0 y 1 z 0 w 1}}
        implot::PlotPolygon_doublePtr "Star (Concave)" $star_xs $star_ys 10 \
            {FillAlpha 0.5 FillColor {x 1 y 1 z 0 w 1} Flags ImPlotPolygonFlags_Concave}
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
