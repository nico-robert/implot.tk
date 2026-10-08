# Copyright (c) 2022-2026 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

# Tk fonts for Dear ImGui (option -fonts) : Dear ImGui needs the file of a
# font (TTF/OTF), Tk only gives its family, size, weight and slant
# ('font actual'). The file is searched with the tools of the platform.
#
# Platform(s) : Windows (registry). Not supported yet on Linux and macOS.

namespace eval ::implottk {}

proc ::implottk::tkFontSize {font} {
    # Size of a Tk font in pixels.
    #
    # font - Tk font (name or description).
    #
    # Returns the size in pixels (Tk : points if > 0, pixels if < 0).
    set size [font actual $font -size]
    if {$size < 0} {
        return [expr {double(-$size)}]
    }
    return [expr {$size * [tk scaling]}]
}

proc ::implottk::matchFontEntry {entries family weight slant} {
    # Finds the file of a font in a list of font entries (Windows registry :
    # name -> file, e.g. 'Segoe UI Bold (TrueType)' -> segoeui.ttf).
    #
    # entries - dict {name file ...}
    # family  - family of the font ('Segoe UI').
    # weight  - normal | bold
    # slant   - roman | italic
    #
    # Returns the file or "" if not found.
    set style [string trim [join [list \
        [expr {$weight eq "bold" ? "Bold" : ""}] \
        [expr {$slant eq "italic" ? "Italic" : ""}]]]]

    if {$style eq ""} {
        set wanted [list $family "$family Regular"]
    } else {
        set wanted [list "$family $style"]
    }

    dict for {name file} $entries {
        # 'Segoe UI (TrueType)', 'Cambria & Cambria Math (TrueType)'
        regsub {\s*\((TrueType|OpenType|All res)\)\s*$} $name {} name
        foreach face [split [string map {" & " \x00} $name] \x00] {
            foreach w $wanted {
                if {[string equal -nocase [string trim $face] $w]} {
                    return $file
                }
            }
        }
    }
    return ""
}

proc ::implottk::tkFontFile {font} {
    # Finds the file of a Tk font.
    #
    # font - Tk font (name or description).
    #
    # Returns the full path of the file or "" if not found.
    set family [font actual $font -family]
    set weight [font actual $font -weight]
    set slant  [font actual $font -slant]

    if {[implottk::isWindows]} {
        package require registry
        set key {SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts}
        # Fonts of the user (full path), then of the system (file name).
        foreach root {HKEY_CURRENT_USER HKEY_LOCAL_MACHINE} {
            set entries {}
            if {[catch {registry values "$root\\$key"} names]} continue
            foreach name $names {
                if {![catch {registry get "$root\\$key" $name} file]} {
                    dict set entries $name $file
                }
            }
            # The regular face if the wanted style doesn't exist.
            foreach {w s} [list $weight $slant normal roman] {
                set file [implottk::matchFontEntry $entries $family $w $s]
                if {$file eq ""} continue
                if {[file pathtype $file] ne "absolute"} {
                    set file [file join $::env(SystemRoot) Fonts $file]
                }
                if {[file exists $file]} {
                    return [file normalize $file]
                }
            }
        }
    }
    return ""
}
