# Example from implot_demo.cpp
# void Demo_SubplotItemSharing()

proc sineWave {freq len} {
    # Returns the cffi pointers {xs ys} of a sine wave (computed once).
    if {![info exists ::waves($freq,$len)]} {
        set x {}
        set y {}
        for {set i 0} {$i < $len} {incr i} {
            lappend x $i
            lappend y [expr {sin($freq * $i)}]
        }
        set ::waves($freq,$len) [list [implottk::doubleToPointer $x] [implottk::doubleToPointer $y]]
    }
    return $::waves($freq,$len)
}

lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req implot.tk
catch {console show}

# set frame
set f [implottk::surface new]
$f SetOptions -width 800 -height 600

# add options
$f SetOptions -title "Subplots Sharing"

# ImPlotSubplotFlags_ShareItems = 32
# ImPlotSubplotFlags_ColMajor   = 1024

# add cmds 'Imgui' on the fly
$f AddGuiCmd {
    implottk::static {
        set flags 32
        set rows  3
        set cols  3
        # plot of each item 'data$j'
        set id {0 1 2 3 4 5}
        set curj -1
    }

    imgui::CheckboxFlags_UintPtr "ImPlotSubplotFlags_ShareItems" flags 32
    imgui::CheckboxFlags_UintPtr "ImPlotSubplotFlags_ColMajor"   flags 1024
    imgui::BulletText "%s" {string "Drag and drop items from the legend onto plots (except for 'common')"} 
}

# add cmds 'Implot' on the fly
$f AddPlotCmd {
    if {[implot::BeginSubplots "##ItemSharing" $rows $cols {x -1 y -1} $flags]} {
        for {set i 0} {$i < [expr {$rows * $cols}]} {incr i} {
            if {[implot::BeginPlot ""]} {
                set fc 0.01
                set len 1000
                lassign [sineWave $fc $len] xs ys
                implot::PlotLine_doublePtrdoublePtr "common" $xs $ys $len

                for {set j 0} {$j < 6} {incr j} {
                    if {[lindex $id $j] == $i} {
                        set fj [expr {0.01 * ($j + 2)}]
                        set label "data${j}"
                        lassign [sineWave $fj $len] xs ys
                        implot::PlotLine_doublePtrdoublePtr $label $xs $ys $len
                        if {[implot::BeginDragDropSourceItem $label]} {
                            set curj $j
                            imgui::SetDragDropPayload "MY_DND" NULL 0
                            set lastitem_vec4 [implot::GetLastItemColor]
                            implot::ItemIcon_Vec4 $lastitem_vec4 ; imgui::SameLine
                            imgui::TextUnformatted $label
                            implot::EndDragDropSource
                        }
                    }
                }
                # drag and drop...
                if {[implot::BeginDragDropTargetPlot]} {
                    if {[cffi::pointer isvalid [imgui::AcceptDragDropPayload "MY_DND"]]} {
                        set id [lreplace $id $curj $curj $i]
                    }

                    implot::EndDragDropTarget
                }
                implot::EndPlot
            }
        }
        implot::EndSubplots
    }
}

# Creates the Tk widget of the surface and shows it.
pack [$f Render] -fill both -expand 1
