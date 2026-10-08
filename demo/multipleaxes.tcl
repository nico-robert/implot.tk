# Example from implot_demo.cpp
# void Demo_MultipleAxes()
# void Demo_AxisConstraints()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 700 -height 700

$f AddPlotCmd {
    implottk::static {
        set xs {} ; set xs2 {} ; set ys1 {} ; set ys2 {} ; set ys3 {}
        for {set i 0} {$i < 1001} {incr i} {
            set x [expr {$i * 0.1}]
            lappend xs  $x
            lappend xs2 [expr {$x + 10.0}]
            lappend ys1 [expr {sin($x) * 3 + 1}]
            lappend ys2 [expr {cos($x) * 0.2 + 0.5}]
            lappend ys3 [expr {sin($x + 0.5) * 100 + 200}]
        }
        foreach name {xs xs2 ys1 ys2 ys3} {set $name [implottk::doubleToPointer [set $name]]}

        set x2_axis 1 ; set y2_axis 1 ; set y3_axis 1

        # Axis constraints
        set limits {-10 10}
        set zoom   {1 20}
        set cflags 0
    }

    # Multiple axes
    imgui::Checkbox "X-Axis 2" x2_axis ; imgui::SameLine
    imgui::Checkbox "Y-Axis 2" y2_axis ; imgui::SameLine
    imgui::Checkbox "Y-Axis 3" y3_axis

    imgui::BulletText "%s" {string "You can drag axes to the opposite side of the plot."}
    imgui::BulletText "%s" {string "Hover over legend items to see which axis they are plotted on."}

    if {[implot::BeginPlot "Multi-Axis Plot" {x -1 y 350}]} {
        implot::SetupAxes "X-Axis 1" "Y-Axis 1"
        implot::SetupAxesLimits 0 100 0 10
        if {$x2_axis} {
            implot::SetupAxis ImAxis_X2 "X-Axis 2" ImPlotAxisFlags_AuxDefault
            implot::SetupAxisLimits ImAxis_X2 0 100
        }
        if {$y2_axis} {
            implot::SetupAxis ImAxis_Y2 "Y-Axis 2" ImPlotAxisFlags_AuxDefault
            implot::SetupAxisLimits ImAxis_Y2 0 1
        }
        if {$y3_axis} {
            implot::SetupAxis ImAxis_Y3 "Y-Axis 3" ImPlotAxisFlags_AuxDefault
            implot::SetupAxisLimits ImAxis_Y3 0 300
        }

        implot::PlotLine_doublePtrdoublePtr "f(x) = x" $xs $xs 1001
        if {$x2_axis} {
            implot::SetAxes ImAxis_X2 ImAxis_Y1
            implot::PlotLine_doublePtrdoublePtr "f(x) = sin(x)*3+1" $xs2 $ys1 1001
        }
        if {$y2_axis} {
            implot::SetAxes ImAxis_X1 ImAxis_Y2
            implot::PlotLine_doublePtrdoublePtr "f(x) = cos(x)*.2+.5" $xs $ys2 1001
        }
        if {$x2_axis && $y3_axis} {
            implot::SetAxes ImAxis_X2 ImAxis_Y3
            implot::PlotLine_doublePtrdoublePtr "f(x) = sin(x+.5)*100+200" $xs2 $ys3 1001
        }
        implot::EndPlot
    }

    # Axis constraints
    imgui::DragFloat2 "Limits Constraints" limits 0.01
    imgui::DragFloat2 "Zoom Constraints"   zoom   0.01
    # ImPlotAxisFlags_PanStretch = 8192
    imgui::CheckboxFlags_UintPtr "ImPlotAxisFlags_PanStretch" cflags 8192

    if {[implot::BeginPlot "##AxisConstraints" {x -1 y -1}]} {
        implot::SetupAxes "X" "Y" $cflags $cflags
        implot::SetupAxesLimits -1 1 -1 1
        foreach axis {ImAxis_X1 ImAxis_Y1} {
            implot::SetupAxisLimitsConstraints $axis {*}$limits
            implot::SetupAxisZoomConstraints   $axis {*}$zoom
        }
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
