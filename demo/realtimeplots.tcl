# Example from implot_demo.cpp
# void Demo_RealtimePlots()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 700 -height 450

# Data changed at each frame : the surface is rendered all the time.
$f SetOptions -idleFps 60

$f AddPlotCmd {
    implottk::static {
        # Scrolling buffers (the last 2000 points) and rolling buffers
        # (x modulo 'history').
        set maxSize 2000
        set sx {} ; set sy1 {} ; set sy2 {}
        set rx {} ; set ry1 {} ; set ry2 {}
        foreach name {sx sy1 sy2 rx ry1 ry2} {
            set ptr($name) [implottk::doubleToPointer [lrepeat $maxSize 0.0]]
        }
        set t0      [imgui::GetTime]
        set last_t  -1
        set history 10.0
        set flags   ImPlotAxisFlags_NoTickLabels
    }

    imgui::BulletText "%s" {string "Move your mouse to change the data!"}

    set mouse [imgui::GetMousePos]
    set t [expr {[imgui::GetTime] - $t0}]

    # Add points to the buffers every 0.02 seconds
    if {$last_t < 0 || $t - $last_t >= 0.02} {
        set mx [expr {[dict get $mouse x] * 0.0005}]
        set my [expr {[dict get $mouse y] * 0.0005}]

        lappend sx $t ; lappend sy1 $mx ; lappend sy2 $my
        if {[llength $sx] > $maxSize} {
            set sx  [lrange $sx  1 end]
            set sy1 [lrange $sy1 1 end]
            set sy2 [lrange $sy2 1 end]
        }

        set xmod [expr {fmod($t, $history)}]
        if {[llength $rx] && $xmod < [lindex $rx end]} {
            set rx {} ; set ry1 {} ; set ry2 {}
        }
        lappend rx $xmod ; lappend ry1 $mx ; lappend ry2 $my
        if {[llength $rx] > $maxSize} {
            set rx  [lrange $rx  1 end]
            set ry1 [lrange $ry1 1 end]
            set ry2 [lrange $ry2 1 end]
        }

        foreach name {sx sy1 sy2 rx ry1 ry2} {
            implottk::updatePointer $ptr($name) [set $name]
        }
        set last_t $t
    }

    imgui::SliderFloat "History" history 1 30 "%.1f s"

    set height [expr {[imgui::GetTextLineHeight] * 10}]

    if {[implot::BeginPlot "##Scrolling" [list x -1 y $height]]} {
        implot::SetupAxes "" "" $flags $flags
        implot::SetupAxisLimits ImAxis_X1 [expr {$t - $history}] $t ImPlotCond_Always
        implot::SetupAxisLimits ImAxis_Y1 0 1
        implot::PlotShaded_doublePtrdoublePtrInt "Mouse X" $ptr(sx) $ptr(sy1) [llength $sx] -Inf {FillAlpha 0.5}
        implot::PlotLine_doublePtrdoublePtr "Mouse Y" $ptr(sx) $ptr(sy2) [llength $sx]
        implot::EndPlot
    }

    if {[implot::BeginPlot "##Rolling" [list x -1 y $height]]} {
        implot::SetupAxes "" "" $flags $flags
        implot::SetupAxisLimits ImAxis_X1 0 $history ImPlotCond_Always
        implot::SetupAxisLimits ImAxis_Y1 0 1
        implot::PlotLine_doublePtrdoublePtr "Mouse X" $ptr(rx) $ptr(ry1) [llength $rx]
        implot::PlotLine_doublePtrdoublePtr "Mouse Y" $ptr(rx) $ptr(ry2) [llength $rx]
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
