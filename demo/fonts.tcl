# Fonts with Dear ImGui 1.92 (dynamic fonts)

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

proc FindFont {names} {
    # Returns the first font file found, "" otherwise.
    set dirs {}
    if {[implottk::isWindows]} {
        lappend dirs [file join $::env(SystemRoot) fonts]
    } elseif {$::tcl_platform(os) eq "Darwin"} {
        lappend dirs /System/Library/Fonts/Supplemental /Library/Fonts /System/Library/Fonts
    } else {
        lappend dirs /usr/share/fonts/truetype/dejavu /usr/share/fonts/TTF \
                     /usr/share/fonts/dejavu /usr/share/fonts/truetype/freefont
    }
    foreach dir $dirs {
        foreach name $names {
            set file [file join $dir $name]
            if {[file exists $file]} {return $file}
        }
    }
    return ""
}

proc SansFont {} {
    # Returns the file of the default font ("" if not found).
    if {[implottk::isWindows]} {
        # The font of Tk (TkDefaultFont : Segoe UI).
        return [implottk::tkFontFile TkDefaultFont]
    }
    return [FindFont {Arial.ttf DejaVuSans.ttf FreeSans.ttf}]
}

set f [implottk::surface new]
$f SetOptions -width 700 -height 500

# Default font of the surface (the default ImGui font if not found).
if {[implottk::isWindows]} {
    # The font of Tk, at the size of Tk.
    $f SetOptions -fonts TkDefaultFont
} elseif {[SansFont] ne ""} {
    $f SetOptions -fonts [list [SansFont] 16]
}


$f AddGuiCmd {
    implottk::static {
        # Another font, loaded once (size 0 : the size is given by PushFont).
        set monoFile [FindFont {consola.ttf Courier\ New.ttf DejaVuSansMono.ttf FreeMono.ttf}]
        set mono NULL
        if {$monoFile ne ""} {
            set atlas [imgui::ImGuiIO getnative [imgui::GetIO_Nil] Fonts]
            set mono  [imgui::ImFontAtlas_AddFontFromFileTTF $atlas $monoFile]
        }
        set size 24.0
        set sans [SansFont]
    }

    imgui::Text "%s" [list string "Default font : [file tail $sans] ([imgui::GetFontSize] px)"]
    imgui::Text "%s" {string "UTF-8 : déjà été, ÆØÅ, €, ±, °C, µs"}

    imgui::SliderFloat "Size" size 8 72 "%.0f px"

    # Current font with another size.
    imgui::PushFont NULL $size
    imgui::Text "%s" {string "Current font, any size"}
    imgui::PopFont

    if {$mono ne "NULL"} {
        imgui::PushFont $mono $size
        imgui::Text "%s" [list string "[file tail $monoFile] : 0123456789"]
        imgui::PopFont
    }
}

$f AddPlotCmd {
    implottk::static {
        set xs {} ; set ys {}
        for {set i 0} {$i <= 100} {incr i} {
            lappend xs [expr {$i / 10.0}]
            lappend ys [expr {sin($i / 10.0)}]
        }
        set xs [implottk::doubleToPointer $xs]
        set ys [implottk::doubleToPointer $ys]
    }

    # ImPlot uses the current ImGui font.
    if {[implot::BeginPlot "Température (°C)" {x -1 y -1}]} {
        implot::SetupAxes "Temps (µs)" "Amplitude"
        implot::PlotLine_doublePtrdoublePtr "sin(x) — courbe" $xs $ys 101
        implot::EndPlot
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
