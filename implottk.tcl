# Copyright (c) 2022-2026 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

# Release:
# 15-Sep-2022 : 1.0b0
# 19-Sep-2022 : 1.0b1
# - Add _SubplotsSizing_ + _SubplotItemSharing_ (drag & drop) demo.
# - Cosmetic changes + adding `imgui` functions.
# 01-Oct-2022 : 1.0b2
# - Add examples.
# - Fix bug when my frame was mapped or unmapped.
# - Rename win32.tcl file by user32.tcl
# 08-Oct-2026 : 1.0
# - Full redesign of the library.
# - More examples and GitHub Actions.

package require Tcl 9.0
package require Tk
package require cffi 2.0
package require Tkgl

namespace eval ::implottk {
    variable version 1.0
    variable dir [file dirname [file normalize [info script]]]
    # Dear ImGui version of the bindings.
    variable imguiVersion "1.92.9b"
}

cffi::alias load C

switch -exact -- $::tcl_platform(os) {
    "Windows NT" {set cimLib cimgui_win32.dll}
    "Darwin"     {set cimLib libcimgui_osx.dylib}
    default      {set cimLib libcimgui_linux.so}
}

# Load the C library.
cffi::Wrapper create CIMGUI [file join $::implottk::dir lib $cimLib]

CIMGUI function igGetVersion string {}

if {[igGetVersion] ne $::implottk::imguiVersion} {
    puts stderr "Warning : 'Dear Imgui' version '[igGetVersion]' is not supported\
                 (supported version : $::implottk::imguiVersion)..."
}

package provide implot.tk $implottk::version
