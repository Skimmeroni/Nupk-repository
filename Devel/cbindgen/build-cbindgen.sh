#!/bin/sh

set -eu

PRETTY_NAME=cbindgen
MAJOR=0
MINOR=29
PATCH=0
VERSION=0.29.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/mozilla/cbindgen/archive/refs/tags/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd cbindgen-$VERSION

cargo fetch
RUSTFLAGS="$RUSTFLAGS -C strip=symbols" cargo build --frozen --release
install -Dm755 target/release/cbindgen "$DESTDIR/usr/bin/cbindgen"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-cbindgen@$VERSION.tar.gz"
doas rm -rf $DESTDIR
