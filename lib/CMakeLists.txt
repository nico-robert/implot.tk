# Builds the C library used by implottk :
#   cimgui (Dear ImGui 1.92.9b) + cimplot (ImPlot 1.0) + cimplot3d (ImPlot3D 0.4)
#   + OpenGL3 renderer backend
#
# Usage (from this folder) :
#   cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
#   cmake --build build --config Release
#
# The library is written in this folder with the name expected by implottk :
#   Windows : cimgui_win32.dll | macOS : libcimgui_osx.dylib | Linux : libcimgui_linux.so
#
# Based on the CMakeLists.txt of cimgui (https://github.com/cimgui/cimgui),
# modified for implot.tk : cimplot and cimplot3d added, sources downloaded
# with FetchContent, OpenGL3 backend exported with C names, library names
# and output folder expected by implot.tk, licenses copied in lib/licenses.

cmake_minimum_required(VERSION 3.18)
project(implottk_cimgui CXX)

include(FetchContent)

# Versions of the bindings (see generator/json_cimgui, json_cimplot and json_cimplot3d).
set(CIMGUI_TAG    "1.92.9b"                                  CACHE STRING "cimgui git tag")
set(CIMPLOT_TAG   "11f13e6cd0f80e83d6409e78592b392967fa7954" CACHE STRING "cimplot git commit (ImPlot 1.0)")
set(CIMPLOT3D_TAG "8d04820c009357e791e30a004e410c6eb98522d1" CACHE STRING "cimplot3d git commit (ImPlot3D 0.4)")

FetchContent_Declare(cimgui
    GIT_REPOSITORY https://github.com/cimgui/cimgui.git
    GIT_TAG        ${CIMGUI_TAG}
    GIT_SHALLOW    TRUE
    GIT_SUBMODULES imgui
    SOURCE_SUBDIR  no-cmake  # sources only : their CMakeLists.txt is not used
)
FetchContent_Declare(cimplot
    GIT_REPOSITORY https://github.com/cimgui/cimplot.git
    GIT_TAG        ${CIMPLOT_TAG}
    GIT_SUBMODULES implot
    SOURCE_SUBDIR  no-cmake
)
FetchContent_Declare(cimplot3d
    GIT_REPOSITORY https://github.com/cimgui/cimplot3d.git
    GIT_TAG        ${CIMPLOT3D_TAG}
    GIT_SUBMODULES implot3d
    SOURCE_SUBDIR  no-cmake
)
FetchContent_MakeAvailable(cimgui cimplot cimplot3d)

set(IMGUI_DIR  ${cimgui_SOURCE_DIR}/imgui)
set(IMPLOT_DIR ${cimplot_SOURCE_DIR}/implot)
set(IMPLOT3D_DIR ${cimplot3d_SOURCE_DIR}/implot3d)

add_library(implottk_cimgui SHARED
    ${cimgui_SOURCE_DIR}/cimgui.cpp
    ${IMGUI_DIR}/imgui.cpp
    ${IMGUI_DIR}/imgui_draw.cpp
    ${IMGUI_DIR}/imgui_demo.cpp
    ${IMGUI_DIR}/imgui_tables.cpp
    ${IMGUI_DIR}/imgui_widgets.cpp
    ${IMGUI_DIR}/backends/imgui_impl_opengl3.cpp
    ${cimplot_SOURCE_DIR}/cimplot.cpp
    ${IMPLOT_DIR}/implot.cpp
    ${IMPLOT_DIR}/implot_items.cpp
    ${IMPLOT_DIR}/implot_demo.cpp
    ${cimplot3d_SOURCE_DIR}/cimplot3d.cpp
    ${IMPLOT3D_DIR}/implot3d.cpp
    ${IMPLOT3D_DIR}/implot3d_items.cpp
    ${IMPLOT3D_DIR}/implot3d_meshes.cpp
    ${IMPLOT3D_DIR}/implot3d_demo.cpp
)

set_target_properties(implottk_cimgui PROPERTIES CXX_STANDARD 11)

# 'cimgui.h' expects to be next to the 'imgui' folder (../cimgui/cimgui.h for cimplot).
target_include_directories(implottk_cimgui PRIVATE
    ${cimgui_SOURCE_DIR} ${IMGUI_DIR} ${cimplot_SOURCE_DIR} ${IMPLOT_DIR}
    ${cimplot3d_SOURCE_DIR} ${IMPLOT3D_DIR}
)

target_compile_definitions(implottk_cimgui PRIVATE
    IMGUI_DISABLE_OBSOLETE_FUNCTIONS=1
    IMPLOT_DISABLE_OBSOLETE_FUNCTIONS=1
)

# The OpenGL3 backend functions must be exported with a C name.
if(WIN32)
    # Same syntax as the cimgui CMakeLists.txt (tabs instead of spaces).
    target_compile_definitions(implottk_cimgui PRIVATE
        IMGUI_IMPL_API=extern\t\"C\"\t__declspec\(dllexport\))
    set(LIBNAME cimgui_win32)
    set_target_properties(implottk_cimgui PROPERTIES PREFIX "")
elseif(APPLE)
    target_compile_definitions(implottk_cimgui PRIVATE "IMGUI_IMPL_API=extern \"C\"")
    set(LIBNAME cimgui_osx)
else()
    target_compile_definitions(implottk_cimgui PRIVATE "IMGUI_IMPL_API=extern \"C\"")
    set(LIBNAME cimgui_linux)
    target_link_libraries(implottk_cimgui PRIVATE ${CMAKE_DL_LIBS})
endif()

# OpenGL is loaded at runtime by the backend (imgui_impl_opengl3_loader.h),
# the context itself is created by TkGL.
set_target_properties(implottk_cimgui PROPERTIES
    OUTPUT_NAME ${LIBNAME}
    RUNTIME_OUTPUT_DIRECTORY         ${CMAKE_CURRENT_SOURCE_DIR}
    LIBRARY_OUTPUT_DIRECTORY         ${CMAKE_CURRENT_SOURCE_DIR}
    RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_CURRENT_SOURCE_DIR}
    LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_CURRENT_SOURCE_DIR}
)

# Licenses of the compiled components (included in the packages, see
# THIRD_PARTY_NOTICES.md). cimplot3d has no license file.
set(LICENSES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/licenses)
file(MAKE_DIRECTORY ${LICENSES_DIR})
configure_file(${IMGUI_DIR}/LICENSE.txt         ${LICENSES_DIR}/imgui.txt    COPYONLY)
configure_file(${IMPLOT_DIR}/LICENSE            ${LICENSES_DIR}/implot.txt   COPYONLY)
configure_file(${IMPLOT3D_DIR}/LICENSE          ${LICENSES_DIR}/implot3d.txt COPYONLY)
configure_file(${cimgui_SOURCE_DIR}/LICENSE     ${LICENSES_DIR}/cimgui.txt   COPYONLY)
configure_file(${cimplot_SOURCE_DIR}/LICENSE    ${LICENSES_DIR}/cimplot.txt  COPYONLY)
