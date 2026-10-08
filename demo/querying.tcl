# Example from implot_demo.cpp
# void Demo_Querying()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 650 -height 550

proc FindCentroid {xs ys rect} {
    # Returns {x y count} : centroid of the points inside rect (ImPlotRect).
    set X [dict get $rect X] ; set Y [dict get $rect Y]
    set sx 0.0 ; set sy 0.0 ; set n 0
    foreach x $xs y $ys {
        if {$x >= [dict get $X Min] && $x <= [dict get $X Max] &&
            $y >= [dict get $Y Min] && $y <= [dict get $Y Max]} {
            set sx [expr {$sx + $x}] ; set sy [expr {$sy + $y}] ; incr n
        }
    }
    if {$n == 0} {return {0 0 0}}
    return [list [expr {$sx / $n}] [expr {$sy / $n}] $n]
}

$f AddPlotCmd {
    implottk::static {
        set xs {} ; set ys {}
        for {set i 0} {$i < 50} {incr i} {
            lappend xs [expr {0.1 + 0.8 * rand()}]
            lappend ys [expr {0.1 + 0.8 * rand()}]
        }
        set maxPoints 1000
        set pxs [implottk::doubleToPointer [lrepeat $maxPoints 0.0]]
        set pys [implottk::doubleToPointer [lrepeat $maxPoints 0.0]]
        set cx  [implottk::doubleToPointer {0}]
        set cy  [implottk::doubleToPointer {0}]
        # Query rects : list of {xmin ymin xmax ymax}
        set rects {}
        set io [imgui::GetIO_Nil]
    }

    imgui::BulletText "%s" {string "Box select (right drag) and left click to create a new query rect."}
    imgui::BulletText "%s" {string "Ctrl + click in the plot area to draw points."}

    if {[imgui::Button "Clear Queries" {x 0 y 0}]} {set rects {}}

    if {[implot::BeginPlot "##Centroid" {x -1 y -1}]} {
        implot::SetupAxesLimits 0 1 0 1

        if {[implot::IsPlotHovered] && [imgui::IsMouseClicked_Bool ImGuiMouseButton_Left] &&
            [imgui::ImGuiIO getnative $io KeyCtrl] && [llength $xs] < $maxPoints} {
            set pt [implot::GetPlotMousePos]
            lappend xs [dict get $pt x]
            lappend ys [dict get $pt y]
        }

        implottk::updatePointer $pxs $xs
        implottk::updatePointer $pys $ys
        implot::PlotScatter_doublePtrdoublePtr "Points" $pxs $pys [llength $xs]

        set cent_spec {Marker ImPlotMarker_Square MarkerSize 6}
        if {[implot::IsPlotSelected]} {
            set select [implot::GetPlotSelection]
            lassign [FindCentroid $xs $ys $select] x y cnt
            if {$cnt > 0} {
                implottk::updatePointer $cx [list $x] ; implottk::updatePointer $cy [list $y]
                implot::PlotScatter_doublePtrdoublePtr "Centroid" $cx $cy 1 $cent_spec
            }
            # Left click : the selection becomes a query rect.
            if {[imgui::IsMouseClicked_Bool ImGuiMouseButton_Left]} {
                implot::CancelPlotSelection
                lappend rects [list [dict get $select X Min] [dict get $select Y Min] \
                                    [dict get $select X Max] [dict get $select Y Max]]
            }
        }

        # Query rects : DragRect needs variables, one per corner.
        for {set i 0} {$i < [llength $rects]} {incr i} {
            lassign [lindex $rects $i] xmin ymin xmax ymax
            lassign [FindCentroid $xs $ys [list X [list Min $xmin Max $xmax] Y [list Min $ymin Max $ymax]]] x y cnt
            if {$cnt > 0} {
                implottk::updatePointer $cx [list $x] ; implottk::updatePointer $cy [list $y]
                implot::PlotScatter_doublePtrdoublePtr "Centroid" $cx $cy 1 $cent_spec
            }
            implot::DragRect $i xmin ymin xmax ymax {x 1 y 0 z 1 w 1} 0 clicked hovered held
            lset rects $i [list $xmin $ymin $xmax $ymax]
        }

        set limits [implot::GetPlotLimits]
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
