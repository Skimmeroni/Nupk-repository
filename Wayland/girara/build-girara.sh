#!/bin/sh -e

PRETTY_NAME=girara
MAJOR=0
MINOR=4
PATCH=5
VERSION=0.4.5

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://github.com/pwmt/girara/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd girara-$VERSION

muon setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D wrap_mode=nofallback \
	-D json=disabled \
	-D docs=disabled \
	-D tests=disabled \
	build

ninja -C build
muon -C build install -d $DESTDIR

find "$DESTDIR/usr/lib" -type f -name '*.a'   -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -type f -name '*.so*' -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Wayland-girara@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
