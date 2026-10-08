# Example from implot_demo.cpp
# void Demo_SubplotsSizing()

proc sineWave {freq len} {
    # Returns the cffi pointers {xs ys} of a sine wave (computed once).
    if {![info exists ::waves($freq,$len)]} {
        set x {}
        set y {}
        for {set i 0} {$i < $len} {incr i} {
            lappend x $i
            lappend y [expr {sin($freq * $i)}]
        }
        set ::waves($freq,$len) [list [implottk::doubleToPointer $x] [implottk::doubleToPointer $y]]
    }
    return $::waves($freq,$len)
}

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

# set frame
set f [implottk::surface new]
$f SetOptions -width 800 -height 600

# add options
$f SetOptions -title "Subplots sizing"

# ImPlotSubplotFlags_NoResize = 8
# ImPlotSubplotFlags_NoTitle  = 1

# add cmds 'Imgui' on the fly
$f AddGuiCmd {
    implottk::static {
        set flags 0
        set rows 3
        set cols 3
        set rratios [implottk::arrayToFloat {5 1 1 1 1 1}]
        set cratios [implottk::arrayToFloat {5 1 1 1 1 1}]
    }

    imgui::CheckboxFlags_UintPtr "ImPlotSubplotFlags_NoResize" flags 8
    imgui::CheckboxFlags_UintPtr "ImPlotSubplotFlags_NoTitle"  flags 1
    
    imgui::SliderInt "Rows" rows 1 5
    imgui::SliderInt "Cols" cols 1 5
    
    imgui::DragScalarN "Row Ratios" ImGuiDataType_Float $rratios $rows 0.01
    imgui::DragScalarN "Col Ratios" ImGuiDataType_Float $cratios $cols 0.01
}

# add cmds 'Implot' on the fly
$f AddPlotCmd {

    if {[implot::BeginSubplots "My Subplots" $rows $cols {x -1 y -1} $flags $rratios $cratios]} {
    
        for {set i 0} {$i < [expr {$rows * $cols}]} {incr i} {
            if {[implot::BeginPlot "" {x -1 y -1} ImPlotFlags_NoLegend]} {
                implot::SetupAxes "" "" ImPlotAxisFlags_NoDecorations ImPlotAxisFlags_NoDecorations
                set fi [expr {0.01 * ($i + 1)}]
                set color [implot::SampleColormap [expr {$i / double(max($rows * $cols - 1, 1))}] ImPlotColormap_Jet]
                set len 1000
                lassign [sineWave $fi $len] xs ys
                implot::PlotLine_doublePtrdoublePtr "data" $xs $ys $len [list LineColor $color]
                implot::EndPlot
            }
        }
        implot::EndSubplots
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
