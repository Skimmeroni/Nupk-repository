#!/bin/sh -e

PRETTY_NAME=wpa-supplicant
MAJOR=2
MINOR=11
PATCH=
VERSION=2.11

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://w1.fi/releases/wpa_supplicant-$VERSION.tar.gz
curl --location --remote-name --skip-existing https://raw.githubusercontent.com/gentoo/libressl/refs/heads/master/net-wireless/wpa_supplicant/files/wpa_supplicant-2.11-libressl.patch

gzip -cd wpa_supplicant-$VERSION.tar.gz | tar -x
cd wpa_supplicant-$VERSION

# ABI breakage
patch -p1 < ../wpa_supplicant-2.11-libressl.patch

cd wpa_supplicant

cp defconfig .config
sed -e 's|CONFIG_CTRL_IFACE_DBUS_NEW=y|#CONFIG_CTRL_IFACE_DBUS_NEW=n|g' \
    -e 's|CONFIG_CTRL_IFACE_DBUS_INTRO=y|#CONFIG_CTRL_IFACE_DBUS_INTRO=n|g' \
    -e "s|#CFLAGS += -I$<path to libnl include files>|CFLAGS += $(pkgconf --cflags libnl-3.0)|g" \
    -e "s|#LIBS += -L$<path to libnl library files>|LIBS += $(pkgconf --libs libnl-3.0)|g" .config > .config.new
mv .config.new .config

sed -e 's|LIBDIR ?= /usr/local/lib|LIBDIR = /usr/lib|g' \
    -e 's|INCDIR ?= /usr/local/include|INCDIR = /usr/include|g' \
    -e 's|BINDIR ?= /usr/local/sbin|BINDIR = /usr/bin|g' Makefile > Makefile.new
mv Makefile.new Makefile

make
make DESTDIR=$DESTDIR install

find "$DESTDIR/usr/bin" -type f -exec strip --strip-unneeded {} \;

mkdir -p $DESTDIR/usr/share/man/man5
mkdir -p $DESTDIR/usr/share/man/man8
cp -f doc/docbook/*.5 $DESTDIR/usr/share/man/man5
cp -f doc/docbook/*.8 $DESTDIR/usr/share/man/man8

install -Dm755 ../../wpa_supplicant.run "$DESTDIR/etc/sv/wpa_supplicant/run"
ln -sf /run/runit/supervise.wpa_supplicant "$DESTDIR/etc/sv/wpa_supplicant/supervise"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../../Net-wpa_supplicant@$VERSION.tar.gz"
doas rm -rf $DESTDIR
