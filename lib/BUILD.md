## Build instructions

> Ready to use packages (implot.tk + the C library + TkGL, for Tcl/Tk 9 ; cffi is not included) are built by
> GitHub Actions ([.github/workflows/build.yml](../.github/workflows/build.yml)) for Windows,
> macOS and Linux, and uploaded as artifacts of the run (the GitHub Releases are published by hand).

`implot.tk` needs two compiled components :

1. A C library containing the C API of `Dear ImGui` ([cimgui](https://github.com/cimgui/cimgui)),
   of `ImPlot` ([cimplot](https://github.com/cimgui/cimplot)), of `ImPlot3D`
   ([cimplot3d](https://github.com/cimgui/cimplot3d)) and the `OpenGL3` renderer backend.
2. The [TkGL](https://github.com/3-manifolds/TkGL) Tk extension, which provides the OpenGL
   surface (Windows, macOS, Linux).

No platform backend (Win32, OSX, GLFW...) is needed : the OpenGL context is created by TkGL
and the inputs (mouse, keyboard) are sent by `implot.tk` from the Tk events.

### 1. cimgui + cimplot + cimplot3d library

The [CMakeLists.txt](CMakeLists.txt) of this folder downloads the versions used by the bindings
(`cimgui` 1.92.9b, `cimplot` with `ImPlot` 1.0, `cimplot3d` with `ImPlot3D` 0.4) and builds
the library. It is based on the `CMakeLists.txt` of [cimgui](https://github.com/cimgui/cimgui),
modified for `implot.tk` (cimplot and cimplot3d added, sources downloaded with `FetchContent`,
OpenGL3 backend exported with C names, library names expected by `implot.tk`) :

```
cd lib
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
```

On macOS, for a universal library (arm64 + x86_64, as in the Releases) :

```
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0
```

Requirements : CMake >= 3.18, git and a C++11 compiler
(Visual Studio on Windows, Xcode command line tools on macOS, gcc or clang on Linux).

The library is written in this folder with the name expected by `implot.tk`, and the licenses
of its components in `lib/licenses/` :

| Platform | File |
| ------ | ------
| Windows | `lib/cimgui_win32.dll`
| macOS   | `lib/libcimgui_osx.dylib`
| Linux   | `lib/libcimgui_linux.so`



### 2. TkGL

The packages use the TkGL commit `TKGL_REF` of [build.yml](../.github/workflows/build.yml)
(see the [TkGL build instructions](https://github.com/3-manifolds/TkGL/blob/main/BUILDING)).
Linux and macOS (on macOS, TkGL is always built universal) :

```
git clone https://github.com/3-manifolds/TkGL.git
cd TkGL
autoconf
./configure --with-tcl=/path/to/tcl9/unix --with-tk=/path/to/tk9/unix
make
make install-lib-binaries
```

Windows (Visual Studio command prompt), with the patch of this repository
([.github/ci/tkgl-windows.patch](../.github/ci/tkgl-windows.patch) : crashes with some OpenGL
drivers and when the parent window does not exist yet) :

```
cd TkGL
git apply path\to\implot.tk\.github\ci\tkgl-windows.patch
cd win
nmake TCLDIR=C:\TclTkSrc\tcl9 TKDIR=C:\TclTkSrc\tk9 -f makefile.vc
```

`package require Tkgl` must work in your Tcl/Tk 9 installation. The license of TkGL
(`license.terms`) must be distributed with it : copy it in the installed `Tkgl1.2.1` folder.

### Demos

[.github/ci/run_demo.tcl](../.github/ci/run_demo.tcl) runs a demo for 2 seconds and fails on any
Tcl error (60 s at most) :

```
tclsh .github/ci/run_demo.tcl demo/lineplots.tcl
```

### Updating Dear ImGui / ImPlot / ImPlot3D

1. Copy the generator outputs of cimgui (`generator/output/*.json`) into [generator/json_cimgui](../generator/json_cimgui),
   of cimplot into [generator/json_cimplot](../generator/json_cimplot) and of cimplot3d into
   [generator/json_cimplot3d](../generator/json_cimplot3d), with the headers (`imgui.h`, `imgui_internal.h`,
   `implot.h`, `implot_internal.h`, `implot3d.h`, `implot3d_internal.h`).
   The three generator outputs must come from the same `cimgui` version (same date).
2. Run `tclsh generator/generate.tcl` (Tcl 9 + tcllib), it regenerates the enums, aliases and
   structs (`src/imgui/*.tcl`, `src/implot/*.tcl`, `src/implot3d/*.tcl`).
3. Run `tclsh generator/generate.tcl -check` : it compares the functions declared by hand in
   `src/imgui/funcs.tcl`, `src/implot/funcs.tcl` and `src/implot3d/funcs.tcl` with the new `definitions.json` and lists the
   missing functions and the changes (number and types of the parameters, return type, default
   values). Nothing is generated, the exit code is 1 if differences are found :
   ```
   CHANGED  implot/funcs.tcl : ImPlot_DragLineX
            C : bool ImPlot_DragLineX(int id,double* x,const ImVec4& col,float thickness=1,...)
            - thickness : C 'float', cffi 'double'
   191 functions checked, 1 difference(s).
   ```
4. Update the versions in [CMakeLists.txt](CMakeLists.txt) and `implottk.tcl`.
