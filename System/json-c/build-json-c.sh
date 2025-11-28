#!/bin/sh -e

PRETTY_NAME=json-c
MAJOR=0
MINOR=18
PATCH=20240915
VERSION=0.18-20240915

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://github.com/json-c/json-c/archive/refs/tags/json-c-$VERSION.tar.gz

gzip -cd json-c-$VERSION.tar.gz | tar -x
cd json-c-json-c-$VERSION

# NOTE: being quite old, the latest release has no (explicit) support for
# modern CMake, even though it builds just fine.
# Thankfully, the upcoming release supports Meson
cmake -B build \
	-D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_INSTALL_LIBDIR=lib \
	-D CMAKE_BUILD_TYPE=Release \
	-D BUILD_STATIC_LIBS=ON \
	-D BUILD_SHARED_LIBS=ON \
	-D DISABLE_EXTRA_LIBS=ON \
	-D BUILD_APPS=OFF \
	-D BUILD_TESTING=OFF \
	-G Ninja

cmake --build build
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../System-json-c@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
