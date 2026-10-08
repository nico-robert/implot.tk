# Example from implot_demo.cpp
# void Demo_Histogram2D()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 700 -height 550

proc NormalDistribution {n mean sd} {
    # Returns n values of a normal distribution (Box-Muller).
    set data {}
    set pi2 [expr {2 * acos(-1)}]
    for {set i 0} {$i < $n} {incr i} {
        set u1 [expr {1.0 - rand()}]
        lappend data [expr {$mean + $sd * sqrt(-2.0 * log($u1)) * cos($pi2 * rand())}]
    }
    return $data
}

$f AddPlotCmd {
    implottk::static {
        set count  50000
        set xybins {100 100}
        # ImPlotHistogramFlags_Density = 4096
        set hist_flags 0
        set dist1 [implottk::doubleToPointer [NormalDistribution 100000 1 2]]
        set dist2 [implottk::doubleToPointer [NormalDistribution 100000 1 1]]
        set max_count 0
    }

    imgui::SliderInt  "Count" count 100 100000
    imgui::SliderInt2 "Bins" xybins 1 500
    imgui::SameLine
    imgui::CheckboxFlags_UintPtr "Density" hist_flags 4096

    set flags {ImPlotAxisFlags_AutoFit ImPlotAxisFlags_Foreground}
    implot::PushColormap_PlotColormap ImPlotColormap_Hot

    set width [expr {[dict get [imgui::GetContentRegionAvail] x] - 110}]
    if {[implot::BeginPlot "##Hist2D" [list x $width y -1]]} {
        implot::SetupAxes "" "" $flags $flags
        implot::SetupAxesLimits -6 6 -6 6
        lassign $xybins xbins ybins
        set max_count [implot::PlotHistogram2D_doublePtr "Hist2D" $dist1 $dist2 $count $xbins $ybins \
            {X {Min -6 Max 6} Y {Min -6 Max 6}} [list Flags $hist_flags]]
        implot::EndPlot
    }
    imgui::SameLine
    implot::ColormapScale [expr {$hist_flags & 4096 ? "Density" : "Count"}] 0 $max_count {x 100 y 0}
    implot::PopColormap
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
