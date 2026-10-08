# Example from implot3d_demo.cpp
# void DemoTrianglePlots()
# void DemoQuadPlots()

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 900 -height 500

$f AddPlotCmd {
    implottk::static {
        # Pyramid : 6 triangles (4 sides + 2 for the base), 3 vertices each.
        set apex {0 0 1}
        set c0 {-0.5 -0.5 0} ; set c1 {0.5 -0.5 0}
        set c2 {0.5 0.5 0}   ; set c3 {-0.5 0.5 0}
        set triangles [list \
            $apex $c0 $c1  $apex $c1 $c2  $apex $c2 $c3  $apex $c3 $c0 \
            $c0 $c1 $c2    $c0 $c2 $c3]
        set txs {} ; set tys {} ; set tzs {}
        foreach p $triangles {
            lassign $p x y z
            lappend txs $x ; lappend tys $y ; lappend tzs $z
        }
        set txs [implottk::doubleToPointer $txs]
        set tys [implottk::doubleToPointer $tys]
        set tzs [implottk::doubleToPointer $tzs]

        # Cube : 2 faces (4 vertices each) per axis.
        set faces {
            X {{1 -1 -1} {1 1 -1} {1 1 1} {1 -1 1}  {-1 -1 -1} {-1 1 -1} {-1 1 1} {-1 -1 1}}
            Y {{-1 1 -1} {1 1 -1} {1 1 1} {-1 1 1}  {-1 -1 -1} {1 -1 -1} {1 -1 1} {-1 -1 1}}
            Z {{-1 -1 1} {1 -1 1} {1 1 1} {-1 1 1}  {-1 -1 -1} {1 -1 -1} {1 1 -1} {-1 1 -1}}
        }
        set quads {}
        foreach {axis vertices} $faces {
            set qxs {} ; set qys {} ; set qzs {}
            foreach p $vertices {
                lassign $p x y z
                lappend qxs $x ; lappend qys $y ; lappend qzs $z
            }
            dict set quads $axis [list \
                [implottk::doubleToPointer $qxs] \
                [implottk::doubleToPointer $qys] \
                [implottk::doubleToPointer $qzs]]
        }
        set colors {
            X {x 0.8 y 0.2 z 0.2 w 0.8}
            Y {x 0.2 y 0.8 z 0.2 w 0.8}
            Z {x 0.2 y 0.2 z 0.8 w 0.8}
        }

        # Same values for the ImPlot3DQuadFlags_ (NoLines, NoFill, NoMarkers).
        set flags 0
        set names {}
        foreach name {NoLines NoFill NoMarkers} {
            lappend names $name [cffi::enum value ::implot3d::ImPlot3DTriangleFlags_ \
                ImPlot3DTriangleFlags_$name]
        }
    }

    foreach {name value} $names {
        if {$name ne "NoLines"} {imgui::SameLine}
        imgui::CheckboxFlags_UintPtr $name flags $value
    }

    set size [imgui::GetContentRegionAvail]
    set w [expr {[dict get $size x] / 2 - 4}]

    if {[implot3d::BeginPlot "Triangle Plots" [list x $w y -1]]} {
        implot3d::SetupAxesLimits -1 1 -1 1 -0.5 1.5
        implot3d::PlotTriangle_doublePtr "Pyramid" $txs $tys $tzs 18 [list \
            FillColor  [implot3d::GetColormapColor 0] \
            LineColor  [implot3d::GetColormapColor 1] \
            Marker     ImPlot3DMarker_Square \
            MarkerSize 3 \
            Flags      $flags]
        implot3d::EndPlot
    }

    imgui::SameLine

    if {[implot3d::BeginPlot "Quad Plots" {x -1 y -1}]} {
        implot3d::SetupAxesLimits -1.5 1.5 -1.5 1.5 -1.5 1.5
        foreach {axis data} $quads {
            set color [dict get $colors $axis]
            implot3d::PlotQuad_doublePtr $axis {*}$data 8 [list \
                FillColor  $color \
                LineColor  $color \
                Marker     ImPlot3DMarker_Square \
                MarkerSize 3 \
                Flags      $flags]
        }
        implot3d::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
