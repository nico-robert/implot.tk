# Example from implot_demo.cpp
# void Demo_PieCharts()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 650 -height 400

$f AddPlotCmd {
    implottk::static {
        set labels1 {Frogs Hogs Dogs Logs}
        set data1   {0.15 0.30 0.2 0.05}
        set values1 [implottk::doubleToPointer $data1]

        set labels2 {A B C D E}
        set values2 [implottk::doubleToPointer {1 1 2 3 5}]

        set flags 0
    }

    imgui::SetNextItemWidth 250
    # DragFloat4 changes the list 'data1', copied in the array of the plot.
    if {[imgui::DragFloat4 "Values" data1 0.01 0 1]} {
        implottk::updatePointer $values1 $data1
    }
    imgui::CheckboxFlags_UintPtr "ImPlotPieChartFlags_Normalize"     flags 1024
    imgui::CheckboxFlags_UintPtr "ImPlotPieChartFlags_IgnoreHidden"  flags 2048
    imgui::CheckboxFlags_UintPtr "ImPlotPieChartFlags_Exploding"     flags 4096
    imgui::CheckboxFlags_UintPtr "ImPlotPieChartFlags_NoSliceBorder" flags 8192

    set size [expr {[imgui::GetTextLineHeight] * 16}]
    set plotFlags {ImPlotFlags_Equal ImPlotFlags_NoMouseText}

    if {[implot::BeginPlot "##Pie1" [list x $size y $size] $plotFlags]} {
        implot::SetupAxes "" "" ImPlotAxisFlags_NoDecorations ImPlotAxisFlags_NoDecorations
        implot::SetupAxesLimits 0 1 0 1
        implot::PlotPieChart_doublePtrStr $labels1 $values1 4 0.5 0.5 0.4 "%.2f" 90 [list Flags $flags]
        implot::EndPlot
    }

    imgui::SameLine

    implot::PushColormap_PlotColormap ImPlotColormap_Pastel
    if {[implot::BeginPlot "##Pie2" [list x $size y $size] $plotFlags]} {
        implot::SetupAxes "" "" ImPlotAxisFlags_NoDecorations ImPlotAxisFlags_NoDecorations
        implot::SetupAxesLimits 0 1 0 1
        implot::PlotPieChart_doublePtrStr $labels2 $values2 5 0.5 0.5 0.4 "%.0f" 180 [list Flags $flags]
        implot::EndPlot
    }
    implot::PopColormap
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
