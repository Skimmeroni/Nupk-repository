#!/bin/sh

set -eu

PRETTY_NAME=boost
MAJOR=1
MINOR=89
PATCH=0
VERSION=1.89.0

# NOTE: Boost is heavily compartimentalized. In principle, it would be possible
# to only build the components that one actually needs, saving time and space,
# even though it is unclear how much we would gain from that

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://archives.boost.io/release/$VERSION/source/boost_${MAJOR}_${MINOR}_${PATCH}.tar.bz2

bzip2 -cd boost_${MAJOR}_${MINOR}_${PATCH}.tar.bz2 | tar -x 
cd boost_${MAJOR}_${MINOR}_${PATCH}

# It isn't actually necessary to specify the installed version of Python,
# since the build script can figure it out on its own. It's just a reminder
# that Python has to be installed first
PYTHON_VERSION=$(python -c 'from sys import version_info as v; print(f"{v[0]}.{v[1]}")')

# Boost uses the b2 build system, that can be installed separately.
# However, since (as of now) only this package uses it, there's no
# point in doing so, being self-contained
./bootstrap.sh \
	--prefix="$DESTDIR/usr" \
	--with-python-version=$PYTHON_VERSION

# -q stops at first error, -d+2 renders output more verbose
./b2 stage \
	python=$PYTHON_VERSION \
	-q \
	-d+2 \
	link=shared \
	threading=multi \
	variant=release \
	-s NO_COMPRESSION=1 \
	--without-mpi \
	--without-locale \
	--without-context \
	--without-coroutine \
	--without-fiber \
	--without-stacktrace

# TODO: avoid using the same options twice, stash them in a variable or something
./b2 install \
	python=$PYTHON_VERSION \
	-q \
	-d+2 \
	link=shared \
	threading=multi \
	variant=release \
	-s NO_COMPRESSION=1 \
	--without-mpi \
	--without-locale \
	--without-context \
	--without-coroutine \
	--without-fiber \
	--without-stacktrace

find "$DESTDIR/usr/lib" -name '*.so*' -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -name '*.a'   -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-boost@$VERSION.tar.gz"
doas rm -rf $DESTDIR
