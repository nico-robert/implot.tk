# Example from implot_demo.cpp
# void Demo_BarPlots()
# void Demo_BarGroups()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 700 -height 650

$f AddPlotCmd {
    implottk::static {
        set data [implottk::doubleToPointer {1 2 3 4 5 6 7 8 9 10}]

        # midterm, final, course (row major : 3 items x 10 groups)
        set grades [implottk::doubleToPointer {
            83 67 23 89 83 78 91 82 85 90
            80 62 56 99 55 78 88 78 90 100
            80 69 52 92 72 78 75 76 89 95
        }]
        set ilabels   {"Midterm Exam" "Final Exam" "Course Grade"}
        set glabels   {S1 S2 S3 S4 S5 S6 S7 S8 S9 S10}
        set positions [implottk::doubleToPointer {0 1 2 3 4 5 6 7 8 9}]

        set items  3
        set size   0.67
        set flags  0
        set horz   0
    }

    # Bar Plots
    if {[implot::BeginPlot "Bar Plot" {x -1 y 250}]} {
        implot::PlotBars_doublePtrInt "Vertical"   $data 10 0.7 1
        implot::PlotBars_doublePtrInt "Horizontal" $data 10 0.4 1 {Flags ImPlotBarsFlags_Horizontal}
        implot::EndPlot
    }

    # Bar Groups
    imgui::CheckboxFlags_UintPtr "Stacked" flags 2048 ; imgui::SameLine
    imgui::Checkbox "Horizontal" horz
    imgui::SliderInt   "Items" items 1 3
    imgui::SliderFloat "Size"  size  0 1

    if {[implot::BeginPlot "Bar Group" {x -1 y -1}]} {
        implot::SetupLegend ImPlotLocation_East ImPlotLegendFlags_Outside
        set labels [lrange $ilabels 0 $items-1]
        if {$horz} {
            implot::SetupAxes "Score" "Student" ImPlotAxisFlags_AutoFit ImPlotAxisFlags_AutoFit
            implot::SetupAxisTicks_doublePtr ImAxis_Y1 $positions 10 $glabels
            # ImPlotBarGroupsFlags_Horizontal = 1024
            implot::PlotBarGroups_doublePtr $labels $grades $items 10 $size 0 \
                [list Flags [expr {$flags | 1024}]]
        } else {
            implot::SetupAxes "Student" "Score" ImPlotAxisFlags_AutoFit ImPlotAxisFlags_AutoFit
            implot::SetupAxisTicks_doublePtr ImAxis_X1 $positions 10 $glabels
            implot::PlotBarGroups_doublePtr $labels $grades $items 10 $size 0 \
                [list Flags $flags]
        }
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
