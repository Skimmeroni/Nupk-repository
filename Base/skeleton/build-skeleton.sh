#!/bin/sh

set -eu

PRETTY_NAME=-
MAJOR=
MINOR=
PATCH=
VERSION=git

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

mkdir -m 755 \
	"$DESTDIR/boot" \
	"$DESTDIR/dev" \
	"$DESTDIR/etc" \
	"$DESTDIR/home" \
	"$DESTDIR/mnt" \
	"$DESTDIR/run" \
	"$DESTDIR/usr" \
	"$DESTDIR/usr/bin" \
	"$DESTDIR/usr/include" \
	"$DESTDIR/usr/lib" \
	"$DESTDIR/usr/share" \
	"$DESTDIR/var" \
	"$DESTDIR/var/cache" \
	"$DESTDIR/var/log" \
	"$DESTDIR/var/lib" \
	"$DESTDIR/var/empty" \
	"$DESTDIR/var/service"

mkdir -m 555 \
	"$DESTDIR/proc" \
	"$DESTDIR/sys"

mkdir -m 0750 "$DESTDIR/root"

mkdir -m 1777 \
	"$DESTDIR/tmp" \
	"$DESTDIR/var/tmp"

ln -sf usr/bin             "$DESTDIR/bin"
ln -sf usr/lib             "$DESTDIR/lib"
ln -sf ../run              "$DESTDIR/var/run"
ln -sf ../run/lock         "$DESTDIR/var/lock"
ln -sf ../proc/self/mounts "$DESTDIR/etc/mtab"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Base-skeleton@$VERSION.tar.gz"
doas rm -rf $DESTDIR
