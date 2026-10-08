@echo off
rem Builds Tcl/Tk 9, cffi and TkGL from source into %1 (Windows, MSVC).
rem Versions : TCL_TAG, CFFI_TAG, TKGL_REF environment variables.
rem Must be run from a Visual Studio x64 command prompt (msvc-dev-cmd).
setlocal
set PREFIX=%~1
set SRC=%CD%\deps-src
mkdir "%SRC%" 2>nul
mkdir "%PREFIX%" 2>nul
git config --global url."https://github.com/".insteadOf "git@github.com:"

cd /d "%SRC%"
echo ::group::Tcl %TCL_TAG%
git clone -q --depth 1 -b %TCL_TAG% https://github.com/tcltk/tcl.git || exit /b 1
cd tcl\win
nmake -nologo -f makefile.vc release || exit /b 1
nmake -nologo -f makefile.vc install INSTALLDIR="%PREFIX%" || exit /b 1
cd /d "%SRC%"
echo ::endgroup::

echo ::group::Tk %TCL_TAG%
git clone -q --depth 1 -b %TCL_TAG% https://github.com/tcltk/tk.git || exit /b 1
cd tk\win
rem OPTS=pdbs : optimized build + debug symbols (for crash diagnostics).
nmake -nologo -f makefile.vc release TCLDIR="%SRC%\tcl" OPTS=pdbs || exit /b 1
nmake -nologo -f makefile.vc install TCLDIR="%SRC%\tcl" INSTALLDIR="%PREFIX%" OPTS=pdbs || exit /b 1
mkdir "%PREFIX%\pdb" 2>nul
for /r %%f in (*.pdb) do copy /y "%%f" "%PREFIX%\pdb\" >nul
cd /d "%SRC%"
echo ::endgroup::

echo ::group::libffi + cffi %CFFI_TAG%
vcpkg install libffi:x64-windows-static-md || exit /b 1
set EXTDIR=%VCPKG_INSTALLATION_ROOT%\installed\x64-windows-static-md
git clone -q --depth 1 -b %CFFI_TAG% --recurse-submodules --shallow-submodules https://github.com/apnadkarni/tcl-cffi.git || exit /b 1
cd tcl-cffi\win
rem The default target also builds a test dll (cffitest.dll) which does not
rem link with this toolchain : only the extension and its pkgIndex are built.
nmake -nologo /f makefile.vc INSTALLDIR="%PREFIX%" EXTDIR="%EXTDIR%" setup || exit /b 1
nmake -nologo /f makefile.vc INSTALLDIR="%PREFIX%" EXTDIR="%EXTDIR%" pkgindex || exit /b 1
nmake -nologo /f makefile.vc INSTALLDIR="%PREFIX%" EXTDIR="%EXTDIR%" install || exit /b 1
cd /d "%SRC%"
echo ::endgroup::

echo ::group::TkGL %TKGL_REF%
git -c core.autocrlf=false clone -q https://github.com/3-manifolds/TkGL.git || exit /b 1
cd TkGL
git checkout -q %TKGL_REF% || exit /b 1
rem Windows fixes (parent window, device context, NULL WGL pointers).
git apply --verbose "%~dp0tkgl-windows.patch" || exit /b 1
cd win
nmake -nologo -f makefile.vc TCLDIR="%SRC%\tcl" TKDIR="%SRC%\tk" OPTS=pdbs || exit /b 1
nmake -nologo -f makefile.vc TCLDIR="%SRC%\tcl" TKDIR="%SRC%\tk" INSTALLDIR="%PREFIX%" OPTS=pdbs install || exit /b 1
for /r %%f in (*.pdb) do copy /y "%%f" "%PREFIX%\pdb\" >nul
rem The pdb files are not distributed in the packages.
del /q "%PREFIX%\lib\Tkgl1.2.1\*.pdb" 2>nul
rem The license of TkGL must be included in the distributions.
for /d %%d in ("%PREFIX%\lib\Tkgl*") do copy /y "%SRC%\TkGL\license.terms" "%%d\" >nul
cd /d "%SRC%"
echo ::endgroup::

dir "%PREFIX%\lib"
endlocal
