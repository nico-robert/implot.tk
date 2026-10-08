# Example from implot_demo.cpp
# void Demo_TimeScale()
# (without the "huge data" : one value per day of 2021)

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 750 -height 450

$f AddPlotCmd {
    implottk::static {
        set t_min 1609459200 ;# 01/01/2021 @ 12:00:00am (UTC)
        set t_max 1640995200 ;# 01/01/2022 @ 12:00:00am (UTC)

        set ts {} ; set ys {}
        for {set t $t_min} {$t <= $t_max} {incr t 86400} {
            lappend ts $t
            lappend ys [expr {0.5 + 0.25 * sin(($t - $t_min) / 2592000.0) + 0.05 * rand()}]
        }
        set count [llength $ts]
        set ts [implottk::doubleToPointer $ts]
        set ys [implottk::doubleToPointer $ys]

        # Fields of the ImPlotStyle of the current context.
        set style [implot::GetStyle]
        foreach field {UseLocalTime UseISO8601 Use24HourClock} {
            set $field [implot::ImPlotStyle getnative $style $field]
        }
        set now  [implottk::doubleToPointer {0}]
        set ynow [implottk::doubleToPointer {0.5}]
    }

    imgui::BulletText "%s" {string "When ImPlotScale_Time is set on the X-Axis, values are interpreted as\nUNIX timestamps in seconds and axis labels are formated as date/time."}
    imgui::BulletText "%s" {string "By default, labels are in UTC time but can be set to use local time instead."}

    # Checkbox changes the variable, written in the ImPlotStyle.
    foreach {field label} {UseLocalTime "Local Time" UseISO8601 "ISO 8601" Use24HourClock "24 Hour Clock"} {
        if {[imgui::Checkbox $label $field]} {
            implot::ImPlotStyle setnative $style $field [set $field]
        }
        if {$field ne "Use24HourClock"} {imgui::SameLine}
    }

    if {[implot::BeginPlot "##Time" {x -1 y -1}]} {
        implot::SetupAxisScale_PlotScale ImAxis_X1 ImPlotScale_Time
        implot::SetupAxesLimits $t_min $t_max 0 1
        implot::PlotLine_doublePtrdoublePtr "Time Series" $ts $ys $count

        # plot time now
        implottk::updatePointer $now [list [clock seconds]]
        implot::PlotScatter_doublePtrdoublePtr "Now" $now $ynow 1
        implot::Annotation_Str [clock seconds] 0.5 [implot::GetLastItemColor] {x 10 y 10} 0 "Now"
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
