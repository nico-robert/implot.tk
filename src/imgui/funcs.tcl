# Copyright (c) 2022-2026 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

namespace eval ::imgui {}

proc ::imgui::initprocFunc {imgui_funcs} {

    foreach {name func} $imgui_funcs {
        # remove cimgui header name declaration
        regsub {(^ImGui_)|(^ig)|(^ImGui)|(^cImGui_)} $name {} procname
        # The cffi function is declared at the first call, then the proc is
        # replaced by an alias of the cffi command (no declaration at the
        # next calls ; an alias keeps the frame of the caller for the
        # inout / out variables).
        # (when the names are the same, the cffi command replaces the proc).
        set params [lindex $func 1]
        if {[lindex $params end] eq "..."} {
            # Variadic function (Text...) : the 'string' arguments are sent
            # in UTF-8, like the other strings (see VarargsUtf8).
            set nfixed [expr {([llength $params] - 1) / 2}]
            set call "tailcall $name {*}\[VarargsUtf8 $nfixed \$args\]"
            proc $procname args "CIMGUI function $name [list {*}$func];\
                proc [namespace current]::$procname args [list $call]; $call"
            continue
        }
        if {$procname eq $name} {
            set alias ""
        } else {
            set alias "interp alias {} [namespace current]::$procname {} [namespace current]::$name;"
        }
        proc $procname args "CIMGUI function $name [list {*}$func]; $alias tailcall $name {*}\$args"
    }
}

proc ::imgui::VarargsUtf8 {nfixed arguments} {
    # Dear ImGui expects UTF-8 strings : the variadic arguments {string value}
    # are sent as {string.utf-8 value} (cffi uses the system encoding for
    # 'string', e.g. cp1252 on Windows).
    #
    # nfixed    - number of fixed parameters.
    # arguments - arguments of the function.
    #
    # Returns the arguments.
    for {set i $nfixed} {$i < [llength $arguments]} {incr i} {
        set arg [lindex $arguments $i]
        if {[llength $arg] == 2 && [lindex $arg 0] eq "string"} {
            lset arguments $i 0 string.utf-8
        }
    }
    return $arguments
}

