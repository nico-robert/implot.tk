# Example from implot3d_demo.cpp
# void DemoMeshPlots()
# (the meshes are built here : sphere and cube)

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 600 -height 650

proc sphereMesh {rings sectors} {
    # UV sphere of radius 1.
    #
    # Returns {xs ys zs idxs}
    set pi [expr {acos(-1)}]
    set xs {} ; set ys {} ; set zs {}
    for {set r 0} {$r <= $rings} {incr r} {
        set phi [expr {$pi * $r / $rings}]
        for {set s 0} {$s <= $sectors} {incr s} {
            set theta [expr {2 * $pi * $s / $sectors}]
            lappend xs [expr {sin($phi) * cos($theta)}]
            lappend ys [expr {sin($phi) * sin($theta)}]
            lappend zs [expr {cos($phi)}]
        }
    }
    set idxs {}
    for {set r 0} {$r < $rings} {incr r} {
        for {set s 0} {$s < $sectors} {incr s} {
            set a [expr {$r * ($sectors + 1) + $s}]
            set b [expr {$a + $sectors + 1}]
            lappend idxs $a $b [expr {$a + 1}] [expr {$a + 1}] $b [expr {$b + 1}]
        }
    }
    return [list $xs $ys $zs $idxs]
}

proc cubeMesh {} {
    # Cube from -0.5 to 0.5 (8 vertices, 12 triangles).
    #
    # Returns {xs ys zs idxs}
    set xs {-0.5 0.5 0.5 -0.5 -0.5 0.5 0.5 -0.5}
    set ys {-0.5 -0.5 0.5 0.5 -0.5 -0.5 0.5 0.5}
    set zs {-0.5 -0.5 -0.5 -0.5 0.5 0.5 0.5 0.5}
    set idxs {
        0 1 2  0 2 3   4 5 6  4 6 7   0 1 5  0 5 4
        2 3 7  2 7 6   1 2 6  1 6 5   3 0 4  3 4 7
    }
    return [list $xs $ys $zs $idxs]
}

$f AddPlotCmd {
    implottk::static {
        set meshes {}
        foreach {name mesh} [list Sphere [sphereMesh 16 24] Cube [cubeMesh]] {
            lassign $mesh xs ys zs idxs
            dict set meshes $name [list \
                [implottk::doubleToPointer $xs] \
                [implottk::doubleToPointer $ys] \
                [implottk::doubleToPointer $zs] \
                [implottk::uintToPointer $idxs] \
                [llength $xs] [llength $idxs]]
        }
        set mesh_id 0
        set line_color   {0.5 0.5 0.2 0.6}
        set fill_color   {0.8 0.8 0.2 0.6}
        set marker_color {0.5 0.5 0.2 0.6}

        set names {}
        foreach name {NoLines NoFill NoMarkers} {
            lappend names $name [cffi::enum value ::implot3d::ImPlot3DMeshFlags_ \
                ImPlot3DMeshFlags_$name]
        }
        set flags [dict get $names NoMarkers]
    }

    imgui::Combo_Str_arr "Mesh" mesh_id [dict keys $meshes] [dict size $meshes]
    imgui::ColorEdit4 "Line Color##Mesh"   line_color
    imgui::ColorEdit4 "Fill Color##Mesh"   fill_color
    imgui::ColorEdit4 "Marker Color##Mesh" marker_color

    foreach {name value} $names {
        if {$name ne "NoLines"} {imgui::SameLine}
        imgui::CheckboxFlags_UintPtr $name flags $value
    }

    if {[implot3d::BeginPlot "Mesh Plots" {x -1 y -1}]} {
        implot3d::SetupAxesLimits -1 1 -1 1 -1 1

        set spec [list Flags $flags Marker ImPlot3DMarker_Square MarkerSize 3]
        foreach {field color} [list \
            LineColor $line_color FillColor $fill_color \
            MarkerLineColor $marker_color MarkerFillColor $marker_color] {
            lassign $color r g b a
            lappend spec $field [list x $r y $g z $b w $a]
        }
        set name [lindex [dict keys $meshes] $mesh_id]
        implot3d::PlotMesh_doublePtr $name {*}[dict get $meshes $name] $spec
        implot3d::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
