# Example from implot_demo.cpp
# void Demo_Annotations()
# void Demo_Tags()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 650 -height 650

$f AddPlotCmd {
    implottk::static {
        set clamp 0
        set px [implottk::doubleToPointer {0.25 0.75 0.75 0.25}]
        set py [implottk::doubleToPointer {0.25 0.25 0.75 0.75}]
        set bx {1.2 1.5 1.8}
        set by {0.25 0.5 0.75}
        set bxs [implottk::doubleToPointer $bx]
        set bys [implottk::doubleToPointer $by]

        set show 1
        set drag_tag 0.25
    }

    # Annotations
    imgui::Checkbox "Clamp" clamp

    if {[implot::BeginPlot "##Annotations" {x -1 y 300}]} {
        implot::SetupAxesLimits 0 2 0 1
        implot::PlotScatter_doublePtrdoublePtr "##Points" $px $py 4
        set col [implot::GetLastItemColor]
        implot::Annotation_Str 0.25 0.25 $col {x -15 y 15}  $clamp "BL"
        implot::Annotation_Str 0.75 0.25 $col {x 15 y 15}   $clamp "BR"
        implot::Annotation_Str 0.75 0.75 $col {x 15 y -15}  $clamp "TR"
        implot::Annotation_Str 0.25 0.75 $col {x -15 y -15} $clamp "TL"
        implot::Annotation_Str 0.5  0.5  $col {x 0 y 0}     $clamp "Center"

        # Annotation with the value (no text).
        implot::Annotation_Bool 1.25 0.75 {x 0 y 1 z 0 w 1} {x 0 y 0} $clamp

        implot::PlotBars_doublePtrdoublePtr "##Bars" $bxs $bys 3 0.2
        for {set i 0} {$i < 3} {incr i} {
            implot::Annotation_Str [lindex $bx $i] [lindex $by $i] {x 0 y 0 z 0 w 0} {x 0 y -5} $clamp \
                "B\[%d\]=%.2f" [list int $i] [list double [lindex $by $i]]
        }
        implot::EndPlot
    }

    # Tags
    imgui::Checkbox "Show Tags" show

    if {[implot::BeginPlot "##Tags" {x -1 y -1}]} {
        implot::SetupAxis ImAxis_X2
        implot::SetupAxis ImAxis_Y2
        if {$show} {
            implot::TagX_Bool 0.25 {x 1 y 1 z 0 w 1}
            implot::TagY_Bool 0.75 {x 1 y 1 z 0 w 1}
            implot::DragLineY 0 drag_tag {x 1 y 0 z 0 w 1} 1 ImPlotDragToolFlags_NoFit
            implot::TagY_Str $drag_tag {x 1 y 0 z 0 w 1} "Drag"
            implot::SetAxes ImAxis_X2 ImAxis_Y2
            implot::TagX_Str 0.5 {x 0 y 1 z 1 w 1} "%s" {string "MyTag"}
            implot::TagY_Str 0.5 {x 0 y 1 z 1 w 1} "Tag: %d" {int 42}
        }
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
