#!/bin/sh -e

PRETTY_NAME=init-scripts
MAJOR=
MINOR=
PATCH=
VERSION=git

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

git clone https://codeberg.org/kiss-community/init.git
cd init-scripts.git

patch -p1 < ../support-toybox.patch

sed -e 's|:-KISS||g' -e 's| to KISS||g' lib/init/rc.boot > lib/init/rc.boot.new
mv lib/init/rc.boot.new lib/init/rc.boot
sed 's|=>|!!|g' lib/init/rc.lib > lib/init/rc.lib.new
mv lib/init/rc.lib.new lib/init/rc.lib
 
install -Dm755 lib/init/rc.lib      "$DESTDIR/usr/lib/init/rc.lib"
install -Dm755 lib/init/rc.boot     "$DESTDIR/usr/lib/init/rc.boot"
install -Dm755 lib/init/rc.shutdown "$DESTDIR/usr/lib/init/rc.shutdown"

install -Dm644 etc/rc.conf "$DESTDIR/etc/rc.conf"

$CC -static -o kpow bin/kpow.c
install -Dm755 kpow    "$DESTDIR/usr/bin/kpow"
strip --strip-unneeded "$DESTDIR/usr/bin/kpow"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Base-init-scripts@$VERSION.tar.gz"
doas rm -rf $DESTDIR
