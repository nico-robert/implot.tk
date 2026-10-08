# Example from implot_demo.cpp
# void Demo_LogScale()
# void Demo_SymmetricLogScale()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 650 -height 650

$f AddPlotCmd {
    implottk::static {
        set xs {} ; set ys1 {} ; set ys2 {} ; set ys3 {}
        for {set i 0} {$i < 1001} {incr i} {
            set x [expr {$i * 0.1}]
            lappend xs  $x
            lappend ys1 [expr {sin($x) + 1}]
            lappend ys2 [expr {$x > 0 ? log($x) : -Inf}]
            lappend ys3 [expr {10.0 ** min($x, 300)}]
        }
        foreach name {xs ys1 ys2 ys3} {set $name [implottk::doubleToPointer [set $name]]}

        set sxs {} ; set sys1 {} ; set sys2 {}
        for {set i 0} {$i < 1001} {incr i} {
            set x [expr {$i * 0.1 - 50}]
            lappend sxs  $x
            lappend sys1 [expr {sin($x)}]
            lappend sys2 [expr {$i * 0.002 - 1}]
        }
        foreach name {sxs sys1 sys2} {set $name [implottk::doubleToPointer [set $name]]}
    }

    if {[implot::BeginPlot "Log Plot" {x -1 y 300}]} {
        implot::SetupAxisScale_PlotScale ImAxis_X1 ImPlotScale_Log10
        implot::SetupAxesLimits 0.1 100 0 10
        implot::PlotLine_doublePtrdoublePtr "f(x) = x"        $xs $xs  1001
        implot::PlotLine_doublePtrdoublePtr "f(x) = sin(x)+1" $xs $ys1 1001
        implot::PlotLine_doublePtrdoublePtr "f(x) = log(x)"   $xs $ys2 1001
        implot::PlotLine_doublePtrdoublePtr "f(x) = 10^x"     $xs $ys3 21
        implot::EndPlot
    }

    if {[implot::BeginPlot "SymLog Plot" {x -1 y -1}]} {
        implot::SetupAxisScale_PlotScale ImAxis_X1 ImPlotScale_SymLog
        implot::PlotLine_doublePtrdoublePtr "f(x) = a*x+b"  $sxs $sys2 1001
        implot::PlotLine_doublePtrdoublePtr "f(x) = sin(x)" $sxs $sys1 1001
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
