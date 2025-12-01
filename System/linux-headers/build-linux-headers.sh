#!/bin/sh

set -eu

PRETTY_NAME=linux
MAJOR=6
MINOR=16
PATCH=1
VERSION=6.16.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://mirrors.edge.kernel.org/pub/linux/kernel/v$MAJOR.x/linux-$VERSION.tar.xz

xz -cd linux-$VERSION.tar.xz | tar -x
cd linux-$VERSION

make HOSTCC="$CC" headers

# Similar to KISS, avoids depending on rsync.
# There's probably a better way to do it
for header in $(find usr/include -name '*.h' -type f)
do
	install -Dm644 $header $DESTDIR/$header
done

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-linux-headers@$VERSION.tar.gz"
doas rm -rf $DESTDIR
