#!/bin/sh

set -eu

PRETTY_NAME=python
MAJOR=3
MINOR=14
PATCH=1
VERSION=3.14.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tar.xz
curl --location --remote-name --skip-existing https://raw.githubusercontent.com/gentoo/libressl/refs/heads/master/dev-lang/python/files/python-3.14.0-libressl.patch

tar -xf Python-$VERSION.tar.xz
cd Python-$VERSION

patch -p1 < ../python-3.14.0-libressl.patch

cat >> Modules/Setup << EOF
*disabled*
nis
ossaudiodev
_gdbm _dbm
_tkinter
EOF

./configure \
	ac_cv_working_openssl_hashlib=yes \
	--prefix=/usr \
	--enable-shared \
	--enable-loadable-sqlite-extensions \
	--enable-optimizations \
	--with-readline=editline \
	--with-tzpath=/usr/share/zoneinfo \
	--with-system-expat \
	--with-system-libmpdec \
	--disable-test-modules \
	--without-ensurepip \
	--without-doc-strings

make
make DESTDIR=$DESTDIR install

ln -sf python3         "$DESTDIR/usr/bin/python"
ln -sf python3-config  "$DESTDIR/usr/bin/python-config"

# Turtles are cute though
find "$DESTDIR/usr/lib/python$MAJOR.$MINOR/__pycache__" -name 'turtle*.pyc' -delete
rm -rf "$DESTDIR/usr/lib/python$MAJOR.$MINOR/turtle.py"
rm -rf "$DESTDIR/usr/lib/python$MAJOR.$MINOR/turtledemo"
# TKinter does not support Wayland
rm -rf "$DESTDIR/usr/lib/python$MAJOR.$MINOR/tkinter"
rm -rf "$DESTDIR/usr/lib/python$MAJOR.$MINOR/idlelib"
rm "$DESTDIR/usr/bin/idle*"

strip --strip-unneeded "$DESTDIR/usr/bin/python3"
find "$DESTDIR/usr/lib" -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Lang-python@$VERSION.tar.gz"
doas rm -rf $DESTDIR
