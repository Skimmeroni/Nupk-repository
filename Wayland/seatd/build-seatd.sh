#!/bin/sh

set -eu

PRETTY_NAME=seatd
MAJOR=0
MINOR=9
PATCH=1
VERSION=0.9.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://git.sr.ht/~kennylevinsen/seatd/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd seatd-$VERSION

muon setup \
    -D prefix=/usr \
    -D default_library=both \
    -D buildtype=release \
    -D man-pages=enabled \
    -D server=enabled \
    build

ninja -C build
muon -C build install -d "$DESTDIR"

chmod u+s $DESTDIR/usr/bin/seatd-launch
install -Dm755 ../seatd.run "$DESTDIR/etc/sv/seatd/run"
ln -sf /run/runit/supervise.seatd "$DESTDIR/etc/sv/seatd/supervise"

find "$DESTDIR/usr/lib" -type f -name '*.a'   -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -type f -name '*.so*' -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-seatd@$VERSION.tar.gz"
doas rm -rf $DESTDIR
