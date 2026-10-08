# Copyright (c) 2022-2026 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.

# Tk -> Dear ImGui inputs (platform independent 'platform backend').
# The events of the TkGL widget are sent to the ImGui IO of the widget.

namespace eval ::implottk {

    # Tk keysym -> ImGuiKey
    variable keymap {
        Tab          ImGuiKey_Tab          Left        ImGuiKey_LeftArrow
        Right        ImGuiKey_RightArrow   Up          ImGuiKey_UpArrow
        Down         ImGuiKey_DownArrow    Prior       ImGuiKey_PageUp
        Next         ImGuiKey_PageDown     Home        ImGuiKey_Home
        End          ImGuiKey_End          Insert      ImGuiKey_Insert
        Delete       ImGuiKey_Delete       BackSpace   ImGuiKey_Backspace
        space        ImGuiKey_Space        Return      ImGuiKey_Enter
        Escape       ImGuiKey_Escape       apostrophe  ImGuiKey_Apostrophe
        comma        ImGuiKey_Comma        minus       ImGuiKey_Minus
        period       ImGuiKey_Period       slash       ImGuiKey_Slash
        semicolon    ImGuiKey_Semicolon    equal       ImGuiKey_Equal
        bracketleft  ImGuiKey_LeftBracket  backslash   ImGuiKey_Backslash
        bracketright ImGuiKey_RightBracket grave       ImGuiKey_GraveAccent
        Caps_Lock    ImGuiKey_CapsLock     Scroll_Lock ImGuiKey_ScrollLock
        Num_Lock     ImGuiKey_NumLock      Print       ImGuiKey_PrintScreen
        Pause        ImGuiKey_Pause        Menu        ImGuiKey_Menu
        App          ImGuiKey_Menu         less        ImGuiKey_Oem102
        KP_Decimal   ImGuiKey_KeypadDecimal  KP_Divide   ImGuiKey_KeypadDivide
        KP_Multiply  ImGuiKey_KeypadMultiply KP_Subtract ImGuiKey_KeypadSubtract
        KP_Add       ImGuiKey_KeypadAdd      KP_Enter    ImGuiKey_KeypadEnter
        KP_Equal     ImGuiKey_KeypadEqual
        Shift_L      ImGuiKey_LeftShift    Shift_R     ImGuiKey_RightShift
        Control_L    ImGuiKey_LeftCtrl     Control_R   ImGuiKey_RightCtrl
        Alt_L        ImGuiKey_LeftAlt      Alt_R       ImGuiKey_RightAlt
        Option_L     ImGuiKey_LeftAlt      Option_R    ImGuiKey_RightAlt
        Super_L      ImGuiKey_LeftSuper    Super_R     ImGuiKey_RightSuper
        Meta_L       ImGuiKey_LeftSuper    Meta_R      ImGuiKey_RightSuper
        Win_L        ImGuiKey_LeftSuper    Win_R       ImGuiKey_RightSuper
        Command      ImGuiKey_LeftSuper
    }

    # ImGuiKey -> modifier
    variable modmap {
        ImGuiKey_LeftShift ImGuiMod_Shift ImGuiKey_RightShift ImGuiMod_Shift
        ImGuiKey_LeftCtrl  ImGuiMod_Ctrl  ImGuiKey_RightCtrl  ImGuiMod_Ctrl
        ImGuiKey_LeftAlt   ImGuiMod_Alt   ImGuiKey_RightAlt   ImGuiMod_Alt
        ImGuiKey_LeftSuper ImGuiMod_Super ImGuiKey_RightSuper ImGuiMod_Super
    }

    # ImGuiMouseCursor -> Tk cursor
    variable cursormap {
        ImGuiMouseCursor_Arrow      {}
        ImGuiMouseCursor_TextInput  xterm
        ImGuiMouseCursor_ResizeAll  fleur
        ImGuiMouseCursor_ResizeNS   sb_v_double_arrow
        ImGuiMouseCursor_ResizeEW   sb_h_double_arrow
        ImGuiMouseCursor_ResizeNESW bottom_left_corner
        ImGuiMouseCursor_ResizeNWSE bottom_right_corner
        ImGuiMouseCursor_Hand       hand2
        ImGuiMouseCursor_Wait       watch
        ImGuiMouseCursor_Progress   watch
        ImGuiMouseCursor_NotAllowed X_cursor
        ImGuiMouseCursor_None       none
    }

    # Tk button -> ImGui mouse button (0 left, 1 right, 2 middle).
    # Since Tk 9 (TIP 474) the numbering is the same on every platform.
    variable buttonmap {1 0 2 2 3 1}
}

proc ::implottk::tkKeyToImGui {keysym} {
    # Converts a Tk keysym to an ImGuiKey name.
    #
    # keysym - Tk keysym (%K)
    #
    # Returns ImGuiKey name or "" if unknown
    variable keymap

    if {[dict exists $keymap $keysym]} {
        return [dict get $keymap $keysym]
    }
    if {[regexp {^[a-zA-Z0-9]$} $keysym]} {
        return ImGuiKey_[string toupper $keysym]
    }
    if {[regexp {^F([1-9]|1[0-9]|2[0-4])$} $keysym]} {
        return ImGuiKey_$keysym
    }
    if {[regexp {^KP_([0-9])$} $keysym -> n]} {
        return ImGuiKey_Keypad$n
    }
    return ""
}

