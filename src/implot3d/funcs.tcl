# Copyright (c) 2022-2026 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

# ImPlot3D (cimplot3d) : functions are declared at the first call, like
# the ImPlot functions (see implot/funcs.tcl).

namespace eval ::implot3d {}

proc ::implot3d::initprocFunc {implot3d_funcs} {

    foreach {name func} $implot3d_funcs {
        # remove implot3d header name declaration
        regsub {(^ImPlot3D_)} $name {} procname
        # The cffi function is declared at the first call, then the proc is
        # replaced by an alias of the cffi command (an alias keeps the frame
        # of the caller for the inout / out variables).
        # (when the names are the same, the cffi command replaces the proc).
        if {$procname eq $name} {
            set alias ""
        } else {
            set alias "interp alias {} [namespace current]::$procname {} [namespace current]::$name;"
        }
        proc $procname args "CIMGUI function $name [list {*}$func]; $alias tailcall $name {*}\$args"
    }
}

# Notes on the declarations below (comments are not allowed in the list) :
# - data : pointer.double, see implottk::doubleToPointer.
# - PlotSurface zs : x_count * y_count values (row major : y then x).
# - PlotMesh idxs : pointer.uint (indices of the triangles), see
#   implottk::uintToPointer.
# - spec : dict of ImPlot3DSpec fields, e.g. {Marker ImPlot3DMarker_Circle}.
proc ::implot3d::init {} {

    set funcs {

        ImPlot3D_CreateContext     {pointer.ImPlot3DContext {}}
        ImPlot3D_DestroyContext    {void {ctx {pointer.ImPlot3DContext nullok {default NULL}}}}
        ImPlot3D_GetCurrentContext {pointer.ImPlot3DContext {}}
        ImPlot3D_SetCurrentContext {void {ctx pointer.ImPlot3DContext}}
        ImPlot3D_EndPlot           {void {}}
        ImPlot3D_ShowAllDemos      {void {}}

        ImPlot3D_BeginPlot {CIMGUI_BOOL {
                title_id string.utf-8
                size     {struct.::imgui::ImVec2 {default {x -1 y -1}}}
                flags    {ImPlot3DFlags bitmask  {default 0}}
            }
        }

        ImPlot3D_SetupAxis {void {
                axis  ImAxis3D
                label {string.utf-8 nullifempty {default ""}}
                flags {ImPlot3DAxisFlags bitmask {default 0}}
            }
        }

        ImPlot3D_SetupAxisLimits {void {
                axis  ImAxis3D
                v_min double
                v_max double
                cond  {ImPlot3DCond {default ImPlot3DCond_Once}}
            }
        }

        ImPlot3D_SetupAxisLimitsConstraints {void {
                axis  ImAxis3D
                v_min double
                v_max double
            }
        }

        ImPlot3D_SetupAxisZoomConstraints {void {
                axis     ImAxis3D
                zoom_min double
                zoom_max double
            }
        }

        ImPlot3D_SetupAxisScale_Plot3DScale {void {
                axis  ImAxis3D
                scale ImPlot3DScale
            }
        }

        ImPlot3D_SetupAxes {void {
                x_label {string.utf-8 nullifempty}
                y_label {string.utf-8 nullifempty}
                z_label {string.utf-8 nullifempty}
                x_flags {ImPlot3DAxisFlags bitmask {default 0}}
                y_flags {ImPlot3DAxisFlags bitmask {default 0}}
                z_flags {ImPlot3DAxisFlags bitmask {default 0}}
            }
        }

        ImPlot3D_SetupAxesLimits {void {
                x_min double
                x_max double
                y_min double
                y_max double
                z_min double
                z_max double
                cond  {ImPlot3DCond {default ImPlot3DCond_Once}}
            }
        }

        ImPlot3D_SetupBoxRotation_double {void {
                elevation double
                azimuth   double
                animate   {ImBool {default 0}}
                cond      {ImPlot3DCond {default ImPlot3DCond_Once}}
            }
        }

        ImPlot3D_SetupBoxRotation_Plot3DQuat {void {
                rotation struct.ImPlot3DQuat
                animate  {ImBool {default 0}}
                cond     {ImPlot3DCond {default ImPlot3DCond_Once}}
            }
        }

        ImPlot3D_SetupBoxInitialRotation_double {void {
                elevation double
                azimuth   double
            }
        }

        ImPlot3D_SetupBoxScale {void {
                x double
                y double
                z double
            }
        }

        ImPlot3D_SetupLegend {void {
                location ImPlot3DLocation
                flags    {ImPlot3DLegendFlags bitmask {default 0}}
            }
        }

        ImPlot3D_PlotScatter_doublePtr {void {
                label_id string.utf-8
                xs       pointer.::implot::double
                ys       pointer.::implot::double
                zs       pointer.::implot::double
                count    int
                spec     {struct.ImPlot3DSpec {default {}}}
            }
        }

        ImPlot3D_PlotLine_doublePtr {void {
                label_id string.utf-8
                xs       pointer.::implot::double
                ys       pointer.::implot::double
                zs       pointer.::implot::double
                count    int
                spec     {struct.ImPlot3DSpec {default {}}}
            }
        }

        ImPlot3D_PlotTriangle_doublePtr {void {
                label_id string.utf-8
                xs       pointer.::implot::double
                ys       pointer.::implot::double
                zs       pointer.::implot::double
                count    int
                spec     {struct.ImPlot3DSpec {default {}}}
            }
        }

        ImPlot3D_PlotQuad_doublePtr {void {
                label_id string.utf-8
                xs       pointer.::implot::double
                ys       pointer.::implot::double
                zs       pointer.::implot::double
                count    int
                spec     {struct.ImPlot3DSpec {default {}}}
            }
        }

        ImPlot3D_PlotSurface_doublePtr {void {
                label_id  string.utf-8
                xs        pointer.::implot::double
                ys        pointer.::implot::double
                zs        pointer.::implot::double
                x_count   int
                y_count   int
                scale_min {double {default 0.0}}
                scale_max {double {default 0.0}}
                spec      {struct.ImPlot3DSpec {default {}}}
            }
        }

        ImPlot3D_PlotMesh_doublePtr {void {
                label_id  string.utf-8
                vtx_xs    pointer.::implot::double
                vtx_ys    pointer.::implot::double
                vtx_zs    pointer.::implot::double
                idxs      pointer.uint
                vtx_count int
                idx_count int
                spec      {struct.ImPlot3DSpec {default {}}}
            }
        }

        ImPlot3D_PlotText {void {
                text       string.utf-8
                x          double
                y          double
                z          double
                angle      {double {default 0.0}}
                pix_offset {struct.::imgui::ImVec2 {default {x 0 y 0}}}
            }
        }

        ImPlot3D_PlotDummy {void {
                label_id string.utf-8
                spec     {struct.ImPlot3DSpec {default {}}}
            }
        }

        ImPlot3D_PlotToPixels_double {struct.::imgui::ImVec2 {
                x double
                y double
                z double
            }
        }

        ImPlot3D_PlotToPixels_Plot3DPoint {struct.::imgui::ImVec2 {
                point struct.ImPlot3DPoint
            }
        }

        ImPlot3D_PixelsToPlotRay_Vec2 {struct.ImPlot3DRay {
                pix struct.::imgui::ImVec2
            }
        }

        ImPlot3D_PixelsToPlotPlane_Vec2 {struct.ImPlot3DPoint {
                pix   struct.::imgui::ImVec2
                plane ImPlane3D
                mask  {ImBool {default 1}}
            }
        }

        ImPlot3D_GetPlotRectPos  {struct.::imgui::ImVec2 {}}
        ImPlot3D_GetPlotRectSize {struct.::imgui::ImVec2 {}}

        ImPlot3D_GetStyle {pointer.ImPlot3DStyle {}}

        ImPlot3D_StyleColorsAuto {void {
                dst {pointer.ImPlot3DStyle nullok {default NULL}}
            }
        }

        ImPlot3D_StyleColorsDark {void {
                dst {pointer.ImPlot3DStyle nullok {default NULL}}
            }
        }

        ImPlot3D_StyleColorsLight {void {
                dst {pointer.ImPlot3DStyle nullok {default NULL}}
            }
        }

        ImPlot3D_StyleColorsClassic {void {
                dst {pointer.ImPlot3DStyle nullok {default NULL}}
            }
        }

        ImPlot3D_PushStyleColor_Vec4 {void {
                idx ImPlot3DCol
                col struct.::imgui::ImVec4
            }
        }

        ImPlot3D_PushStyleColor_U32 {void {
                idx ImPlot3DCol
                col ImU32
            }
        }

        ImPlot3D_PopStyleColor {void {
                count {int {default 1}}
            }
        }

        ImPlot3D_PushStyleVar_Float {void {
                idx ImPlot3DStyleVar
                val float
            }
        }

        ImPlot3D_PushStyleVar_Int {void {
                idx ImPlot3DStyleVar
                val int
            }
        }

        ImPlot3D_PushStyleVar_Vec2 {void {
                idx ImPlot3DStyleVar
                val struct.::imgui::ImVec2
            }
        }

        ImPlot3D_PopStyleVar {void {
                count {int {default 1}}
            }
        }

        ImPlot3D_GetStyleColorVec4 {struct.::imgui::ImVec4 {
                idx ImPlot3DCol
            }
        }

        ImPlot3D_GetColormapCount {int {}}

        ImPlot3D_GetColormapName {string.utf-8 {
                cmap ImPlot3DColormap
            }
        }

        ImPlot3D_GetColormapIndex {ImPlot3DColormap {
                name string.utf-8
            }
        }

        ImPlot3D_GetColormapSize {int {
                cmap {ImPlot3DColormap {default -1}}
            }
        }

        ImPlot3D_PushColormap_Plot3DColormap {void {
                cmap ImPlot3DColormap
            }
        }

        ImPlot3D_PushColormap_Str {void {
                name string.utf-8
            }
        }

        ImPlot3D_PopColormap {void {
                count {int {default 1}}
            }
        }

        ImPlot3D_NextColormapColor {struct.::imgui::ImVec4 {}}

        ImPlot3D_GetColormapColor {struct.::imgui::ImVec4 {
                idx  int
                cmap {ImPlot3DColormap {default -1}}
            }
        }

        ImPlot3D_SampleColormap {struct.::imgui::ImVec4 {
                t    float
                cmap {ImPlot3DColormap {default -1}}
            }
        }

        ImPlot3D_ShowColormapSelector {CIMGUI_BOOL {
                label string.utf-8
            }
        }

        ImPlot3D_ShowStyleSelector {CIMGUI_BOOL {
                label string.utf-8
            }
        }

        ImPlot3D_ShowStyleEditor {void {
                ref {pointer.ImPlot3DStyle nullok {default NULL}}
            }
        }

        ImPlot3D_ShowDemoWindow {void {
                p_open {pointer.bool nullok {default NULL}}
            }
        }

        ImPlot3D_ShowMetricsWindow {void {
                p_popen {pointer.bool nullok {default NULL}}
            }
        }

        ImPlot3D_ShowAboutWindow {void {
                p_open {pointer.bool nullok {default NULL}}
            }
        }
    }

    return $funcs
}

