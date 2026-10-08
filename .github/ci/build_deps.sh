#!/bin/bash
# Builds Tcl/Tk 9, cffi and TkGL from source into $1 (Linux and macOS).
# Versions : TCL_TAG, CFFI_TAG, TKGL_REF environment variables.
set -euo pipefail

PREFIX=$1
SRC=$(pwd)/deps-src
JOBS=4
mkdir -p "$SRC" "$PREFIX"

# The cffi 'tclh' submodule url is 'git@github.com:...'.
git config --global url."https://github.com/".insteadOf "git@github.com:"

AQUA=""
FFI_ENV=()
TCLTK_CFLAGS=""
if [ "$(uname)" = "Darwin" ]; then
    AQUA="--enable-aqua"
    # Everything is built universal (arm64 + x86_64) : TkGL always is (see
    # its configure.ac), so Tcl/Tk (stub libraries) must be too, and cffi is
    # linked with the universal libffi of the macOS SDK (Homebrew's libffi
    # is native only).
    ARCHS="-arch x86_64 -arch arm64 -mmacosx-version-min=11.0"
    TCLTK_CFLAGS="-O2 $ARCHS"
    SDK=$(xcrun --show-sdk-path)
    FFI_ENV=("CFLAGS=-O2 $ARCHS -I$SDK/usr/include/ffi" "LDFLAGS=$ARCHS")
fi

cd "$SRC"
echo "::group::Tcl $TCL_TAG"
git clone -q --depth 1 -b "$TCL_TAG" https://github.com/tcltk/tcl.git
(cd tcl/unix && ./configure --prefix="$PREFIX" ${TCLTK_CFLAGS:+"CFLAGS=$TCLTK_CFLAGS"} && make -j$JOBS && make install)
echo "::endgroup::"

echo "::group::Tk $TCL_TAG"
git clone -q --depth 1 -b "$TCL_TAG" https://github.com/tcltk/tk.git
(cd tk/unix && ./configure --prefix="$PREFIX" --with-tcl="$SRC/tcl/unix" $AQUA ${TCLTK_CFLAGS:+"CFLAGS=$TCLTK_CFLAGS"} \
    && make -j$JOBS && make install)
echo "::endgroup::"

echo "::group::cffi $CFFI_TAG"
git clone -q --depth 1 -b "$CFFI_TAG" --recurse-submodules --shallow-submodules \
    https://github.com/apnadkarni/tcl-cffi.git
mkdir -p tcl-cffi/build
(cd tcl-cffi/build && env "${FFI_ENV[@]}" ../configure --prefix="$PREFIX" \
    --with-tcl="$SRC/tcl/unix" --with-libffi --disable-staticffi \
    && make -j$JOBS && make install-binaries install-libraries)
echo "::endgroup::"

echo "::group::TkGL $TKGL_REF"
git clone -q https://github.com/3-manifolds/TkGL.git
(cd TkGL && git checkout -q "$TKGL_REF" && autoconf \
    && ./configure --prefix="$PREFIX" --with-tcl="$SRC/tcl/unix" --with-tk="$SRC/tk/unix" \
    && make && make install-lib-binaries)
# The license of TkGL must be included in the distributions.
for d in "$PREFIX"/lib/[Tt]kgl*; do
    if [ -d "$d" ]; then cp TkGL/license.terms "$d/"; fi
done
echo "::endgroup::"

ls "$PREFIX/lib"
