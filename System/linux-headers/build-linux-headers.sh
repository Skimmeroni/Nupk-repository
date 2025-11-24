#!/bin/sh -e

PRETTY_NAME=linux
MAJOR=6
MINOR=16
PATCH=1
VERSION=6.16.1

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

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
doas sh -c "tar -zcC $DESTDIR . | gzip > ../System-linux-headers@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
