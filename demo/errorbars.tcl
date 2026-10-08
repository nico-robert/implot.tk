# Example from implot_demo.cpp
# void Demo_ErrorBars()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 600 -height 450

$f AddPlotCmd {
    implottk::static {
        foreach {name values} {
            xs   {1 2 3 4 5}
            bar  {1 2 5 3 4}
            lin1 {8 8 9 7 8}
            lin2 {6 7 6 9 6}
            err1 {0.2 0.4 0.2 0.6 0.4}
            err2 {0.4 0.2 0.4 0.8 0.6}
            err3 {0.09 0.14 0.09 0.12 0.16}
            err4 {0.02 0.08 0.15 0.05 0.2}
        } {
            set $name [implottk::doubleToPointer $values]
        }
    }

    if {[implot::BeginPlot "##ErrorBars" {x -1 y -1}]} {
        implot::SetupAxesLimits 0 6 0 10

        implot::PlotBars_doublePtrdoublePtr "Bar" $xs $bar 5 0.5
        implot::PlotErrorBars_doublePtrdoublePtrdoublePtrInt "Bar" $xs $bar $err1 5

        implot::PlotErrorBars_doublePtrdoublePtrdoublePtrdoublePtr "Line" $xs $lin1 $err1 $err2 5 \
            [list LineColor [implot::GetColormapColor 1] Size 0]
        implot::PlotLine_doublePtrdoublePtr "Line" $xs $lin1 5 {Marker ImPlotMarker_Square}

        set spec [list LineColor [implot::GetColormapColor 2] Size 6 LineWeight 1.5]
        implot::PlotErrorBars_doublePtrdoublePtrdoublePtrInt "Scatter" $xs $lin2 $err2 5 $spec
        dict set spec Flags ImPlotErrorBarsFlags_Horizontal
        implot::PlotErrorBars_doublePtrdoublePtrdoublePtrdoublePtr "Scatter" $xs $lin2 $err3 $err4 5 $spec
        implot::PlotScatter_doublePtrdoublePtr "Scatter" $xs $lin2 5

        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
