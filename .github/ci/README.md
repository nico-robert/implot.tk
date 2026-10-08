# CI scripts

Used only by the GitHub Actions workflow ([build.yml](../workflows/build.yml)), never needed
to use or develop `implottk` locally.

The GitHub runners don't have Tcl/Tk 9, cffi and TkGL : these scripts build them from source
(the result is cached between the runs) :

- `build_deps.sh` : Linux and macOS (universal binaries on macOS).
- `build_deps.bat` : Windows (MSVC).
- `tkgl-windows.patch` : fix of TkGL on Windows (crash when the widget is mapped with some
  OpenGL drivers), applied until TkGL includes it.

The versions are set at the top of `build.yml` (`TCL_TAG`, `CFFI_TAG`, `TKGL_REF`).
