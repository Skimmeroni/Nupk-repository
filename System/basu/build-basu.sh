#!/bin/sh

set -eu

PRETTY_NAME=basu
MAJOR=0
MINOR=2
PATCH=1
VERSION=0.2.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://git.sr.ht/~emersion/basu/refs/download/v$VERSION/basu-$VERSION.tar.gz

gzip -cd basu-$VERSION.tar.gz | tar -x
cd basu-$VERSION

meson setup \
	-D prefix=/usr \
	-D default_library=both \
	-D buildtype=release \
	-D wrap_mode=nofallback \
	-D strip=true \
	build

meson compile -C build
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-basu@$VERSION.tar.gz"
doas rm -rf $DESTDIR
