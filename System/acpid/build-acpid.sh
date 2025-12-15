#!/bin/sh

set -eu

PRETTY_NAME=acpid
MAJOR=2
MINOR=0
PATCH=34
VERSION=2.0.34

# TODO: this package is non-functional on its own
# it requires scripts to handle acpi events

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://downloads.sourceforge.net/acpid2/acpid-$VERSION.tar.xz

xz -cd acpid-$VERSION.tar.xz | tar -x
cd acpid-$VERSION

# See https://gitweb.gentoo.org/repo/gentoo.git/tree/sys-power/acpid/files/acpid-2.0.34-lfs.patch
sed 's|stat64|stat|g' sock.c > sock.c.new
mv sock.c.new sock.c

./configure \
	--prefix=/usr \
	--sbindir=/usr/bin \
	--disable-maintainer-mode

make
make DESTDIR=$DESTDIR install-strip

mkdir -p "$DESTDIR/usr/share/LICENSES"
mv "$DESTDIR/usr/share/doc/acpid/COPYING" "$DESTDIR/usr/share/LICENSES/acpid.license"
rm -rf "$DESTDIR/usr/share/doc"

install -Dm755 ../acpid.run "$DESTDIR/etc/sv/acpid/run"
ln -sf /run/runit/supervise.acpid "$DESTDIR/etc/sv/acpid/supervise"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-acpid@$VERSION.tar.gz"
doas rm -rf $DESTDIR
