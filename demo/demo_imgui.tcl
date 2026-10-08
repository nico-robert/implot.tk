# Demo imgui with all widgets

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

set f [implottk::surface new]
$f SetOptions -width 500 -height 400

# Animations : the surface is rendered all the time (60 frames per second).
$f SetOptions -idleFps 60

$f AddGuiCmd {

    # special case for demo 'imgui'
    # in this cas I'm not fullscreen!
    if {[imgui::IsWindowFocused]} {
        imgui::SetNextWindowFocus
    }
    # Demo imgui...
    imgui::ShowDemoWindow
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