proc ::imgui::init {} {

    set funcs {
        igShowUserGuide                    {void                          {}}
        igNewFrame                         {void                          {}}
        igEndFrame                         {void                          {}}
        igEnd                              {void                          {}}
        igRender                           {void                          {}}
        igGetIO_Nil                        {pointer.ImGuiIO               {}}
        igGetDrawData                      {pointer.ImDrawData            {}}
        igGetCurrentContext                {{pointer.ImGuiContext nullok} {}}
        igSetCurrentContext                {void                          {ctx pointer.ImGuiContext}}
        igGetMainViewport                  {pointer.ImGuiViewport         {}}
        igGetMousePos                      {struct.ImVec2                 {}}
        igGetTime                          {double                        {}}
        igSetNextWindowFocus               {void                          {}}
        igEndTable                         {void                          {}}
        igTableHeadersRow                  {void                          {}}
        igPopID                            {void                          {}}
        igShutdown                         {void                          {}}
        

        
        igBegin {CIMGUI_BOOL {
                name   string.utf-8
                p_open {pointer.bool     nullok  {default NULL}}
                flags  {ImGuiWindowFlags bitmask {default 0}}
            }
        }
        
        igShowDemoWindow {void {
                p_open {pointer.bool nullok {default NULL}}
            }
        }
        
        igCreateContext {pointer.ImGuiContext {
                shared_font_atlas {pointer.ImFontAtlas nullok {default NULL}}
            }
        }
        
        igSliderFloat {CIMGUI_BOOL {
                label  string.utf-8
                v      {float inout}
                v_min  float
                v_max  float
                format {string.utf-8           {default "%.3f"}}
                flags  {ImGuiSliderFlags {default 0}} 
            }
        }

        igGetIO_ContextPtr {pointer.ImGuiIO {
                ctx    pointer.ImGuiContext
            }
        }

        igDestroyContext {void {
                ctx {pointer.ImGuiContext nullok}
            }
        }

        igSetNextWindowPos {void {
                pos   struct.ImVec2
                cond  ImGuiCond
                pivot struct.ImVec2
            }
        }

        igSetNextWindowSize {void {
                size struct.ImVec2
                cond ImGuiCond
            }
        }
        
        igSetWindowPos_Str {void {
                name string.utf-8
                pos  struct.ImVec2
                cond ImGuiCond
            }
        }
        
        igSetWindowSize_Str {void {
                name string.utf-8
                pos  struct.ImVec2
                cond ImGuiCond
            }
        }

        igButton {CIMGUI_BOOL {
                label string.utf-8
                size  struct.ImVec2
            }
        }

        ImGuiIO_AddKeyEvent {void {
                self pointer.ImGuiIO
                key  ImGuiKey
                down ImBool
            }
        }
        
        
        

        
        
        igPushStyleColor_Vec4 {void {
                idx ImGuiCol
                col struct.ImVec4
            }
        }
        
        igPushStyleColor_U32 {void {
                idx ImGuiCol
                col ImU32
            }
        }
        
        igInputText {CIMGUI_BOOL {
                label     string.utf-8
                buf       {chars.utf-8[buf_size] inout}
                buf_size  {size_t                                {default 512}}
                flags     {ImGuiInputTextFlags                   {default 0}}
                callback  {pointer.ImGuiInputTextCallback nullok {default NULL}}
                user_data {pointer nullok                        {default NULL}}
            }
        }
        
        igPopStyleColor {void {
                count {int {default 1}}
            }
        }
        
        igPushStyleVar_Vec2 {void {
                idx ImGuiStyleVar
                val struct.ImVec2
            }
        }
        
        igSameLine {void {
                offset_from_start_x {float {default 0.0}}
                spacing             {float {default -1.0}}
            }
        }
        
        igColorEdit4 {CIMGUI_BOOL {
                label string.utf-8
                col   {float[4] inout}
                flags {ImGuiColorEditFlags {default 0}}
            }
        }
        
        igColorPicker4 {CIMGUI_BOOL {
                label   string.utf-8
                col     {float[4] inout}
                flags   {ImGuiColorEditFlags  {default 0}}
                ref_col {pointer.float nullok {default NULL}}
            }
        }
        
        ImFontAtlas_AddFontFromFileTTF {pointer.ImFont {
                self         {pointer.ImFontAtlas unsafe}
                filename     string.utf-8
                size_pixels  {float {default 0.0}}
                font_cfg     {pointer.ImFontConfig nullok {default NULL}}
                glyph_ranges {pointer.ImWchar      nullok {default NULL}}
            }
        }

        ImFontAtlas_AddFontDefault {pointer.ImFont {
                self         pointer.ImFontAtlas
                font_cfg     {pointer.ImFontConfig nullok {default NULL}}
            }
        }

        ImFontAtlas_ImFontAtlas {pointer.ImFontAtlas {}}

        igColorConvertRGBtoHSV {void {
                r     float
                g     float
                b     float
                out_h {float out}
                out_s {float out}
                out_v {float out}
            }
        }
        
        igCheckbox {CIMGUI_BOOL {
                label string.utf-8
                vOut  {ImBool inout}
            }
        }
        
        igRadioButton_IntPtr {CIMGUI_BOOL {
                label    string.utf-8
                v        {int inout}
                v_button int
            }
        }
      
        igSetNextItemWidth {void {
                item_width float
            }
        }
        
        igDragFloat {CIMGUI_BOOL {
                label   string.utf-8
                v       {float inout}
                v_speed {float            {default 1.0}}
                v_min   {float            {default 0.0}}
                v_max   {float            {default 0.0}}
                format  {string.utf-8           {default "%.3f"}}
                flags   {ImGuiSliderFlags {default 0}}
            }
        }

        igCheckboxFlags_UintPtr {CIMGUI_BOOL {
                label       string.utf-8
                flags       {uint inout}
                flags_value uint
            }
        }
        
        igSliderInt {CIMGUI_BOOL {
                label  string.utf-8
                v      {int inout}
                v_min  int
                v_max  int
                format {string.utf-8           {default "%d"}}
                flags  {ImGuiSliderFlags {default 0}}
            }
        }
   
        igDragScalarN {CIMGUI_BOOL {
                label      string.utf-8
                data_type  ImGuiDataType
                p_data     pointer
                components int
                v_speed    {float               {default 1.0}}
                p_min      {pointer nullok      {default NULL}}
                p_max      {pointer nullok      {default NULL}}
                format     {string.utf-8 nullifempty  {default ""}}
                flags      {ImGuiSliderFlags    {default 0}}
            }
        }

        igBulletText {void {
                fmt string.utf-8
                ...
            }
        }

        igSetDragDropPayload {CIMGUI_BOOL {
                type string.utf-8
                data {pointer nullok}
                sz   size_t
                cond {ImGuiCond {default 0}}
            }
        }

        igTextUnformatted {void {
                text     string.utf-8
                text_end {string.utf-8 nullifempty {default ""}}
            }
        }

        igAcceptDragDropPayload {{pointer.ImGuiPayload nullok} {
                type  string.utf-8
                flags {ImGuiDragDropFlags {default 0}}
            }
        }
        
        igIsWindowFocused {CIMGUI_BOOL {
                flags {ImGuiFocusedFlags {default 0}}
            }
        }
        
        igBeginTable {CIMGUI_BOOL {
                str_id      string.utf-8
                column      int
                flags       {ImGuiTableFlags bitmask {default 0}}
                outer_size  {struct.ImVec2           {default {x 0 y 0}}}
                inner_width {float                   {default 0.0}}
            }
        }
        
        igTableSetupColumn {void {
                label                string.utf-8
                flags                {ImGuiTableColumnFlags {default 0}}
                init_width_or_weight {float                 {default 0.0}}
                user_id              {ImGuiID               {default 0}}
            }
        }
        
        igTableNextRow {void {
                row_flags      {ImGuiTableRowFlags {default 0}}
                min_row_height {float              {default 0.0}}
            }
        }
        
        igTableSetColumnIndex {CIMGUI_BOOL {
                column_n int
            }
        }
        
        igText {void {
                fmt string.utf-8
                ...
            }
        }

        igIsMouseClicked_Bool {CIMGUI_BOOL {
                button ImGuiMouseButton
                repeat {ImBool {default 0}}
            }
        }

        igIndent   {void {indent_w {float {default 0.0}}}}
        igUnindent {void {indent_w {float {default 0.0}}}}

        igGetContentRegionAvail {struct.ImVec2 {}}

        igSliderInt2 {CIMGUI_BOOL {
                label  string.utf-8
                v      {int[2] inout}
                v_min  int
                v_max  int
                format {string.utf-8     {default "%d"}}
                flags  {ImGuiSliderFlags {default 0}}
            }
        }

        igCombo_Str_arr {CIMGUI_BOOL {
                label                     string.utf-8
                current_item              {int inout}
                items                     string.utf-8[items_count]
                items_count               int
                popup_max_height_in_items {int {default -1}}
            }
        }

        igBeginDisabled {void {
                disabled {ImBool {default 1}}
            }
        }

        igEndDisabled {void {}}

        igTextDisabled {void {
                fmt string.utf-8
                ...
            }
        }

        igLabelText {void {
                label string.utf-8
                fmt   string.utf-8
                ...
            }
        }

        igGetTextLineHeight {float {}}

        igDragFloat2 {CIMGUI_BOOL {
                label   string.utf-8
                v       {float[2] inout}
                v_speed {float            {default 1.0}}
                v_min   {float            {default 0.0}}
                v_max   {float            {default 0.0}}
                format  {string.utf-8           {default "%.3f"}}
                flags   {ImGuiSliderFlags {default 0}}
            }
        }

        igDragFloat4 {CIMGUI_BOOL {
                label   string.utf-8
                v       {float[4] inout}
                v_speed {float            {default 1.0}}
                v_min   {float            {default 0.0}}
                v_max   {float            {default 0.0}}
                format  {string.utf-8           {default "%.3f"}}
                flags   {ImGuiSliderFlags {default 0}}
            }
        }

        igDragFloatRange2 {CIMGUI_BOOL {
                label         string.utf-8
                v_current_min {float inout}
                v_current_max {float inout}
                v_speed       {float            {default 1.0}}
                v_min         {float            {default 0.0}}
                v_max         {float            {default 0.0}}
                format        {string.utf-8           {default "%.3f"}}
                format_max    {string.utf-8 nullifempty {default ""}}
                flags         {ImGuiSliderFlags {default 0}}
            }
        }
        
        igPushID_Int {void {
                int_id int
            }
        }
        

        ImGuiIO_AddFocusEvent {void {
                self    pointer.ImGuiIO
                focused ImBool
            }
        }
        
        ImGuiIO_AddMouseButtonEvent {void {
                self   pointer.ImGuiIO
                button int
                down   ImBool
            }
        }
        
        ImGuiIO_AddInputCharacter {void {
                self pointer.ImGuiIO
                c    uint
            }
        }
        
        igPushFont {void {
                font                    {pointer.ImFont nullok}
                font_size_base_unscaled {float {default 0.0}}
            }
        }
        
        igPopFont {void {}}


        igGetFont     {pointer.ImFont {}}
        igGetFontSize {float {}}
    }
    
    
    # Renderer backend (OpenGL3) : the OpenGL context is provided by TkGL,
    # inputs are sent by implottk (see input.tcl).
    append funcs {
        ImGui_ImplOpenGL3_NewFrame {void {}}
        ImGui_ImplOpenGL3_Shutdown {void {}}

        ImGui_ImplOpenGL3_Init {CIMGUI_BOOL {
                glsl_version {string.utf-8 nullifempty {default ""}}
            }
        }

        ImGui_ImplOpenGL3_RenderDrawData {void {
                draw_data pointer.ImDrawData
            }
        }

        ImGuiIO_AddMousePosEvent {void {
                self pointer.ImGuiIO
                x    float
                y    float
            }
        }

        ImGuiIO_AddMouseWheelEvent {void {
                self    pointer.ImGuiIO
                wheel_x float
                wheel_y float
            }
        }

        ImGuiIO_AddInputCharactersUTF8 {void {
                self pointer.ImGuiIO
                str  string.utf-8
            }
        }

        igGetBackgroundDrawList_Nil {pointer.ImDrawList {}}

        ImDrawList_AddRectFilled {void {
                self     pointer.ImDrawList
                p_min    struct.ImVec2
                p_max    struct.ImVec2
                col      ImU32
                rounding {float       {default 0.0}}
                flags    {ImDrawFlags {default 0}}
            }
        }

        igColorConvertFloat4ToU32 {ImU32 {
                in struct.ImVec4
            }
        }

        igGetMouseCursor {ImGuiMouseCursor {}}
    }
    
    return $funcs
}

imgui::initprocFunc [imgui::init]

