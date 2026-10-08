# Data added as they come !

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

namespace eval ::acquisition {
    variable xs       {}  ; # C array (x)
    variable ys       {}  ; # C array (y)
    variable count    0   ; # number of points
    variable capacity 0   ; # size of the arrays
    variable value    0.0 ; # last value
    variable afterId  {}
    variable surface  {}
    variable t0       [clock milliseconds]
}

proc ::acquisition::add {x y} {
    # Adds a point to the arrays (they are reallocated twice as big when
    # they are full).
    variable xs
    variable ys
    variable count
    variable capacity

    if {$count == $capacity} {
        set capacity [expr {max(1024, 2 * $capacity)}]
        foreach var {xs ys} {
            set old [set $var]
            set values {}
            if {$count} {
                set values [cffi::memory get $old double\[$count\]]
                cffi::memory free $old
            }
            set $var [cffi::memory new double\[$capacity\] $values ::implot::double]
        }
    }
    cffi::memory set $xs double $x $count
    cffi::memory set $ys double $y $count
    incr count
}

proc ::acquisition::clear {} {
    variable count 0
}

proc ::acquisition::tick {period} {
    # A new point (random walk) every 'period' ms.
    variable value
    variable afterId
    variable surface
    variable t0

    set value [expr {$value + rand() - 0.5}]
    add [expr {([clock milliseconds] - $t0) / 1000.0}] $value
    # Render on demand : a new frame shows the new point.
    $surface redraw
    set afterId [after $period [list ::acquisition::tick $period]]
}

proc ::acquisition::start {period} {
    variable afterId
    stop
    set afterId [after $period [list ::acquisition::tick $period]]
}

proc ::acquisition::stop {} {
    variable afterId
    after cancel $afterId
    set afterId {}
}

proc ::acquisition::running {} {
    variable afterId
    return [expr {$afterId ne ""}]
}

set f [implottk::surface new]
$f SetOptions -width 800 -height 450

set ::acquisition::surface $f
::acquisition::start 50

$f AddPlotCmd {
    implottk::static {
        set period 50
        set follow 1
        set history 10.0
    }

    if {[::acquisition::running]} {
        if {[imgui::Button "Stop" {x 80 y 0}]} {::acquisition::stop}
    } else {
        if {[imgui::Button "Start" {x 80 y 0}]} {::acquisition::start $period}
    }
    imgui::SameLine
    if {[imgui::Button "Add a point" {x 0 y 0}]} {
        ::acquisition::tick 0
        ::acquisition::stop
    }
    imgui::SameLine
    if {[imgui::Button "Clear" {x 0 y 0}]} {::acquisition::clear}
    imgui::SameLine
    imgui::SetNextItemWidth 150
    if {[imgui::SliderInt "Period (ms)" period 10 500]} {
        if {[::acquisition::running]} {::acquisition::start $period}
    }
    imgui::SameLine
    imgui::Checkbox "Follow" follow
    imgui::SameLine
    imgui::SetNextItemWidth 150
    imgui::SliderFloat "History (s)" history 1 60 "%.0f s"

    set n $::acquisition::count
    imgui::Text "%d points" [list int $n]

    if {[implot::BeginPlot "##Acquisition" {x -1 y -1}]} {
        # y : fitted on the visible points.
        implot::SetupAxes "time (s)" "value" 0 {ImPlotAxisFlags_AutoFit ImPlotAxisFlags_RangeFit}
        if {$n && $follow} {
            # The last 'history' seconds.
            set last [cffi::memory get $::acquisition::xs double [expr {$n - 1}]]
            implot::SetupAxisLimits ImAxis_X1 [expr {$last - $history}] $last ImPlotCond_Always
        }
        if {$n} {
            implot::PlotLine_doublePtrdoublePtr "signal" $::acquisition::xs $::acquisition::ys $n
        }
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
