# Copyright (c) 2022-2026 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

# The drawing surface is a TkGL widget (https://github.com/3-manifolds/TkGL) :
# TkGL provides the OpenGL context on every platform, Dear ImGui renders with
# its OpenGL3 backend and the inputs come from Tk bindings (see input.tcl).
# Each surface has its own ImGui / ImPlot / ImPlot3D contexts.

namespace eval ::implottk {

    # Size of the widget when -width / -height are not given.
    variable imFrame {width 600 height 400}

    # GLSL version for an OpenGL 3.2 core profile (Windows, Linux, macOS).
    variable glslVersion "#version 150"

    # class surface
    oo::class create surface {
        variable _cmdplot           ; # list commands implot
        variable _cmdimgui          ; # list commands imgui
        variable _cmdstyle          ; # list commands imgui style
        variable _lenCmdstyle       ; # len  commands imgui style
        variable _cmdplotstyle      ; # configure style plot
        variable _lencmdplotstyle   ; # len commands implot style
        variable _titleplot         ; # title plot (default not visible)
        variable _axisnames         ; # axis names (implot::SetupAxes)
        variable _io                ; # imgui IO
        variable _font              ; # font {pathname size}
        variable _w                 ; # Tk path of the TkGL widget
        variable _ctx               ; # imgui context
        variable _ctxplot           ; # implot context
        variable _ctxplot3d         ; # implot3d context
        variable _afterId           ; # render loop 'after' id
        variable _time              ; # time of the last frame (microseconds)
        variable _background        ; # window background color {r g b} or {} (theme)
        variable _width             ; # requested width of the widget
        variable _height            ; # requested height of the widget
        variable _fbScale           ; # framebuffer scale (HiDPI)
        variable _backend           ; # 1 if the OpenGL3 backend is initialized
        variable _running           ; # 1 while the render loop runs (widget mapped)
        variable _next              ; # time of the next frame (milliseconds)
        variable _lastEvent         ; # time of the last event (milliseconds)
        variable _idleFps           ; # frames per second without event (0 : none)

        superclass plot imgui

        constructor {} {
            # Creates a surface.
            set _cmdplot         {}
            set _cmdimgui        {}
            set _cmdstyle        {}
            set _cmdplotstyle    {}
            set _font            {}
            set _lenCmdstyle     0
            set _lencmdplotstyle 0
            set _titleplot       "##title"
            set _axisnames       {}
            set _io              {}
            set _w               {}
            set _ctx             {}
            set _ctxplot         {}
            set _afterId         {}
            set _time            0
            set _background      {}
            set _width           [dict get $::implottk::imFrame width]
            set _height          [dict get $::implottk::imFrame height]
            set _fbScale         1.0
            set _backend         0
            set _running         0
            set _next            0
            set _lastEvent       0
            set _idleFps         10

            my CreateContexts
        }

        destructor {
            my Stop
            if {$_ctx eq ""} {return}
            if {$_w ne "" && [winfo exists $_w]} {
                bind $_w <Destroy> {}
                catch {$_w makecurrent}
            }
            my MakeCurrent
            if {$_backend} {imgui::ImplOpenGL3_Shutdown}
            implot3d::DestroyContext $_ctxplot3d
            implot::DestroyContext $_ctxplot
            imgui::DestroyContext  $_ctx
            # The widget is destroyed with the surface ($oow destroy).
            if {$_w ne "" && [winfo exists $_w]} {catch {destroy $_w}}
        }
    }

