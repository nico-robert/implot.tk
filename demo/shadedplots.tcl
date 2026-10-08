# Example from implot_demo.cpp
# void Demo_ShadedPlots()

proc RandomRange {args} {

    set num [expr {rand()}]
    
	lassign $args lower upper
	set range [expr {$upper - $lower}]
    
	return [expr {double($num * $range) + $lower}]
}

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

# set frame
set f [implottk::surface new]
$f SetOptions -width 500 -height 400

# add options
$f SetOptions -color     {windowBackground {240 240 240} text {0 0 0}} \
           -colorPlot {legendBackground {240 240 240} frameBackground {240 240 240}} \
           -title "Shaded Plots"

# Windows font (optional)
if {[info exists ::env(SystemRoot)]} {
    set font [file join $::env(SystemRoot) fonts segoeui.ttf]
    if {[file exists $font]} {$f SetOptions -fonts [list $font 16]}
}


# add cmds 'Imgui' on the fly
$f AddGuiCmd {
    implottk::static {
        set alpha 0.25
        set len 1001

        set lxs {} ; set lys {} ; set ys1 {} ; set ys2 {} ; set ys3 {} ; set ys4 {}
        for {set i 0} {$i < $len} {incr i} {
            set x [expr {$i * 0.001}]
            set y [expr {0.25 + 0.25 * sin(25 * $x) * sin(5 * $x) + [RandomRange -0.01 0.01]}]
            lappend lxs $x
            lappend lys $y
            lappend ys1 [expr {$y + [RandomRange 0.1 0.12]}]
            lappend ys2 [expr {$y - [RandomRange 0.1 0.12]}]
            lappend ys3 [expr {0.75 + 0.2 * sin(25 * $x)}]
            lappend ys4 [expr {0.75 + 0.1 * sin(25 * $x)}]
        }

        # Transform data list Tcl to cffi memory.
        set xs  [implottk::doubleToPointer $lxs]
        set ys  [implottk::doubleToPointer $lys]
        set ys1 [implottk::doubleToPointer $ys1]
        set ys2 [implottk::doubleToPointer $ys2]
        set ys3 [implottk::doubleToPointer $ys3]
        set ys4 [implottk::doubleToPointer $ys4]
    }

    imgui::DragFloat "Alpha" alpha 0.01 0 1
}

# add cmds 'Implot' on the fly
$f AddPlotCmd {

    implot::PlotShaded_doublePtrdoublePtrdoublePtr "Uncertain Data" $xs $ys1 $ys2 $len [list FillAlpha $alpha]
    implot::PlotLine_doublePtrdoublePtr "Uncertain Data" $xs $ys $len
    implot::PlotShaded_doublePtrdoublePtrdoublePtr "Overlapping" $xs $ys3 $ys4 $len [list FillAlpha $alpha]
    implot::PlotLine_doublePtrdoublePtr "Overlapping" $xs $ys3 $len
    implot::PlotLine_doublePtrdoublePtr "Overlapping" $xs $ys4 $len

}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
