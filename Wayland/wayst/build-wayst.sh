#!/bin/sh -e

PRETTY_NAME=wayst
MAJOR=
MINOR=
PATCH=
VERSION=git

mkdir temporary-builddir
DESTDIR="$PWD/temporary-builddir"

git clone https://github.com/91861/wayst.git
cd wayst

# Note: PGO and LTO are available
make window_protocol=wayland renderer=gles20 libutf8proc=on mode=quick
install -Dm755 wayst "$DESTDIR/usr/bin/wayst"
strip --strip-unneeded "$DESTDIR/usr/bin/wayst"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Wayland-wayst@$VERSION.tar.gz"
doas rm -rf $DESTDIR
