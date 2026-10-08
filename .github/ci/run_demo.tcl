
# Runs a demo for a few seconds (needs OpenGL 3.2) and fails on any Tcl error.
# Usage : tclsh .github/ci/run_demo.tcl demo/lineplots.tcl

package require Tk

lassign $argv demo

interp bgerror {} {apply {{msg opts} {
    puts "ERROR: $msg\n[dict get $opts -errorinfo]"
    exit 1
}}}

wm geometry . 800x600+0+0

if {[catch {uplevel #0 [list source $demo]} err]} {
    puts "ERROR: $err\n$::errorInfo"
    exit 1
}

# Watchdog : 60 s at most (a demo that blocks the event loop is stopped by
# the 'timeout-minutes' of the CI step).
after 60000 {
    puts "ERROR: [file tail $::demo] : timeout"
    exit 1
}

after 2000 {
    puts "ok [file tail $::demo]"
    exit 0
}