proc ::implottk::onKey {oow down keysym char} {
    # Key press / release
    #
    # oow    - frame object
    # down   - 1 if pressed
    # keysym - Tk keysym (%K)
    # char   - character (%A)
    #
    # Returns nothing
    variable modmap
    set io [$oow getIo]
    if {$io eq ""} {return}
    $oow redraw

    set key [tkKeyToImGui $keysym]
    if {$key ne ""} {
        if {[dict exists $modmap $key]} {
            imgui::IO_AddKeyEvent $io [dict get $modmap $key] $down
        }
        imgui::IO_AddKeyEvent $io $key $down
    }

    # Text input (printable characters only)
    if {$down && $char ne "" && [string is print -strict $char]} {
        imgui::IO_AddInputCharactersUTF8 $io $char
    }

    return {}
}

proc ::implottk::updateModifiers {io state} {
    # Updates the Shift / Ctrl modifiers from the state of a mouse event
    # (%s) : the key events are only received by the widget with the focus,
    # a modifier pressed before the first click would be lost.
    # Dear ImGui ignores the events that don't change the state.
    #
    # io    - ImGui IO
    # state - Tk event state (%s)
    #
    # Returns nothing
    if {![string is integer -strict $state]} {return}
    imgui::IO_AddKeyEvent $io ImGuiMod_Shift [expr {($state & 1) != 0}]
    imgui::IO_AddKeyEvent $io ImGuiMod_Ctrl  [expr {($state & 4) != 0}]
    return {}
}

proc ::implottk::onMouseButton {oow button down x y {state ""}} {
    # Mouse button press / release
    variable buttonmap
    set io [$oow getIo]
    if {$io eq ""} {return}
    $oow redraw
    updateModifiers $io $state
    if {![dict exists $buttonmap $button]} {return}

    imgui::IO_AddMousePosEvent    $io $x $y
    imgui::IO_AddMouseButtonEvent $io [dict get $buttonmap $button] $down

    return {}
}

proc ::implottk::onMouseWheel {oow delta {horizontal 0} {state ""}} {
    # Mouse wheel, Tk 9 gives a delta of 120 per notch on every platform.
    set io [$oow getIo]
    if {$io eq ""} {return}
    $oow redraw
    updateModifiers $io $state

    set d [expr {$delta / 120.0}]
    if {$horizontal} {
        imgui::IO_AddMouseWheelEvent $io $d 0.0
    } else {
        imgui::IO_AddMouseWheelEvent $io 0.0 $d
    }
    return {}
}

proc ::implottk::onMotion {oow x y {state ""}} {
    set io [$oow getIo]
    if {$io eq ""} {return}
    $oow redraw
    updateModifiers $io $state
    imgui::IO_AddMousePosEvent $io $x $y
    return {}
}

proc ::implottk::onLeave {oow} {
    # The mouse is no longer over the widget (-FLT_MAX).
    set io [$oow getIo]
    if {$io eq ""} {return}
    $oow redraw
    imgui::IO_AddMousePosEvent $io -3.4028234663852886e+38 -3.4028234663852886e+38
    return {}
}

proc ::implottk::onFocus {oow focused} {
    set io [$oow getIo]
    if {$io eq ""} {return}
    $oow redraw
    imgui::IO_AddFocusEvent $io $focused
    return {}
}

proc ::implottk::bindInputs {w oow} {
    # Binds the Tk events of the widget to ImGui.
    #
    # w   - TkGL widget
    # oow - frame object
    #
    # Returns nothing

    bind $w <Motion>        [list implottk::onMotion $oow %x %y %s]
    bind $w <Leave>         [list implottk::onLeave  $oow]
    bind $w <ButtonPress>   [list apply {{w oow b x y s} {
        focus $w
        implottk::onMouseButton $oow $b 1 $x $y $s
    }} %W $oow %b %x %y %s]
    bind $w <ButtonRelease> [list implottk::onMouseButton $oow %b 0 %x %y %s]

    bind $w <MouseWheel>       [list implottk::onMouseWheel $oow %D 0 %s]
    bind $w <Shift-MouseWheel> [list implottk::onMouseWheel $oow %D 1 %s]

    bind $w <KeyPress>   [list implottk::onKey $oow 1 %K %A]
    bind $w <KeyRelease> [list implottk::onKey $oow 0 %K %A]

    bind $w <FocusIn>  [list implottk::onFocus $oow 1]
    bind $w <FocusOut> [list implottk::onFocus $oow 0]

    return {}
}

proc ::implottk::updateCursor {w} {
    # Applies the mouse cursor requested by ImGui to the Tk widget.
    #
    # w - TkGL widget
    #
    # Returns nothing
    variable cursormap
    variable cursors

    set cursor [imgui::GetMouseCursor]
    if {[string is integer -strict $cursor]} {
        set cursor [cffi::enum name ::imgui::ImGuiMouseCursor_ $cursor ImGuiMouseCursor_Arrow]
    }
    set tkcursor [dict getdef $cursormap $cursor {}]

    if {![info exists cursors($w)] || $cursors($w) ne $tkcursor} {
        set cursors($w) $tkcursor
        catch {$w configure -cursor $tkcursor}
    }
    return {}
}
