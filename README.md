# implot.Tk
Tcl/Tk bindings for [ImPlot](https://github.com/epezent/implot)
and [ImPlot3D](https://github.com/brenocq/implot3d) : fast interactive 2D / 3D plots (GPU, OpenGL)
in a Tk widget.

## Dependencies
- [Tcl/Tk](https://www.tcl-lang.org) >= 9.0
- [Tcl cffi](https://cffi.magicsplat.com) >= 2.0
- [TkGL](https://github.com/3-manifolds/TkGL) : OpenGL widget for Tk
- A C library with through [cimgui](https://github.com/cimgui/cimgui),
  [cimplot](https://github.com/cimgui/cimplot) and [cimplot3d](https://github.com/cimgui/cimplot3d)

## Cross-Platform
- Windows, Linux, macOS support.

## Installation
- Download the package of your platform from the [GitHub Releases](https://github.com/nico-robert/implot.tk/releases) :
  it contains `implot.tk`, the C library and `TkGL` built for Tcl/Tk 9.
- Or build everything yourself, see [lib/BUILD.md](lib/BUILD.md).

## Quick start
```tcl
package require implot.tk

# 1. Creates the surface (no Tk widget yet) and sets its options.
set f [implottk::surface new]
$f SetOptions -width 600 -height 400 -title "Line" -axisName {x y}

# 2. Adds the commands, evaluated at each frame.
$f AddPlotCmd {
    implottk::static {
        set xs [implottk::doubleToPointer {0 1 2 3 4}]
        set ys [implottk::doubleToPointer {0 1 0.5 4 1}]
    }
    implot::PlotLine_doublePtrdoublePtr "Line 1" $xs $ys 5 {LineColor {x 1 y 0 z 0 w 1}}
}

# 3. Render creates the Tk widget and returns its path, 4. pack it.
pack [$f Render] -fill both -expand 1
```

## Options of the surface

| Option | Value | Default
| ------ | ------ | ------
| `-width`, `-height` | size of the widget (pixels) | 600, 400
| `-title`            | title of the plot added by the surface (`##...` : hidden) | `##title`
| `-axisName`         | names of the axes `{x y}` of the plot added by the surface | `{}`
| `-background`       | color of the window `{r g b}`, `{}` : color of the theme | `{}`
| `-color`            | ImGui colors `{windowBackground {r g b} popupBackground {r g b} text {r g b}}` | -
| `-colorPlot`        | ImPlot colors `{plotBackground .. frameBackground .. axisText .. legendBackground .. legendText ..}` | -
| `-fonts`            | `{file.ttf size}`, or a Tk font `{TkDefaultFont ?size?}` | ImGui font
| `-idleFps`          | frames per second without event | 10
| `-framebufferScale` | pixels per Tk unit (e.g. 2.0 on a retina display) | 1.0

## Scripts

> [!NOTE]
> `Dear ImGui` is an *immediate mode* GUI : the scripts are evaluated at each frame, `AddGuiCmd`
> scripts first (widgets : sliders, checkboxes...), then `AddPlotCmd` scripts (plots). Every function
> declared in *src/imgui/funcs.tcl*, *src/implot/funcs.tcl* and *src/implot3d/funcs.tcl* can be called.

The style of an item is an `ImPlotSpec`, written as a dictionary (missing fields keep their
default value) :

```tcl
implot::PlotLine_doublePtrdoublePtr "Line 2" $xs $ys 5 {
    LineColor  {x 0 y 0.5 z 1 w 1}
    LineWeight 2
    Marker     ImPlotMarker_Circle
    Flags      ImPlotLineFlags_Segments
}
```

When a script calls `implot::BeginPlot` itself, the other `ImPlot` functions must only be called
when it returns true.

### Variables of the scripts :
`implottk::static` initializes the data only the first time :

```tcl
$f AddPlotCmd {
    # a script evaluated only the first time...
    implottk::static {
        set rectXMin 0.0025 ; set rectYMin 0.0
        set rectXMax 0.0045 ; set rectYMax 0.5
    }
    # ... or pairs 'name value'.
    implottk::static flags 0

    imgui::CheckboxFlags_UintPtr "NoCursors" flags 1
    if {[implot::BeginPlot "##Main"]} {
        implot::DragRect 0 rectXMin rectYMin rectXMax rectYMax {x 1 y 0 z 1 w 1} $flags clicked hovered held
        implot::EndPlot
    }
}
```

## Supported plots
- [x] line, shaded, scatter, stairs, stems, infinite lines
- [x] bars (vertical / horizontal / stacked, groups), error bars
- [x] pie charts, heatmaps, 1D / 2D histograms
- [x] bubbles, polygons, digital plots, text, dummy
- [x] getters (*PlotLineG*)
- [ ] images
- [x] 3D (*ImPlot3D*) : line, scatter, triangle, quad, surface and mesh plots, text

## Examples
See [demo](demo/) folder.

## Known issues
- macOS : On a retina display set `-framebufferScale 2.0` (not tested yet).
- Calling an `ImPlot` function outside of a plot (when `BeginPlot` returned false) can crash
  the application.
- And probably many others...

## Inspiration
- [opengl-tcltk](https://github.com/codeplea/opengl-tcltk)
- [Tcl cffi examples](https://github.com/apnadkarni/tcl-cffi/tree/main/examples)

## License

**implot.tk** is covered under the terms of the [MIT](LICENSE) license.
The packages also contain Dear ImGui, ImPlot, ImPlot3D, cimgui, cimplot, cimplot3d and TkGL, under
their own licenses : see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Release
*  **15-Sep-2022** : 1.0b0
*  **19-Sep-2022** : 1.0b1
    - Add _SubplotsSizing_ + _SubplotItemSharing_ (drag & drop) demo.
    - Cosmetic changes + adding `imgui` functions.
*  **01-Oct-2022** : 1.0b2
    - Add examples.
    - Fix bug when my frame was mapped or unmapped.
    - Rename `win32.tcl` file by `user32.tcl`
*  **08-Oct-2026** : 1.0
    - Full redesign of the library.
    - More examples and GitHub Actions.