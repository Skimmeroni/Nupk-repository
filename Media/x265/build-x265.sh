#!/bin/sh

set -eu

PRETTY_NAME=x265
MAJOR=4
MINOR=1
PATCH=
VERSION=4.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://bitbucket.org/multicoreware/x265_git/downloads/x265_$VERSION.tar.gz

gzip -cd x265_$VERSION.tar.gz | tar -x
cd x265_$VERSION/source

# Prune outdated Cmake policies (taken from LFS)
sed -r '/cmake_policy.*(0025|0054)/d' CMakeLists.txt > CMakeLists.txt.new
mv CMakeLists.txt.new CMakeLists.txt

# CMAKE_POLICY_VERSION_MINIMUM enforced until the next release
cmake -B build \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release \
	-D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-D ENABLE_CLI=FALSE \
	-D ENABLE_LIBNUMA=FALSE \
	-W no-dev -G Ninja

cmake --build build
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-x265@$VERSION.tar.gz"
doas rm -rf $DESTDIR
