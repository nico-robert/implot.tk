# Example from implot_demo.cpp
# void Demo_Histogram()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 750 -height 500

proc NormalDistribution {n mean sd} {
    # Returns n values of a normal distribution (Box-Muller).
    set data {}
    for {set i 0} {$i < $n} {incr i} {
        set u1 [expr {1.0 - rand()}]
        set u2 [expr {rand()}]
        lappend data [expr {$mean + $sd * sqrt(-2.0 * log($u1)) * cos(2 * acos(-1) * $u2)}]
    }
    return $data
}

$f AddPlotCmd {
    implottk::static {
        # ImPlotHistogramFlags : Horizontal 1024, Cumulative 2048,
        # Density 4096, NoOutliers 8192.
        set hist_flags 4096
        set bins       50
        set mu         5
        set sigma      2
        set range      0
        set rmin       -3
        set rmax       13
        set dist [implottk::doubleToPointer [NormalDistribution 10000 $mu $sigma]]
        set x [implottk::doubleToPointer [lrepeat 100 0.0]]
        set y [implottk::doubleToPointer [lrepeat 100 0.0]]
    }

    # ImPlotBin_ : Sqrt -1, Sturges -2, Rice -3, Scott -4 (or a number of bins).
    foreach {label value} {Sqrt -1 Sturges -2 Rice -3 Scott -4} {
        imgui::RadioButton_IntPtr $label bins $value
        imgui::SameLine
    }
    imgui::RadioButton_IntPtr "N Bins" bins [expr {$bins >= 0 ? $bins : 50}]
    if {$bins >= 0} {
        imgui::SameLine
        imgui::SetNextItemWidth 200
        imgui::SliderInt "##Bins" bins 1 100
    }
    imgui::CheckboxFlags_UintPtr "Horizontal" hist_flags 1024 ; imgui::SameLine
    imgui::CheckboxFlags_UintPtr "Density"    hist_flags 4096 ; imgui::SameLine
    imgui::CheckboxFlags_UintPtr "Cumulative" hist_flags 2048

    imgui::Checkbox "Range" range
    if {$range} {
        imgui::SameLine
        imgui::SetNextItemWidth 200
        set r [list $rmin $rmax]
        if {[imgui::DragFloat2 "##Range" r 0.1 -3 13]} {lassign $r rmin rmax}
        imgui::SameLine
        imgui::CheckboxFlags_UintPtr "Exclude Outliers" hist_flags 8192
    }

    # Theoretical density (or cumulative distribution).
    if {$hist_flags & 4096} {
        set xs {} ; set ys {}
        for {set i 0} {$i < 100} {incr i} {
            set xi [expr {-3 + 16 * $i / 99.0}]
            lappend xs $xi
            lappend ys [expr {exp(-(($xi - $mu)**2) / (2 * $sigma**2)) / ($sigma * sqrt(2 * acos(-1)))}]
        }
        if {$hist_flags & 2048} {
            set sum 0 ; set cs {}
            foreach v $ys {lappend cs [set sum [expr {$sum + $v}]]}
            set ys [lmap v $cs {expr {$v / $sum}}]
        }
        implottk::updatePointer $x $xs
        implottk::updatePointer $y $ys
    }

    if {[implot::BeginPlot "##Histograms" {x -1 y -1}]} {
        implot::SetupAxes "" "" ImPlotAxisFlags_AutoFit ImPlotAxisFlags_AutoFit
        set hrange [expr {$range ? [list Min $rmin Max $rmax] : {Min 0 Max 0}}]
        implot::PlotHistogram_doublePtr "Empirical" $dist 10000 $bins 1.0 $hrange \
            [list FillAlpha 0.5 Flags $hist_flags]
        if {($hist_flags & 4096) && !($hist_flags & 8192)} {
            if {$hist_flags & 1024} {
                implot::PlotLine_doublePtrdoublePtr "Theoretical" $y $x 100
            } else {
                implot::PlotLine_doublePtrdoublePtr "Theoretical" $x $y 100
            }
        }
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
