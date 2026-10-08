# Example from implot_demo.cpp
# void Demo_StemPlots()
# void Demo_InfiniteLines()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 600 -height 600

$f AddPlotCmd {
    implottk::static {
        set xs {} ; set ys1 {} ; set ys2 {}
        for {set i 0} {$i < 51} {incr i} {
            set x [expr {$i * 0.02}]
            lappend xs  $x
            lappend ys1 [expr {1.0 + 0.5 * sin(25 * $x) * cos(2 * $x)}]
            lappend ys2 [expr {0.5 + 0.25 * sin(10 * $x) * sin($x)}]
        }
        set xs  [implottk::doubleToPointer $xs]
        set ys1 [implottk::doubleToPointer $ys1]
        set ys2 [implottk::doubleToPointer $ys2]
        set vals [implottk::doubleToPointer {0.25 0.5 0.75}]
    }

    if {[implot::BeginPlot "Stem Plots" {x -1 y 300}]} {
        implot::SetupAxisLimits ImAxis_X1 0 1.0
        implot::SetupAxisLimits ImAxis_Y1 0 1.6
        implot::PlotStems_doublePtrdoublePtr "Stems 1" $xs $ys1 51
        implot::PlotStems_doublePtrdoublePtr "Stems 2" $xs $ys2 51 0 {Marker ImPlotMarker_Circle}
        implot::EndPlot
    }

    if {[implot::BeginPlot "##Infinite" {x -1 y -1}]} {
        implot::SetupAxes "" "" ImPlotAxisFlags_NoInitialFit ImPlotAxisFlags_NoInitialFit
        implot::PlotInfLines_doublePtr "Vertical"   $vals 3
        implot::PlotInfLines_doublePtr "Horizontal" $vals 3 {Flags ImPlotInfLinesFlags_Horizontal}
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
