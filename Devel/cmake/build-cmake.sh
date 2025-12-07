#!/bin/sh

set -eu

PRETTY_NAME=cmake
MAJOR=4
MINOR=2
PATCH=0
VERSION=4.2.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://cmake.org/files/v$MAJOR.$MINOR/cmake-$VERSION.tar.gz

gzip -cd cmake-$VERSION.tar.gz | tar -x
cd cmake-$VERSION

# From LFS: always use lib, never use lib64
sed '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake > Modules/GNUInstallDirs.cmake.new
mv Modules/GNUInstallDirs.cmake.new Modules/GNUInstallDirs.cmake

# Since cmake takes ages to build, it is reasonable to skip
# the bootstrap phase if it is installed already. It makes
# (should make?) no difference anyway
if [ -z $(command -v cmake) ]
then
	echo "CMake was not found, starting bootstrap phase..."

	./configure \
		--bootstrap-system-jsoncpp \
		--bootstrap-system-librhash \
		--bootstrap-system-libuv \
		--prefix=/usr \
		--system-libs \
		--no-debugger \
		--no-qt-gui

	make
	make DESTDIR=$DESTDIR install
else
	echo "CMake found, bootstrap phase skipped"

	cmake -B build \
		-D CMAKE_INSTALL_PREFIX=/usr \
		-D CMAKE_BUILD_TYPE=Release \
		-D CMAKE_USE_SYSTEM_LIBRARIES=ON \
		-D CMake_ENABLE_DEBUGGER=OFF \
		-D BUILD_TESTING=OFF \
		-D BUILD_QtDialog=OFF \
		-G Ninja
	
	cmake --build build --verbose
	DESTDIR=$DESTDIR cmake --install build
fi

rm -rf "$DESTDIR/usr/doc"
rm -rf "$DESTDIR/usr/share/vim"
rm -rf "$DESTDIR/usr/share/emacs"
rm -rf "$DESTDIR/usr/share/bash-completion"
rm -rf "$DESTDIR/usr/share/cmake-$MAJOR.$MINOR/Help"

find $DESTDIR/usr/bin -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-cmake@$VERSION.tar.gz"
doas rm -rf $DESTDIR
