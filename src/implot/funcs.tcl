# Copyright (c) 2022-2026 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

# Note : ImPlot_PlotLineG (and the other *G functions) are not available,
# the ImPlot 1.0 getter returns an 'ImPlotPoint' by value and cffi
# callbacks can't return a struct.

namespace eval ::implot {

    # callbacks implot (ImPlot 1.0)
    cffi::prototype function ImPlotFormatter int {
        value     double
        buff      {pointer unsafe}
        size      int
        user_data {pointer unsafe nullok}
    }

    cffi::prototype function ImPlotTransform double {
        value     double
        user_data {pointer unsafe nullok}
    }

    cffi::prototype function ImPlotLocator void {
        ticker         {pointer.ImPlotTicker unsafe}
        range          {pointer.ImPlotRange unsafe}
        pixels         float
        vertical       ImBool
        formatter      {pointer.ImPlotFormatter unsafe nullok}
        formatter_data {pointer unsafe nullok}
    }
}

proc ::implot::initprocFunc {implot_funcs} {
  
    foreach {name func} $implot_funcs {
        # remove implot header name declaration
        regsub {(^ImPlot_)} $name {} procname
        set params [lindex $func 1]
        if {[lindex $params end] eq "..."} {
            # Variadic function (Annotation, TagX...) : the 'string'
            # arguments are sent in UTF-8 (see imgui::VarargsUtf8).
            set nfixed [expr {([llength $params] - 1) / 2}]
            set call "tailcall $name {*}\[::imgui::VarargsUtf8 $nfixed \$args\]"
            proc $procname args "CIMGUI function $name [list {*}$func];\
                proc [namespace current]::$procname args [list $call]; $call"
            continue
        }
        # The cffi function is declared at the first call, then the proc is
        # replaced by an alias of the cffi command (no declaration at the
        # next calls ; an alias keeps the frame of the caller for the
        # inout / out variables).
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
# - label_ids (PlotBarGroups, PlotPieChart) : Tcl list of strings.
# - PlotBarGroups / PlotHeatmap values : row major.
# - PlotHistogram bins : number of bins or ImPlotBin_ method, returns the
#   height of the largest bin.
# - DragRect : x_min... names of variables (inout), clicked, hovered, held
#   names of output variables.
proc ::implot::init {} {

    set funcs {

        ImPlot_CreateContext           {pointer.ImPlotContext {}}
        ImPlot_DestroyContext          {void                  {ctx {pointer.ImPlotContext nullok {default NULL}}}}
        ImPlot_GetCurrentContext       {pointer.ImPlotContext {}}
        ImPlot_SetCurrentContext       {void                  {ctx pointer.ImPlotContext}}
        ImPlot_SetImGuiContext         {void                  {ctx pointer.::imgui::ImGuiContext}}
        ImPlot_EndPlot                 {void                  {}}
        ImPlot_EndSubplots             {void                  {}}
        ImPlot_EndDragDropSource       {void                  {}}
        ImPlot_BeginDragDropTargetPlot {CIMGUI_BOOL           {}}
        ImPlot_EndDragDropTarget       {void                  {}}
        

        ImPlot_BeginPlot {CIMGUI_BOOL {
                title_id string.utf-8
                size     {struct.::imgui::ImVec2 {default {x -1 y -1}}}
                flags    {ImPlotFlags bitmask    {default 0}}
            }
        }
        
        ImPlot_ShowDemoWindow {void {
                p_open {pointer.bool nullok {default NULL}}
            }
        }
        
        ImPlot_PlotLine_doublePtrdoublePtr {void {
                label_id string.utf-8
                xs       pointer.double
                ys       pointer.double
                count    int
                spec     {struct.ImPlotSpec {default {}}}
            }
        }
        
        ImPlot_SetupAxesLimits {void {
                x_min double
                x_max double
                y_min double
                y_max double
                cond  {ImPlotCond {default 2}}
            }
        }
        
        ImPlot_GetPlotLimits {struct.ImPlotRect {
                x_axis {ImAxis {default -1}}
                y_axis {ImAxis {default -1}}
            }
        }
        
        ImPlot_GetPlotSize {struct.::imgui::ImVec2 {}}
        
        ImPlot_GetPlotPos {struct.::imgui::ImVec2 {}}

        ImPlot_PushStyleColor_Vec4 {void {
                idx ImPlotCol
                col struct.::imgui::ImVec4
            }
        }

        ImPlot_PopStyleColor {void {
                count {int {default 1}}
            }
        }
        
        ImPlot_SetupAxes {void {
                x_label {string.utf-8 nullifempty}
                y_label {string.utf-8 nullifempty}
                x_flags {ImPlotAxisFlags bitmask {default 0}}
                y_flags {ImPlotAxisFlags bitmask {default 0}}
            }
        }
        
        ImPlot_PushStyleVar_Float {void {
                idx ImPlotStyleVar
                val float
            }
        }
        
        ImPlot_PushStyleVar_Vec2 {void {
                idx ImPlotStyleVar
                val struct.::imgui::ImVec2
            }
        }
        
        ImPlot_PlotShaded_doublePtrInt {void {
                label_id string.utf-8
                values   pointer.double
                count    int
                yref     {double            {default 0}}
                xscale   {double            {default 1}}
                xstart   {double            {default 0}}
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotShaded_doublePtrdoublePtrInt {void {
                label_id string.utf-8
                xs       pointer.double
                ys       pointer.double
                count    int
                yref     {double            {default 0}}
                spec     {struct.ImPlotSpec {default {}}}
            }
        }
        
        ImPlot_PlotShaded_doublePtrdoublePtrdoublePtr {void {
                label_id string.utf-8
                xs       pointer.double
                ys1      pointer.double
                ys2      pointer.double
                count    int
                spec     {struct.ImPlotSpec {default {}}}
            }
        }
        
        ImPlot_PopStyleVar {void {
                count {int {default 1}}
            }
        }
        
        ImPlot_BeginSubplots {CIMGUI_BOOL {
                title_id   string.utf-8
                rows       int
                cols       int
                size       struct.::imgui::ImVec2
                flags      ImPlotSubplotFlags
                row_ratios {pointer nullok {default NULL}}
                col_ratios {pointer nullok {default NULL}}
            }
        }
        
        ImPlot_SampleColormap {struct.::imgui::ImVec4 {
                t    float
                cmap {ImPlotColormap {default -1}}
            }
        }

        ImPlot_BeginDragDropSourceItem {CIMGUI_BOOL {
                label_id string.utf-8
                flags    {imgui::ImGuiDragDropFlags {default 0}}
            }
        }

        ImPlot_ItemIcon_Vec4 {void {
                col struct.::imgui::ImVec4
            }
        }

        ImPlot_GetLastItemColor {struct.::imgui::ImVec4 {}}
        
        ImPlot_PushColormap_PlotColormap {void {
                cmap ImPlotColormap
            }
        }
        
        ImPlot_PopColormap {void {
                count {int {default 1}}
            }
        }
        
        ImPlot_GetColormapColor {struct.::imgui::ImVec4 {
                idx  int
                cmap {ImPlotColormap {default -1}}
            }
        }
        
        ImPlot_PlotStems_doublePtrdoublePtr {void {
                label_id string.utf-8
                xs       pointer.double
                ys       pointer.double
                count    int
                ref      {double            {default 0}}
                spec     {struct.ImPlotSpec {default {}}}
            }
        }
        

        ImPlot_SetupAxisLimits {void {
                axis  ImAxis
                v_min double
                v_max double
                cond  {ImPlotCond {default ImPlotCond_Once}}
            }
        }

        ImPlot_SetupLegend {void {
                location ImPlotLocation
                flags    {ImPlotLegendFlags {default 0}}
            }
        }


        ImPlot_PlotLine_doublePtrInt {void {
                label_id string.utf-8
                values   pointer.double
                count    int
                xscale   {double            {default 1}}
                xstart   {double            {default 0}}
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotScatter_doublePtrdoublePtr {void {
                label_id string.utf-8
                xs       pointer.double
                ys       pointer.double
                count    int
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotStairs_doublePtrInt {void {
                label_id string.utf-8
                values   pointer.double
                count    int
                xscale   {double            {default 1}}
                xstart   {double            {default 0}}
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotBars_doublePtrInt {void {
                label_id string.utf-8
                values   pointer.double
                count    int
                bar_size {double            {default 0.67}}
                shift    {double            {default 0}}
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotBars_doublePtrdoublePtr {void {
                label_id string.utf-8
                xs       pointer.double
                ys       pointer.double
                count    int
                bar_size double
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotBarGroups_doublePtr {void {
                label_ids   {string.utf-8[item_count]}
                values      pointer.double
                item_count  int
                group_count int
                group_size  {double            {default 0.67}}
                shift       {double            {default 0}}
                spec        {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotErrorBars_doublePtrdoublePtrdoublePtrInt {void {
                label_id string.utf-8
                xs       pointer.double
                ys       pointer.double
                err      pointer.double
                count    int
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotErrorBars_doublePtrdoublePtrdoublePtrdoublePtr {void {
                label_id string.utf-8
                xs       pointer.double
                ys       pointer.double
                neg      pointer.double
                pos      pointer.double
                count    int
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotPieChart_doublePtrStr {void {
                label_ids {string.utf-8[count]}
                values    pointer.double
                count     int
                x         double
                y         double
                radius    double
                label_fmt {string.utf-8            {default "%.1f"}}
                angle0    {double            {default 90}}
                spec      {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotHeatmap_doublePtr {void {
                label_id   string.utf-8
                values     pointer.double
                rows       int
                cols       int
                scale_min  {double             {default 0}}
                scale_max  {double             {default 0}}
                label_fmt  {string.utf-8 nullifempty {default "%.1f"}}
                bounds_min {struct.ImPlotPoint {default {x 0 y 0}}}
                bounds_max {struct.ImPlotPoint {default {x 1 y 1}}}
                spec       {struct.ImPlotSpec  {default {}}}
            }
        }

        ImPlot_PlotHistogram_doublePtr {double {
                label_id  string.utf-8
                values    pointer.double
                count     int
                bins      {ImPlotBin          {default ImPlotBin_Sturges}}
                bar_scale {double             {default 1.0}}
                range     {struct.ImPlotRange {default {Min 0 Max 0}}}
                spec      {struct.ImPlotSpec  {default {}}}
            }
        }


        ImPlot_ColormapScale {void {
                label     string.utf-8
                scale_min double
                scale_max double
                size      {struct.::imgui::ImVec2    {default {x 0 y 0}}}
                format    {string.utf-8                    {default "%g"}}
                flags     {ImPlotColormapScaleFlags  {default 0}}
                cmap      {ImPlotColormap            {default -1}}
            }
        }

        ImPlot_ColormapButton {CIMGUI_BOOL {
                label string.utf-8
                size  {struct.::imgui::ImVec2 {default {x 0 y 0}}}
                cmap  {ImPlotColormap         {default -1}}
            }
        }

        ImPlot_GetColormapName  {string.utf-8 {cmap ImPlotColormap}}
        ImPlot_GetColormapCount {int    {}}

        ImPlot_BustColorCache {void {
                plot_title_id {string.utf-8 nullifempty {default ""}}
            }
        }


        ImPlot_PlotScatter_doublePtrInt {void {
                label_id string.utf-8
                values   pointer.double
                count    int
                xscale   {double            {default 1}}
                xstart   {double            {default 0}}
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotStems_doublePtrInt {void {
                label_id string.utf-8
                values   pointer.double
                count    int
                ref      {double            {default 0}}
                scale    {double            {default 1}}
                start    {double            {default 0}}
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotStairs_doublePtrdoublePtr {void {
                label_id string.utf-8
                xs       pointer.double
                ys       pointer.double
                count    int
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotBubbles_doublePtrdoublePtrInt {void {
                label_id string.utf-8
                values   pointer.double
                szs      pointer.double
                count    int
                xscale   {double            {default 1}}
                xstart   {double            {default 0}}
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotBubbles_doublePtrdoublePtrdoublePtr {void {
                label_id string.utf-8
                xs       pointer.double
                ys       pointer.double
                szs      pointer.double
                count    int
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotPolygon_doublePtr {void {
                label_id string.utf-8
                xs       pointer.double
                ys       pointer.double
                count    int
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotInfLines_doublePtr {void {
                label_id string.utf-8
                values   pointer.double
                count    int
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotDigital_doublePtr {void {
                label_id string.utf-8
                xs       pointer.double
                ys       pointer.double
                count    int
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotText {void {
                text       string.utf-8
                x          double
                y          double
                pix_offset {struct.::imgui::ImVec2 {default {x 0 y 0}}}
                spec       {struct.ImPlotSpec      {default {}}}
            }
        }

        ImPlot_PlotDummy {void {
                label_id string.utf-8
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_PlotHistogram2D_doublePtr {double {
                label_id string.utf-8
                xs       pointer.double
                ys       pointer.double
                count    int
                x_bins   {ImPlotBin         {default ImPlotBin_Sturges}}
                y_bins   {ImPlotBin         {default ImPlotBin_Sturges}}
                range    {struct.ImPlotRect {default {X {Min 0 Max 0} Y {Min 0 Max 0}}}}
                spec     {struct.ImPlotSpec {default {}}}
            }
        }

        ImPlot_SetupAxis {void {
                axis  ImAxis
                label {string.utf-8 nullifempty {default ""}}
                flags {ImPlotAxisFlags bitmask  {default 0}}
            }
        }

        ImPlot_SetupAxisFormat_Str {void {
                axis ImAxis
                fmt  string.utf-8
            }
        }

        ImPlot_SetupAxisScale_PlotScale {void {
                axis  ImAxis
                scale ImPlotScale
            }
        }

        ImPlot_SetupAxisLinks {void {
                axis     ImAxis
                link_min {pointer.double nullok}
                link_max {pointer.double nullok}
            }
        }

        ImPlot_SetupAxisLimitsConstraints {void {
                axis  ImAxis
                v_min double
                v_max double
            }
        }

        ImPlot_SetupAxisZoomConstraints {void {
                axis  ImAxis
                z_min double
                z_max double
            }
        }

        ImPlot_SetupMouseText {void {
                location ImPlotLocation
                flags    {ImPlotMouseTextFlags bitmask {default 0}}
            }
        }

        ImPlot_SetupFinish {void {}}

        ImPlot_SetNextAxisLimits {void {
                axis  ImAxis
                v_min double
                v_max double
                cond  {ImPlotCond {default ImPlotCond_Once}}
            }
        }

        ImPlot_SetNextAxesLimits {void {
                x_min double
                x_max double
                y_min double
                y_max double
                cond  {ImPlotCond {default ImPlotCond_Once}}
            }
        }

        ImPlot_SetNextAxisToFit {void {axis ImAxis}}
        ImPlot_SetNextAxesToFit {void {}}

        ImPlot_SetNextAxisLinks {void {
                axis     ImAxis
                link_min {pointer.double nullok}
                link_max {pointer.double nullok}
            }
        }

        ImPlot_SetAxis  {void {axis ImAxis}}
        ImPlot_SetAxes  {void {x_axis ImAxis y_axis ImAxis}}

        ImPlot_Annotation_Bool {void {
                x          double
                y          double
                col        struct.::imgui::ImVec4
                pix_offset struct.::imgui::ImVec2
                clamp      ImBool
                round      {ImBool {default 0}}
            }
        }

        ImPlot_Annotation_Str {void {
                x          double
                y          double
                col        struct.::imgui::ImVec4
                pix_offset struct.::imgui::ImVec2
                clamp      ImBool
                fmt        string.utf-8
                ...
            }
        }

        ImPlot_TagX_Bool {void {
                x     double
                col   struct.::imgui::ImVec4
                round {ImBool {default 0}}
            }
        }

        ImPlot_TagX_Str {void {
                x   double
                col struct.::imgui::ImVec4
                fmt string.utf-8
                ...
            }
        }

        ImPlot_TagY_Bool {void {
                y     double
                col   struct.::imgui::ImVec4
                round {ImBool {default 0}}
            }
        }

        ImPlot_TagY_Str {void {
                y   double
                col struct.::imgui::ImVec4
                fmt string.utf-8
                ...
            }
        }

        ImPlot_GetPlotMousePos {struct.ImPlotPoint {
                x_axis {ImAxis {default -1}}
                y_axis {ImAxis {default -1}}
            }
        }

        ImPlot_IsPlotHovered      {CIMGUI_BOOL {}}
        ImPlot_IsAxisHovered      {CIMGUI_BOOL {axis ImAxis}}
        ImPlot_IsSubplotsHovered  {CIMGUI_BOOL {}}
        ImPlot_IsLegendEntryHovered {CIMGUI_BOOL {label_id string.utf-8}}
        ImPlot_IsPlotSelected     {CIMGUI_BOOL {}}
        ImPlot_CancelPlotSelection {void {}}

        ImPlot_GetPlotSelection {struct.ImPlotRect {
                x_axis {ImAxis {default -1}}
                y_axis {ImAxis {default -1}}
            }
        }

        ImPlot_PixelsToPlot_Vec2 {struct.ImPlotPoint {
                pix    struct.::imgui::ImVec2
                x_axis {ImAxis {default -1}}
                y_axis {ImAxis {default -1}}
            }
        }

        ImPlot_PlotToPixels_double {struct.::imgui::ImVec2 {
                x      double
                y      double
                x_axis {ImAxis {default -1}}
                y_axis {ImAxis {default -1}}
            }
        }

        ImPlot_BeginAlignedPlots {CIMGUI_BOOL {
                group_id string.utf-8
                vertical {ImBool {default 1}}
            }
        }

        ImPlot_EndAlignedPlots {void {}}

        ImPlot_GetStyle {pointer.ImPlotStyle {}}

        ImPlot_DragRect {CIMGUI_BOOL {
                id      int
                x_min   {double inout}
                y_min   {double inout}
                x_max   {double inout}
                y_max   {double inout}
                col     struct.::imgui::ImVec4
                flags   {ImPlotDragToolFlags {default 0}}
                clicked {ImBool out}
                hovered {ImBool out}
                held    {ImBool out}
            }
        }
        
    }
    
    return $funcs

}

implot::initprocFunc [implot::init]

# SetupAxisTicks : 'labels' is a list of 'n_ticks' strings, or {} for the
# default labels (NULL pointer : cffi can't pass an empty array as NULL).
proc ::implot::SetupAxisTicks_doublePtr {axis values n_ticks {labels {}} {keep_default 0}} {
    if {[llength $labels]} {
        set name ImPlot_SetupAxisTicks_doublePtr
        set type {string.utf-8[n_ticks]}
    } else {
        set name ImPlot_SetupAxisTicks_doublePtr_NoLabels
        set type {pointer nullok}
        set labels NULL
    }
    if {[info commands ::implot::$name] eq ""} {
        CIMGUI function [list ImPlot_SetupAxisTicks_doublePtr ::implot::$name] void [list \
            axis ImAxis values pointer.double n_ticks int labels $type keep_default ImBool]
    }
    tailcall $name $axis $values $n_ticks $labels $keep_default
}

proc ::implot::SetupAxisTicks_double {axis v_min v_max n_ticks {labels {}} {keep_default 0}} {
    if {[llength $labels]} {
        set name ImPlot_SetupAxisTicks_double
        set type {string.utf-8[n_ticks]}
    } else {
        set name ImPlot_SetupAxisTicks_double_NoLabels
        set type {pointer nullok}
        set labels NULL
    }
    if {[info commands ::implot::$name] eq ""} {
        CIMGUI function [list ImPlot_SetupAxisTicks_double ::implot::$name] void [list \
            axis ImAxis v_min double v_max double n_ticks int labels $type keep_default ImBool]
    }
    tailcall $name $axis $v_min $v_max $n_ticks $labels $keep_default
}

# Drag tools : x, y are names of variables (inout), clicked, hovered, held
# optional names of output variables ("" : not returned).
# 'tailcall' : the variables are those of the caller.
proc ::implot::DragPoint {id x y col {size 4} {flags 0} {clicked ""} {hovered ""} {held ""}} {
    if {[info commands ::implot::ImPlot_DragPoint] eq ""} {
        CIMGUI function ImPlot_DragPoint CIMGUI_BOOL {
            id      int
            x       {double inout}
            y       {double inout}
            col     struct.::imgui::ImVec4
            size    float
            flags   ImPlotDragToolFlags
            clicked {ImBool out nullifempty}
            hovered {ImBool out nullifempty}
            held    {ImBool out nullifempty}
        }
    }
    tailcall ImPlot_DragPoint $id $x $y $col $size $flags $clicked $hovered $held
}

proc ::implot::DragLineX {id x col {thickness 1} {flags 0} {clicked ""} {hovered ""} {held ""}} {
    if {[info commands ::implot::ImPlot_DragLineX] eq ""} {
        CIMGUI function ImPlot_DragLineX CIMGUI_BOOL {
            id        int
            x         {double inout}
            col       struct.::imgui::ImVec4
            thickness float
            flags     ImPlotDragToolFlags
            clicked   {ImBool out nullifempty}
            hovered   {ImBool out nullifempty}
            held      {ImBool out nullifempty}
        }
    }
    tailcall ImPlot_DragLineX $id $x $col $thickness $flags $clicked $hovered $held
}

proc ::implot::DragLineY {id y col {thickness 1} {flags 0} {clicked ""} {hovered ""} {held ""}} {
    if {[info commands ::implot::ImPlot_DragLineY] eq ""} {
        CIMGUI function ImPlot_DragLineY CIMGUI_BOOL {
            id        int
            y         {double inout}
            col       struct.::imgui::ImVec4
            thickness float
            flags     ImPlotDragToolFlags
            clicked   {ImBool out nullifempty}
            hovered   {ImBool out nullifempty}
            held      {ImBool out nullifempty}
        }
    }
    tailcall ImPlot_DragLineY $id $y $col $thickness $flags $clicked $hovered $held
}

# Getter functions (PlotLineG...) : the points are given by a Tcl command
# called for each index, it returns the point {x y}.
#   implot::PlotLineG "label" {apply {{i} {list $i [expr {sin($i * 0.1)}]}}} 100
# The ImPlot getter returns an 'ImPlotPoint' by value (not possible with a
# cffi callback), the '_LJ' functions of cimplot give a pointer on the point
# to fill instead. The command is called several times by point and by frame
# (fit + drawing) : for large data, the arrays functions are faster.
proc ::implot::InitGetters {} {
    # Declares the '_LJ' functions and creates the callbacks (once).
    variable getters
    if {[info exists getters]} return

    set getter  {getter pointer.ImPlotPointGetter data {pointer unsafe nullok}}
    set spec    {spec {struct.ImPlotSpec {default {}}}}
    foreach name {PlotLineG PlotScatterG PlotStairsG PlotDigitalG} {
        CIMGUI function [list ImPlot_${name}_LJ ::implot::ImPlot_${name}_LJ] void [list \
            label_id string.utf-8 {*}$getter count int {*}$spec]
    }
    CIMGUI function [list ImPlot_PlotBarsG_LJ ::implot::ImPlot_PlotBarsG_LJ] void [list \
        label_id string.utf-8 {*}$getter count int bar_size double {*}$spec]
    CIMGUI function [list ImPlot_PlotShadedG_LJ ::implot::ImPlot_PlotShadedG_LJ] void [list \
        label_id string.utf-8 getter1 pointer.ImPlotPointGetter data1 {pointer unsafe nullok} \
        getter2 pointer.ImPlotPointGetter data2 {pointer unsafe nullok} count int {*}$spec]

    cffi::prototype function ImPlotPointGetter {pointer unsafe nullok} {
        data  {pointer unsafe nullok}
        idx   int
        point {pointer.ImPlotPoint unsafe}
    }
    # One callback by getter (ShadedG has 2 getters).
    foreach i {1 2} {
        dict set getters $i callback [cffi::callback new ::implot::ImPlotPointGetter \
            [list ::implot::GetterCallback $i] NULL]
        dict set getters $i command {}
        dict set getters $i error   {}
    }
}

proc ::implot::GetterCallback {i data idx point} {
    # Callback of the getters : calls the Tcl command of the getter $i (in
    # the frame of the caller of PlotXxxG) and writes the point.
    variable getters
    if {[dict get $getters $i error] ne ""} {return NULL}
    if {[catch {
        lassign [uplevel 1 [list {*}[dict get $getters $i command] $idx]] x y
        ::implot::ImPlotPoint tonative! $point [list x $x y $y]
    } msg opts]} {
        # Reported by PlotXxxG once the C function has returned.
        dict set getters $i error [list $msg $opts]
    }
    return NULL
}

proc ::implot::CallGetters {name commands args} {
    # Calls the '_LJ' function 'name' in the frame of the caller of
    # PlotXxxG. In 'args', @1 and @2 are replaced by the callbacks of the
    # getters, the getter commands are 'commands'.
    variable getters
    InitGetters
    set i 0
    foreach cmd $commands {
        incr i
        dict set getters $i command $cmd
        dict set getters $i error {}
    }
    set args [lmap a $args {
        expr {$a in {@1 @2} ? [dict get $getters [string index $a 1] callback] : $a}
    }]
    uplevel 2 [list ::implot::ImPlot_${name}_LJ {*}$args]
    foreach i {1 2} {
        set err [dict get $getters $i error]
        if {$err ne ""} {
            dict set getters $i error {}
            return -options [lindex $err 1] [lindex $err 0]
        }
    }
    return {}
}

proc ::implot::PlotLineG {label_id getter count {spec {}}} {
    CallGetters PlotLineG [list $getter] $label_id @1 NULL $count $spec
}

proc ::implot::PlotScatterG {label_id getter count {spec {}}} {
    CallGetters PlotScatterG [list $getter] $label_id @1 NULL $count $spec
}

proc ::implot::PlotStairsG {label_id getter count {spec {}}} {
    CallGetters PlotStairsG [list $getter] $label_id @1 NULL $count $spec
}

proc ::implot::PlotDigitalG {label_id getter count {spec {}}} {
    CallGetters PlotDigitalG [list $getter] $label_id @1 NULL $count $spec
}

proc ::implot::PlotBarsG {label_id getter count bar_size {spec {}}} {
    CallGetters PlotBarsG [list $getter] $label_id @1 NULL $count $bar_size $spec
}

proc ::implot::PlotShadedG {label_id getter1 getter2 count {spec {}}} {
    CallGetters PlotShadedG [list $getter1 $getter2] $label_id @1 NULL @2 NULL $count $spec
}
