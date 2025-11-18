#!/bin/sh -e

PRETTY_NAME=runit
MAJOR=
MINOR=
PATCH=
VERSION=git

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

git clone https://github.com/void-linux/runit.git
cd runit.git/src

patch -p1 < ../../use-char-const-instead-of-const-char-const-pointer.patch

sed -i 's|/sbin/runit|/usr/bin/runit|g'                runit.h
sed -i 's|/etc/runit/ctrlaltdel|/usr/bin/ctrlaltdel|g' runit.h

echo "$CC $CFLAGS -D_GNU_SOURCE -Wno-implicit -static" > conf-cc
echo "$CC $CFLAGS -static -Wl,-z -Wl,noexecstac"       > conf-ld

make

for i in chpst runit runit-init runsv runsvchdir runsvdir sv svlogd utmpset
do
	install -Dm755 $i          "$DESTDIR/usr/bin/$i"
	strip   --strip-unneeded   "$DESTDIR/usr/bin/$i"
	install -Dm644 ../man/$i.8 "$DESTDIR/usr/share/man/man8/$i.8"
done

install -Dm755 ../../2        "$DESTDIR/etc/runit/2"
install -Dm755 ../../poweroff "$DESTDIR/usr/bin/poweroff"
install -Dm755 ../../reboot   "$DESTDIR/usr/bin/reboot"

ln -sf runit-init                "$DESTDIR/usr/bin/init"
ln -sf /usr/lib/init/rc.boot     "$DESTDIR/etc/runit/1"
ln -sf /usr/lib/init/rc.shutdown "$DESTDIR/etc/runit/3"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../runit@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
