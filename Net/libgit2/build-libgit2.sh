#!/bin/sh

set -eu

PRETTY_NAME=libgit2
MAJOR=1
MINOR=9
PATCH=2
VERSION=1.9.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/libgit2/libgit2/archive/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd libgit2-$VERSION

# Note: an external http parser is supported
cmake -B build \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release \
	-D USE_SSH=ON \
	-D USE_HTTP_PARSER=builtin \
	-D REGEX_BACKEND=pcre2 \
	-D BUILD_TESTS=OFF \
	-D USE_GSSAPI=OFF \
	-G Ninja

cmake --build build --verbose
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Net-libgit2@$VERSION.tar.gz"
doas rm -rf $DESTDIR
