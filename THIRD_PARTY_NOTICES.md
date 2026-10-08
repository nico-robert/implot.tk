# Third party notices

`implot.tk` is distributed under the MIT license (see [LICENSE](LICENSE)). The distributions
(GitHub Releases) also contain components of other projects, under their own licenses.

## C library (folder `implot.tk<version>/lib` of the distribution)

Built with [lib/CMakeLists.txt](lib/CMakeLists.txt). The license texts are copied by CMake in
`lib/licenses/` (also in the distribution).

| Component | Copyright | License | Text |
| ------ | ------ | ------ | ------
| [Dear ImGui](https://github.com/ocornut/imgui) 1.92.9b | Omar Cornut | MIT | lib/licenses/imgui.txt
| [ImPlot](https://github.com/epezent/implot) 1.0 | Evan Pezent | MIT | lib/licenses/implot.txt
| [ImPlot3D](https://github.com/brenocq/implot3d) 0.4 | Breno Cunha Queiroz | MIT | lib/licenses/implot3d.txt
| [cimgui](https://github.com/cimgui/cimgui) | Stephan Dilly (maintained by Victor Bombí) | MIT | lib/licenses/cimgui.txt
| [cimplot](https://github.com/cimgui/cimplot) | Victor Bombí | MIT | lib/licenses/cimplot.txt
| [cimplot3d](https://github.com/cimgui/cimplot3d) | Victor Bombí (author, no copyright notice) | none given (see below) | -

**cimplot3d** : its repository has no license file (checked at commit `8d04820`). It is written by
Victor Bombí, author of cimplot (MIT).

Dear ImGui includes `imstb_*.h` ([stb](https://github.com/nothings/stb), MIT or public domain,
license at the end of each file) and `imgui_impl_opengl3_loader.h` (from gl3w, public domain).

## TkGL (folder `Tkgl1.2.1` of the distribution)

[TkGL](https://github.com/3-manifolds/TkGL), Marc Culler, Nathan Dunfield, Matthias Goerner and
others, derived from Togl (Brian Paul, Benjamin Bederson, Greg Couch). BSD-like license : its text
(`license.terms`) must be included verbatim in any distribution, it is in the `Tkgl1.2.1` folder.

On Windows, TkGL is built with a patch (see [lib/BUILD.md](lib/BUILD.md#2-tkgl)).

## Source files in this repository

`generator/json_*` contain copies of the cimgui, cimplot and cimplot3d generator outputs and of the
Dear ImGui, ImPlot and ImPlot3D headers (used by `generator/generate.tcl` only), with their `LICENSE-*.txt`.