# Example from implot_demo.cpp
# void Demo_LinkedAxes()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 600 -height 600

$f AddPlotCmd {
    implottk::static {
        # The linked limits : arrays of 1 double, read and written by
        # ImPlot (SetupAxisLinks keeps the pointers).
        foreach name {xmin xmax ymin ymax} value {0 1 0 1} {
            set lims($name) [implottk::doubleToPointer [list $value]]
        }
        set linkx 1
        set linky 1
        set data [implottk::doubleToPointer {0 1}]
    }

    imgui::Checkbox "Link X" linkx ; imgui::SameLine
    imgui::Checkbox "Link Y" linky

    if {[implot::BeginAlignedPlots "AlignedGroup"]} {
        foreach title {"Plot A" "Plot B"} {
            if {[implot::BeginPlot $title {x -1 y 250}]} {
                if {$linkx} {
                    implot::SetupAxisLinks ImAxis_X1 $lims(xmin) $lims(xmax)
                } else {
                    implot::SetupAxisLinks ImAxis_X1 NULL NULL
                }
                if {$linky} {
                    implot::SetupAxisLinks ImAxis_Y1 $lims(ymin) $lims(ymax)
                } else {
                    implot::SetupAxisLinks ImAxis_Y1 NULL NULL
                }
                implot::PlotLine_doublePtrInt "Line" $data 2
                implot::EndPlot
            }
        }
        implot::EndAlignedPlots
    }

    set values [lmap name {xmin xmax ymin ymax} {format %.3f [cffi::memory get $lims($name) double]}]
    imgui::Text "%s" [list string "Limits : X [lrange $values 0 1]  Y [lrange $values 2 3]"]
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
