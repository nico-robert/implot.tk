# Example from implot_demo.cpp
# void Demo_DigitalPlots()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 700 -height 450

# Data changed at each frame : the surface is rendered all the time.
$f SetOptions -idleFps 60

$f AddPlotCmd {
    implottk::static {
        set paused 0
        set maxSize 2000
        # Scrolling buffers : names, shown, x, y and arrays of the plot.
        set signals {digital_0 digital_1 digital_2 analog_0 analog_1}
        foreach name $signals visible {1 0 0 1 0} {
            set show($name) $visible
            set xs($name) {}
            set ys($name) {}
            set px($name) [implottk::doubleToPointer [lrepeat $maxSize 0.0]]
            set py($name) [implottk::doubleToPointer [lrepeat $maxSize 0.0]]
        }
        set t 0.0
        set last_t 0.0
    }

    imgui::BulletText "%s" {string "Digital plots do not respond to Y drag and zoom, so that"}
    imgui::Indent
    imgui::Text "%s" {string "you can drag analog plots over the rising/falling digital edge."}
    imgui::Unindent

    imgui::Checkbox "Pause" paused
    foreach name $signals {
        imgui::Checkbox $name show($name)
        if {$name ne "analog_1"} {imgui::SameLine}
    }

    if {!$paused} {
        set t [expr {$t + [imgui::ImGuiIO getnative [imgui::GetIO_Nil] DeltaTime]}]
        if {$t - $last_t >= 0.01} {
            set last_t $t
            set values [dict create \
                digital_0 [expr {sin(2 * $t) > 0.45}] \
                digital_1 [expr {sin(2 * $t) < 0.45}] \
                digital_2 [expr {sin(50 * $t) > 0.5}] \
                analog_0  [expr {sin(2 * $t)}] \
                analog_1  [expr {cos(2 * $t)}]]
            foreach name $signals {
                if {!$show($name)} continue
                lappend xs($name) $t
                lappend ys($name) [dict get $values $name]
                if {[llength $xs($name)] > $maxSize} {
                    set xs($name) [lrange $xs($name) 1 end]
                    set ys($name) [lrange $ys($name) 1 end]
                }
                implottk::updatePointer $px($name) $xs($name)
                implottk::updatePointer $py($name) $ys($name)
            }
        }
    }

    if {[implot::BeginPlot "##Digital" {x -1 y -1}]} {
        implot::SetupAxisLimits ImAxis_X1 [expr {$t - 10.0}] $t \
            [expr {$paused ? "ImPlotCond_Once" : "ImPlotCond_Always"}]
        implot::SetupAxisLimits ImAxis_Y1 -1 1
        set i 0
        foreach name {digital_0 digital_1 digital_2} {
            incr i
            if {$show($name) && [llength $xs($name)]} {
                implot::PlotDigital_doublePtr $name $px($name) $py($name) [llength $xs($name)] \
                    [list Size [expr {$i * 4}]]
            }
        }
        foreach name {analog_0 analog_1} {
            if {$show($name) && [llength $xs($name)]} {
                implot::PlotLine_doublePtrdoublePtr $name $px($name) $py($name) [llength $xs($name)]
            }
        }
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