    oo::define surface {
        method title {} {
            return $_titleplot
        }

        method SetOptions {args} {
            # Sets options of the surface.
            #
            # args - option value ... (see README) :
            #   -width -height -fonts -background -color -colorPlot
            #   -title -axisName -idleFps -framebufferScale
            #
            # Returns nothing
            if {[llength $args] % 2} {
                error "wrong # args : should be 'SetOptions ?option value ...?'"
            }

            foreach {key value} $args {
                if {$value eq "" && $key ni {-background -title -axisName}} {
                    error "No value specified for key '$key'"
                }

                switch -exact -- $key {
                    -width - -height {
                        if {![string is integer -strict $value] || $value <= 0} {
                            error "$key should be an integer greater than 0"
                        }
                        set [string map {- _} $key] $value
                        if {$_w ne ""} {$_w configure $key $value}
                    }
                    -fonts {
                        # {file size} : a font file (TTF/OTF) and its size in pixels.
                        # {tkfont ?size?} : a Tk font (TkDefaultFont...), its
                        # file is searched (see tkfont.tcl), the size is the
                        # size of the Tk font if not given.
                        if {[llength $value] ni {1 2}} {
                            error {
                                list value should be -fonts [list 'fullpathname' 'size'] or [list 'tkfont' ?size?]
                            }
                        }

                        lassign $value pathname size

                        if {![file exists $pathname]} {
                            # A path of a font file must exist ('font actual'
                            # accepts any family name).
                            if {[string tolower [file extension $pathname]] in {.ttf .otf .ttc} ||
                                [catch {font actual $pathname}]} {
                                error "$pathname doesn't exists (font file or Tk font)..."
                            }
                            set tkfont $pathname
                            set pathname [implottk::tkFontFile $tkfont]
                            if {$size eq ""} {set size [implottk::tkFontSize $tkfont]}
                            if {$pathname eq ""} {
                                # Default ImGui font.
                                puts stderr "implottk : file of the Tk font '$tkfont'\
                                    ([font actual $tkfont -family]) not found,\
                                    default font used."
                                continue
                            }
                        }

                        if {![string is double -strict $size] || $size <= 0} {
                            error "Size font should be greater than 0"
                        }
                        set _font [list $pathname $size]
                        if {$_backend} {my LoadFont}
                    }
                    -background {
                        # Color of the window background {r g b}, {} : color
                        # of the ImGui theme.
                        if {[llength $value] ni {0 3}} {
                            error "list background should be equal to 3..."
                        }
                        set _background $value
                    }
                    -framebufferScale {
                        # Pixels per Tk unit (e.g. 2.0 on a macOS retina display).
                        if {![string is double -strict $value] || $value <= 0} {
                            error "framebufferScale should be greater than 0"
                        }
                        set _fbScale $value
                    }
                    -color {

                        set _options [dict create]

                        foreach {keycolor valuecolor} $value {
                            if {$valuecolor eq ""} {
                                error "No value specified for subkey '$keycolor'"
                            }

                            if {[llength $valuecolor] != 3} {
                                error "list color should be equal to 3..."
                            }

                            switch -exact -- $keycolor {
                                windowBackground {dict set _options ImGuiCol_WindowBg $valuecolor}
                                popupBackground  {dict set _options ImGuiCol_PopupBg  $valuecolor}
                                text             {dict set _options ImGuiCol_Text     $valuecolor}
                                default          {error "Unknown subkey '$keycolor' specified"}
                            }
                        }

                        set _cmdstyle {}

                        dict for {key info} $_options {
                            lappend _cmdstyle [list imgui::PushStyleColor_Vec4 $key [implottk::rgbaToVec4 $info]]
                        }

                        set _lenCmdstyle [llength $_cmdstyle]

                    }

                    -colorPlot {
                        set _options [dict create]

                        foreach {keycolor valuecolor} $value {
                            if {$valuecolor eq ""} {
                                error "No value specified for subkey '$keycolor'"
                            }

                            if {[llength $valuecolor] != 3} {
                                error "list colorPlot should be equal to 3..."
                            }

                            switch -exact -- $keycolor {
                                plotBackground   {dict set _options ImPlotCol_PlotBg     $valuecolor}
                                frameBackground  {dict set _options ImPlotCol_FrameBg    $valuecolor}
                                axisText         {dict set _options ImPlotCol_AxisText   $valuecolor}
                                legendBackground {dict set _options ImPlotCol_LegendBg   $valuecolor}
                                legendText       {dict set _options ImPlotCol_LegendText $valuecolor}
                                default          {error "Unknown subkey '$keycolor' specified"}
                            }
                        }

                        set _cmdplotstyle {}

                        dict for {key info} $_options {
                            lappend _cmdplotstyle [list implot::PushStyleColor_Vec4 $key [implottk::rgbaToVec4 $info]]
                        }

                        set _lencmdplotstyle [llength $_cmdplotstyle]
                    }

                    -idleFps {
                        # Frames per second when there is no event (mouse,
                        # keyboard...) : 0 renders only on events and
                        # 'redraw', 60 renders all the time (animations).
                        if {![string is double -strict $value] || $value < 0} {
                            error "idleFps should be greater than or equal to 0"
                        }
                        set _idleFps $value
                    }
                    -title {set _titleplot $value}
                    -axisName {
                        # Names of the axes {x y} of the plot added by the
                        # surface ({} : none), set up before the commands.
                        if {[llength $value] ni {0 2}} {
                            error "label Axis should be equal to 2..."
                        }
                        set _axisnames $value
                    }

                    default {error "Unknown key '$key' specified"}
                }
            }

            my redraw
            return {}
        }

        method redraw {} {
            # Asks for a new frame as soon as possible : called on every
            # input event, and by the application when its data change.
            #
            # Returns nothing
            set _lastEvent [clock milliseconds]
            if {!$_running} {return}
            if {$_afterId eq "" || $_next > $_lastEvent + 16} {
                after cancel $_afterId
                set _next $_lastEvent
                set _afterId [after 0 [namespace code {my Frame}]]
            }
            return {}
        }

        method getIo {} {
            # Access the IO structure
            # (mouse/keyboard/gamepad inputs, time, various configuration options/flags)
            #
            # Returns IO struct
            return $_io
        }

        method widget {} {
            # Returns the Tk path of the TkGL widget ("" before Render).
            return $_w
        }

        method Render {args} {
            # Creates the Tk widget of the surface the first time, then asks
            # for a new frame.
            #
            # args - Optional '-parent path' : Tk parent of the widget
            #        (default : toplevel '.'), used on the first call only.
            #
            # Returns the Tk path of the widget (to pack, grid...).
            set parent ""
            foreach {key value} $args {
                if {$key ne "-parent" || [llength $args] % 2} {
                    error "wrong # args or unknown option '$key',\
                           should be \"[self] Render ?-parent path?\""
                }
                set parent $value
            }
            if {($parent ne "") && ![winfo exists $parent]} {
                error "bad window path name \"$parent\""
            }
            if {$_w eq ""} {
                set parent [string trimright $parent .]
                set w "$parent.implottk[incr ::implottk::count]"
                while {[winfo exists $w]} {
                    set w "$parent.implottk[incr ::implottk::count]"
                }
                my CreateWidget $w
            }
            my redraw
            return $_w
        }

        method CreateWidget {w} {
            # Creates the TkGL widget 'w' of the surface.
            #
            # Returns nothing
            if {$_w ne ""} {error "the widget of the surface is already created ($_w)"}

            # TkGL (Windows) uses the HWND of the parent window as soon as the
            # widget is created, but Tk creates windows lazily : 'winfo id'
            # forces the parent window to exist (otherwise TkGL dereferences
            # a NULL window and crashes).
            set parent [string range $w 0 [string last . $w]-1]
            winfo id [expr {$parent eq "" ? "." : $parent}]

            # OpenGL 3.2 core profile (needed on macOS by the OpenGL3 backend).
            tkgl $w -width $_width -height $_height -profile 3_2 \
                    -double 1 -swapinterval 0
            set _w $w

            # The render loop runs while the widget is mapped.
            bind $w <Map>       [list [self] Start]
            bind $w <Unmap>     [list [self] Stop]
            # Resize, window exposed : new frame.
            bind $w <Configure> [list [self] redraw]
            bind $w <Expose>    [list [self] redraw]
            # The surface is destroyed with its widget.
            bind $w <Destroy>   [list apply {{w oow} {
                if {[info object isa object $oow]} {$oow destroy}
            }} %W [self]]
            return {}
        }

        method cmdPlot {} {
            # Returns commands implot
            return $_cmdplot
        }

        method cmdImGUI {} {
            # Returns commands imgui
            return $_cmdimgui
        }

        method cmdStyle {} {
            # Returns commands imgui style
            return [list $_cmdstyle [list imgui::PopStyleColor $_lenCmdstyle]]
        }

        method cmdplotStyle {} {
            # Returns commands implot style
            return [list $_cmdplotstyle [list implot::PopStyleColor $_lencmdplotstyle]]
        }

        method getFont {} {
            # Returns font {pathname size}
            return $_font
        }

        method MakeCurrent {} {
            # Selects the ImGui / ImPlot / ImPlot3D contexts of this widget.
            imgui::SetCurrentContext    $_ctx
            implot::SetCurrentContext   $_ctxplot
            implot3d::SetCurrentContext $_ctxplot3d
        }

        method CreateContexts {} {
            # Creates the ImGui / ImPlot / ImPlot3D contexts (no OpenGL
            # needed).
            #
            # Returns nothing
            set _ctx       [imgui::CreateContext]
            set _ctxplot   [implot::CreateContext]
            set _ctxplot3d [implot3d::CreateContext]
            my MakeCurrent
            implot::SetImGuiContext $_ctx

            set _io [imgui::GetIO_ContextPtr $_ctx]
            # No 'imgui.ini' file.
            imgui::ImGuiIO setnative $_io IniFilename NULL
            # A Tcl error in a user command must not abort the application :
            # ImGui recovers the missing End() calls without asserting.
            imgui::ImGuiIO setnative $_io ConfigErrorRecoveryEnableAssert 0

            set _time [clock microseconds]
            return {}
        }

        method Init {} {
            # Initializes the OpenGL3 backend, the first time the widget is
            # mapped (the OpenGL context must exist).
            #
            # Returns nothing
            $_w makecurrent
            my MakeCurrent

            if {![imgui::ImplOpenGL3_Init $::implottk::glslVersion]} {
                error "OpenGL3 backend initialization failed"
            }
            set _backend 1

            if {$_font ne ""} {my LoadFont}

            implottk::bindInputs $_w [self]
            set _time [clock microseconds]

            return {}
        }

        method LoadFont {} {
            # Adds the font defined by '-fonts' and makes it the default font.
            my MakeCurrent
            lassign $_font pathname size
            set atlas [imgui::ImGuiIO getnative $_io Fonts]
            set font  [imgui::ImFontAtlas_AddFontFromFileTTF $atlas $pathname $size]
            imgui::ImGuiIO setnative $_io FontDefault $font
            return {}
        }

        method Eval {script} {
            # Evaluates a user script (AddGuiCmd, AddPlotCmd) in the frame
            # of a coroutine owned by the surface : its local variables are
            # kept from one frame to the next (see implottk::static) and
            # shared by all the scripts of the surface.
            #
            # script - script to evaluate.
            #
            # Returns the result of the script.
            set co [self namespace]::userframe
            if {[info commands $co] eq ""} {
                coroutine $co apply {{} {
                    set {#result} {}
                    while 1 {
                        set {#script} [yield ${#result}]
                        set {#code} [catch ${#script} {#msg} {#opts}]
                        set {#result} [list ${#code} ${#msg} ${#opts}]
                    }
                }}
            }
            lassign [$co $script] code msg opts
            if {$code == 1} {return -options $opts $msg}
            return $msg
        }

        method Start {} {
            # Starts the render loop.
            if {!$_backend} {my Init}
            set _running 1
            set _lastEvent [clock milliseconds]
            if {$_afterId eq ""} {my Frame}
            return {}
        }

        method Stop {} {
            # Stops the render loop.
            set _running 0
            if {$_afterId ne ""} {
                after cancel $_afterId
                set _afterId {}
            }
            return {}
        }

        method Frame {} {
            # Renders one frame and schedules the next one.
            #
            # Returns nothing
            set _afterId {}
            set start [clock microseconds]

            set width  [winfo width $_w]
            set height [winfo height $_w]

            $_w makecurrent
            my MakeCurrent

            set now [clock microseconds]
            set dt  [expr {max(($now - $_time) / 1e6, 1e-4)}]
            set _time $now

            imgui::ImGuiIO setnative $_io DisplaySize [list x $width y $height]
            imgui::ImGuiIO setnative $_io DisplayFramebufferScale [list x $_fbScale y $_fbScale]
            imgui::ImGuiIO setnative $_io DeltaTime $dt

            imgui::ImplOpenGL3_NewFrame
            imgui::NewFrame

            # -background : color of the window.
            if {$_background ne ""} {
                imgui::PushStyleColor_Vec4 ImGuiCol_WindowBg [implottk::rgbaToVec4 $_background]
            }

            # add style ImGui if exists...
            foreach colorStyle $_cmdstyle {
                uplevel #0 $colorStyle
            }

            set name "implottk_[self]"
            imgui::Begin $name NULL {
                ImGuiWindowFlags_NoDecoration
                ImGuiWindowFlags_NoMove
                ImGuiWindowFlags_NoSavedSettings
                ImGuiWindowFlags_NoBringToFrontOnFocus
            }

            imgui::SetWindowPos_Str  $name {x 0 y 0} ImGuiCond_None
            imgui::SetWindowSize_Str $name [list x $width y $height] ImGuiCond_None

            # add style Implot if exists...
            foreach colorPlotStyle $_cmdplotstyle {
                uplevel #0 $colorPlotStyle
            }

            # User commands : an error is reported once the frame is ended.
            set err {}
            try {
                # add commands imgui
                my DrawGuiCmd

                # add commands implot
                if {[llength $_cmdplot]} {
                    if {[lsearch -regexp $_cmdplot {implot(3d)?::BeginPlot}] == -1} {
                        # commands implot without 'implot::BeginPlot'
                        # (or 'implot3d::BeginPlot')
                        if {[implot::BeginPlot $_titleplot]} {
                            try {
                                if {[llength $_axisnames]} {
                                    implot::SetupAxes {*}$_axisnames
                                }
                                my DrawPlotCmd
                            } finally {
                                implot::EndPlot
                            }
                        }
                    } else {
                        # commands implot with 'implot::BeginPlot'
                        my DrawPlotCmd
                    }
                }
            } on error {msg opts} {
                set err [list $msg $opts]
            }

            # set style ImPlot if exists...
            if {$_lencmdplotstyle} {implot::PopStyleColor $_lencmdplotstyle}

            imgui::End

            # set style ImGui if exists...
            if {$_lenCmdstyle} {imgui::PopStyleColor $_lenCmdstyle}
            if {$_background ne ""} {imgui::PopStyleColor}

            imgui::Render
            implottk::updateCursor $_w
            imgui::ImplOpenGL3_RenderDrawData [imgui::GetDrawData]

            $_w swapbuffers

            # A 'redraw' asked while this frame was drawn is replaced by the
            # frame scheduled below (only one render loop).
            if {$_afterId ne ""} {
                after cancel $_afterId
                set _afterId {}
            }

            # The render loop stops on error (reported by bgerror), until the
            # widget is mapped again.
            if {$err ne ""} {
                set _running 0
                lassign $err msg opts
                return -options $opts $msg
            }

            # The next frame is scheduled once this one is drawn : 60 frames
            # per second during 0.5 s after an event (ImGui needs a few
            # frames to end an interaction) or while a text is edited, then
            # '-idleFps' frames per second. The period is counted from the
            # start of this frame (the time to draw it is not added to the
            # period), with at least 1 ms for the Tk events and idle tasks.
            set now [clock milliseconds]
            if {($now - $_lastEvent < 500) ||
                [imgui::ImGuiIO getnative $_io WantTextInput]} {
                set period [expr {1000.0 / 60}]
            } elseif {$_idleFps > 0} {
                set period [expr {1000.0 / min($_idleFps, 60)}]
            } else {
                # No frame until the next event or 'redraw'.
                return {}
            }
            set elapsed [expr {([clock microseconds] - $start) / 1000.0}]
            set delay [expr {max(1, round($period - $elapsed))}]
            set _next [expr {$now + $delay}]
            set _afterId [after $delay [namespace code {my Frame}]]

            return {}
        }

        export Start Stop Render SetOptions
    }
}
