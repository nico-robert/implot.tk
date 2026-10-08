# Example from implot_demo.cpp
# void Demo_Heatmaps()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 700 -height 400

$f AddPlotCmd {
    implottk::static {
        set values1 [implottk::doubleToPointer {
            0.8 2.4 2.5 3.9 0.0 4.0 0.0
            2.4 0.0 4.0 1.0 2.7 0.0 0.0
            1.1 2.4 0.8 4.3 1.9 4.4 0.0
            0.6 0.0 0.3 0.0 3.1 0.0 0.0
            0.7 1.7 0.6 2.6 2.2 6.2 0.0
            1.3 1.2 0.0 0.0 0.0 3.2 5.1
            0.1 2.0 0.0 1.4 0.0 1.9 6.3
        }]
        set scale_min 0
        set scale_max 6.3
        set xlabels {C1 C2 C3 C4 C5 C6 C7}
        set ylabels {R1 R2 R3 R4 R5 R6 R7}
        set map      [cffi::enum value ::implot::ImPlotColormap_ ImPlotColormap_Viridis]
        set hm_flags 0
        set axes_flags {ImPlotAxisFlags_Lock ImPlotAxisFlags_NoGridLines ImPlotAxisFlags_NoTickMarks}

        # Random values (80 x 80), new values at each frame.
        set size 80
        set values2 [implottk::doubleToPointer [lrepeat [expr {$size * $size}] 0.0]]
    }

    if {[implot::ColormapButton [implot::GetColormapName $map] {x 225 y 0} $map]} {
        set map [expr {($map + 1) % [implot::GetColormapCount]}]
        # We bust the color cache of our plots so that item colors will
        # resample the new colormap in the event that they have already
        # been created. See documentation in implot.h.
        implot::BustColorCache "##Heatmap1"
        implot::BustColorCache "##Heatmap2"
    }

    imgui::SameLine
    imgui::LabelText "##Colormap Index" "%s" {string "Change Colormap"}
    imgui::SetNextItemWidth 225
    imgui::DragFloatRange2 "Min / Max" scale_min scale_max 0.01 -20 20
    # ImPlotHeatmapFlags_ColMajor = 1024
    imgui::CheckboxFlags_UintPtr "Column Major" hm_flags 1024

    implot::PushColormap_PlotColormap $map

    set side [expr {[imgui::GetTextLineHeight] * 14}]

    if {[implot::BeginPlot "##Heatmap1" [list x $side y $side] {ImPlotFlags_NoLegend ImPlotFlags_NoMouseText}]} {
        implot::SetupAxes "" "" $axes_flags $axes_flags
        implot::SetupAxisTicks_double ImAxis_X1 [expr {0 + 1.0/14.0}] [expr {1 - 1.0/14.0}] 7 $xlabels
        implot::SetupAxisTicks_double ImAxis_Y1 [expr {1 - 1.0/14.0}] [expr {0 + 1.0/14.0}] 7 $ylabels
        implot::PlotHeatmap_doublePtr "heat" $values1 7 7 $scale_min $scale_max "%g" {x 0 y 0} {x 1 y 1} \
            [list Flags $hm_flags]
        implot::EndPlot
    }
    imgui::SameLine
    implot::ColormapScale "##HeatScale" $scale_min $scale_max {x 60 y 225}

    imgui::SameLine

    set random {}
    for {set i 0} {$i < $size * $size} {incr i} {lappend random [expr {rand()}]}
    implottk::updatePointer $values2 $random

    if {[implot::BeginPlot "##Heatmap2" [list x $side y $side]]} {
        implot::SetupAxes "" "" ImPlotAxisFlags_NoDecorations ImPlotAxisFlags_NoDecorations
        implot::SetupAxesLimits -1 1 -1 1
        implot::PlotHeatmap_doublePtr "heat1" $values2 $size $size 0 1 ""
        implot::PlotHeatmap_doublePtr "heat2" $values2 $size $size 0 1 "" {x -1 y -1} {x 0 y 0}
        implot::EndPlot
    }
    implot::PopColormap
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
