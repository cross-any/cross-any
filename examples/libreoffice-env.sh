#/bin/bash
# libreoffice build
# prepare
emerge -nuv -j4 -uvn zip ccache p7zip patch freetype libcap dev-python/lxml polib cppunit libcap htmldoc dev-python/six   dev-python/sphinx dev-python/utidylib dev-python/lxml dev-python/chardet --autounmask-continue --autounmask=y --autounmask-write
emerge -nuv -j4 -uvn --nodeps translate-toolkit --autounmask-continue --autounmask=y --autounmask-write
PYTHON_TARGETS="python3_7" USE=-llvm emerge -nuv -j4 -uvn zip ccache p7zip patch freetype libcap dev-python/lxml polib cppunit libcap htmldoc translate-toolkit --autounmask-continue --autounmask=y --autounmask-write
$crossenv-emerge -nuv -j4  --autounmask-continue --autounmask=y --autounmask-write =freetype-2.7.1-r2::localrepo =media-libs/fontconfig-2.12.6 libffi awk gzip libpcre
USE=static-libs $crossenv-emerge -nuv -j4 libpcre cppunit libcap pam

PYTHON_TARGETS="python3_7" USE=-llvm $crossenv-emerge  -nuv -j4 --autounmask-continue --autounmask=y --autounmask-write mesa dev-python/lxml
PYTHON_TARGETS="python3_7" $crossenv-emerge -nuv -j4 --exclude=dev-lang/python  x11-apps/xconsole libXrender xrandr libXinerama --autounmask-continue --autounmask=y --autounmask-write

if [[ "$crossenv" = x86_64-* ]]; then
  emerge -nuv -j4 --exclude=dev-lang/python  x11-apps/xconsole libXrender xrandr --autounmask-continue --autounmask=y --autounmask-write
fi
