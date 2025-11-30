#!/bin/sh -e

PRETTY_NAME=mandoc
MAJOR=1
MINOR=14
PATCH=6
VERSION=1.14.6

# NOTE: since we don't use databases or fancy features, just display
# man pages, using Toybox man could be a sensible choice. At the moment,
# the Toybox implementation is not functional

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://mandoc.bsd.lv/snapshots/mandoc-$VERSION.tar.gz

gzip -cd mandoc-$VERSION.tar.gz | tar -x
cd mandoc-$VERSION

patch -p1 < ../mandoc-no-warn.patch

sed 's/"more -s"/"less"/g' main.c > main.c.new
mv main.c.new main.c
sed "s/CC=.*/CC=$CC/" configure > configure.new
mv configure.new configure

cat > configure.local << EOF
PREFIX=/usr
MANDIR=/usr/share/man
LIBDIR=/usr/lib
SBINDIR=/usr/bin
LN="ln -sf"
EOF

./configure

make
make DESTDIR=$DESTDIR base-install

find "$DESTDIR/usr/bin" -type f -exec chmod 755 {} \; -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-mandoc@$VERSION.tar.gz"
doas rm -rf $DESTDIR
