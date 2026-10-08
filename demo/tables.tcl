# Example from implot_demo.cpp
# void Demo_Tables()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

proc Sparkline {id values count min_v max_v offset col size} {
    # Plots 'values' (pointer.double) without decorations, from index
    # 'offset' (ImPlotSpec Offset).
    implot::PushStyleVar_Vec2 ImPlotStyleVar_PlotPadding {x 0 y 0}

    if {[implot::BeginPlot $id $size ImPlotFlags_CanvasOnly]} {
        implot::SetupAxes "" "" ImPlotAxisFlags_NoDecorations ImPlotAxisFlags_NoDecorations
        implot::SetupAxesLimits 0 [expr {$count - 1}] $min_v $max_v ImPlotCond_Always
        implot::PlotLine_doublePtrInt $id $values $count 1 0 \
            [list LineColor $col Offset $offset]
        implot::PlotShaded_doublePtrInt $id $values $count 0 1 0 \
            [list FillColor $col FillAlpha 0.25 Offset $offset]
        implot::EndPlot
    }

    implot::PopStyleVar
}

set f [implottk::surface new]
$f SetOptions -width 800 -height 600

# Animations : the surface is rendered all the time (60 frames per second).
$f SetOptions -idleFps 60

$f AddGuiCmd {
    implottk::static {
        set flags {
            ImGuiTableFlags_BordersOuter ImGuiTableFlags_BordersV ImGuiTableFlags_RowBg
            ImGuiTableFlags_Resizable ImGuiTableFlags_Reorderable
        }
        set anim   1
        set offset 0
        set pos    0.0

        # 100 random values per row, created once (the C++ demo creates
        # the same values at each frame with srand(row)).
        expr {srand(0)}
        for {set row 0} {$row < 10} {incr row} {
            set values {}
            for {set i 0} {$i < 100} {incr i} {lappend values [expr {10 * rand()}]}
            set data($row) $values
            set ptr($row)  [implottk::doubleToPointer $values]
        }
    }

    imgui::BulletText "%s" {string "Plots can be used inside of ImGui tables as another means of creating subplots."}
    imgui::Checkbox "Animate" anim

    # 60 values per second, whatever the number of frames per second
    # (DeltaTime : time since the previous frame).
    if {$anim} {
        set dt  [imgui::ImGuiIO getnative [imgui::GetIO_Nil] DeltaTime]
        set pos [expr {fmod($pos + 60 * $dt, 100)}]
        set offset [expr {int($pos)}]
    }

    if {[imgui::BeginTable "##table" 3 $flags {x -1 y -1}]} {
        imgui::TableSetupColumn "Electrode" ImGuiTableColumnFlags_WidthFixed 75.0
        imgui::TableSetupColumn "Voltage"   ImGuiTableColumnFlags_WidthFixed 75.0
        imgui::TableSetupColumn "EMG Signal"
        imgui::TableHeadersRow

        implot::PushColormap_PlotColormap ImPlotColormap_Cool

        for {set row 0} {$row < 10} {incr row} {
            imgui::TableNextRow
            imgui::TableSetColumnIndex 0
            imgui::Text "EMG %d" [list int $row]
            imgui::TableSetColumnIndex 1
            imgui::Text "%.3f V" [list double [lindex $data($row) $offset]]
            imgui::TableSetColumnIndex 2
            imgui::PushID_Int $row
            Sparkline "##spark" $ptr($row) 100 0 11.0 $offset [implot::GetColormapColor $row] {x -1 y 35}
            imgui::PopID
        }

        implot::PopColormap
        imgui::EndTable
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
