#!/bin/sh -e

PRETTY_NAME=mandoc
MAJOR=1
MINOR=14
PATCH=6
VERSION=1.14.6

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://mandoc.bsd.lv/snapshots/mandoc-$VERSION.tar.gz

gzip -cd mandoc-$VERSION.tar.gz | tar -x
cd mandoc-$VERSION

patch -p1 < ../mandoc-no-warn.patch

sed -i 's/"more -s"/"less"/g' main.c
sed -i "s/CC=.*/CC=$CC/" configure

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
doas sh -c "tar -zcC $DESTDIR . | gzip > ../mandoc@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
