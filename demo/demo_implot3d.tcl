# Demo implot3d with all plots

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 600 -height 500

# Animations : the surface is rendered all the time (60 frames per second).
$f SetOptions -idleFps 60

$f AddGuiCmd {
    # The demo is a window inside the surface window.
    if {[imgui::IsWindowFocused]} {
        imgui::SetNextWindowFocus
    }

    # Demo implot3d...
    implot3d::ShowDemoWindow
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
