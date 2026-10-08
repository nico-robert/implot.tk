# Several implottk surfaces in the same application :
# each surface has its own ImGui / ImPlot contexts.

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

# Each surface has its own variables (implottk::static).
set f1 [implottk::surface new]
$f1 SetOptions -width 500 -height 300
$f1 SetOptions -title "Surface 1" -axisName {x sin(x)}
$f1 AddPlotCmd {
    implottk::static {
        set len 200
        set xs [implottk::doubleToPointer [lmap i [lseq $len] {expr {$i / 20.0}}]]
        set ys [implottk::doubleToPointer [lmap i [lseq $len] {expr {sin($i / 20.0)}}]]
    }
    implot::PlotLine_doublePtrdoublePtr "sin" $xs $ys $len
}

set f2 [implottk::surface new]
$f2 SetOptions -width 500 -height 300
$f2 SetOptions -title "Surface 2" -axisName {x cos(x)} -background {240 240 240}
$f2 AddPlotCmd {
    implottk::static {
        set len 200
        set xs [implottk::doubleToPointer [lmap i [lseq $len] {expr {$i / 20.0}}]]
        set ys [implottk::doubleToPointer [lmap i [lseq $len] {expr {cos($i / 20.0)}}]]
    }
    implot::PlotShaded_doublePtrdoublePtrInt "cos" $xs $ys $len 0 {FillAlpha 0.4}
}

# Creates the Tk widgets of the surfaces and shows them.
pack [$f1 Render] -fill both -expand 1
pack [$f2 Render] -fill both -expand 1
