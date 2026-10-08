# Example from implot3d_demo.cpp
# void DemoSurfacePlots()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 700 -height 700

# Animation : the surface is rendered all the time.
$f SetOptions -idleFps 60

$f AddPlotCmd {
    implottk::static {
        set N 20
        set min_val -1.0
        set max_val  1.0
        set step [expr {($max_val - $min_val) / ($N - 1)}]
        set xs {} ; set ys {}
        for {set i 0} {$i < $N} {incr i} {
            for {set j 0} {$j < $N} {incr j} {
                lappend xs [expr {$min_val + $j * $step}]
                lappend ys [expr {$min_val + $i * $step}]
            }
        }
        set pxs [implottk::doubleToPointer $xs]
        set pys [implottk::doubleToPointer $ys]
        set pzs [implottk::doubleToPointer $xs]
        # Custom per-point colors (ImU32), updated with z.
        set colors [implottk::uintToPointer [lrepeat [expr {$N * $N}] 0]]

        set selected_fill 1
        set solid_color {0.8 0.8 0.2 0.6}
        set colormaps {
            Viridis Plasma Hot Cool Pink Jet Twilight RdBu BrBG PiYG Spectral Greys
        }
        set sel_colormap 5
        set custom_range 0
        set range_min -1.0
        set range_max  1.0

        set names {}
        foreach name {NoLines NoFill NoMarkers} {
            lappend names $name [cffi::enum value ::implot3d::ImPlot3DSurfaceFlags_ \
                ImPlot3DSurfaceFlags_$name]
        }
        set flags [dict get $names NoMarkers]
    }

    # z = sin(2t + sqrt(x^2 + y^2))
    set t [imgui::GetTime]
    set zs {} ; set cols {}
    foreach x $xs y $ys {
        set z [expr {sin(2 * $t + sqrt($x * $x + $y * $y))}]
        lappend zs $z
        # IM_COL32(R=x, G=y, B=z, 255) : 0xAABBGGRR
        lappend cols [expr {
            (255 << 24) | (int(($z + 1) * 127.5) << 16) |
            (int(($y + 1) * 127.5) << 8) | int(($x + 1) * 127.5)
        }]
    }
    implottk::updatePointer $pzs $zs
    cffi::memory set $colors uint\[[llength $cols]\] $cols

    imgui::Text "Fill color"
    imgui::Indent
    imgui::RadioButton_IntPtr "Solid" selected_fill 0
    if {$selected_fill == 0} {
        imgui::SameLine
        imgui::ColorEdit4 "##SurfaceSolidColor" solid_color
    }
    imgui::RadioButton_IntPtr "Colormap" selected_fill 1
    if {$selected_fill == 1} {
        imgui::SameLine
        imgui::Combo_Str_arr "##SurfaceColormap" sel_colormap $colormaps [llength $colormaps]
    }
    imgui::RadioButton_IntPtr "Custom Per-Point" selected_fill 2
    if {$selected_fill == 2} {
        imgui::SameLine
        imgui::TextDisabled "R=x, G=y, B=z"
    }
    imgui::Unindent

    # Range : only for the colormap.
    imgui::BeginDisabled [expr {$selected_fill != 1}]
    imgui::Checkbox "Custom range" custom_range
    imgui::Indent
    imgui::BeginDisabled [expr {!$custom_range}]
    imgui::SliderFloat "Range min" range_min -1.0 [expr {$range_max - 0.01}]
    imgui::SliderFloat "Range max" range_max [expr {$range_min + 0.01}] 1.0
    imgui::EndDisabled
    imgui::Unindent
    imgui::EndDisabled

    foreach {name value} $names {
        if {$name ne "NoLines"} {imgui::SameLine}
        imgui::CheckboxFlags_UintPtr $name flags $value
    }

    if {$selected_fill == 1} {
        implot3d::PushColormap_Str [lindex $colormaps $sel_colormap]
    }
    if {[implot3d::BeginPlot "Surface Plots" {x -1 y -1} ImPlot3DFlags_NoClip]} {
        implot3d::SetupAxesLimits -1 1 -1 1 -1.5 1.5

        set spec [list \
            FillAlpha 0.8 \
            Flags     $flags \
            Marker    ImPlot3DMarker_Square \
            LineColor [implot3d::GetColormapColor 1]]
        if {$selected_fill == 0} {
            lassign $solid_color r g b a
            lappend spec FillColor [list x $r y $g z $b w $a]
        } elseif {$selected_fill == 2} {
            lappend spec FillColors $colors
        }

        if {$custom_range} {
            implot3d::PlotSurface_doublePtr "Wave Surface" $pxs $pys $pzs $N $N \
                $range_min $range_max $spec
        } else {
            implot3d::PlotSurface_doublePtr "Wave Surface" $pxs $pys $pzs $N $N 0 0 $spec
        }
        implot3d::EndPlot
    }
    if {$selected_fill == 1} {
        implot3d::PopColormap
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