implot3d::initprocFunc [implot3d::init]

# SetupAxisTicks : 'labels' is a list of 'n_ticks' strings, or {} for the
# default labels (NULL pointer : cffi can't pass an empty array as NULL).
proc ::implot3d::SetupAxisTicks_doublePtr {axis values n_ticks {labels {}} {keep_default 0}} {
    if {[llength $labels]} {
        set name ImPlot3D_SetupAxisTicks_doublePtr
        set type {string.utf-8[n_ticks]}
    } else {
        set name ImPlot3D_SetupAxisTicks_doublePtr_NoLabels
        set type {pointer nullok}
        set labels NULL
    }
    if {[info commands ::implot3d::$name] eq ""} {
        CIMGUI function [list ImPlot3D_SetupAxisTicks_doublePtr ::implot3d::$name] void [list \
            axis ImAxis3D values pointer.::implot::double n_ticks int labels $type keep_default ImBool]
    }
    tailcall $name $axis $values $n_ticks $labels $keep_default
}

proc ::implot3d::SetupAxisTicks_double {axis v_min v_max n_ticks {labels {}} {keep_default 0}} {
    if {[llength $labels]} {
        set name ImPlot3D_SetupAxisTicks_double
        set type {string.utf-8[n_ticks]}
    } else {
        set name ImPlot3D_SetupAxisTicks_double_NoLabels
        set type {pointer nullok}
        set labels NULL
    }
    if {[info commands ::implot3d::$name] eq ""} {
        CIMGUI function [list ImPlot3D_SetupAxisTicks_double ::implot3d::$name] void [list \
            axis ImAxis3D v_min double v_max double n_ticks int labels $type keep_default ImBool]
    }
    tailcall $name $axis $v_min $v_max $n_ticks $labels $keep_default
}
