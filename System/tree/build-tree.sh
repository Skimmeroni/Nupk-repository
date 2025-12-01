#!/bin/sh

set -eu

PRETTY_NAME=unix-tree-pt-br
MAJOR=2
MINOR=2
PATCH=1
VERSION=2.2.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://gitlab.com/OldManProgrammer/unix-tree/-/archive/$VERSION/unix-tree-$VERSION.tar.gz

gzip -cd unix-tree-$VERSION.tar.gz | tar -x
cd unix-tree-$VERSION

make
install -Dm755 tree "$DESTDIR/usr/bin/tree"
install -Dm644 doc/tree.1 "$DESTDIR/usr/share/man/man1/tree.1"
strip --strip-unneeded "$DESTDIR/usr/bin/tree"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-tree@$VERSION.tar.gz"
doas rm -rf $DESTDIR
