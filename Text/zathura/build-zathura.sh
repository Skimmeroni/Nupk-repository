#!/bin/sh -e

PRETTY_NAME=zathura
MAJOR=0
MINOR=5
PATCH=14
VERSION=0.5.14

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://github.com/pwmt/zathura/archive/$VERSION.tar.gz
curl --location --remote-name --skip-existing https://codeberg.org/kiss-community/community/raw/branch/main/community/zathura/patches/remove_gettext.patch

gzip -cd $VERSION.tar.gz | tar -x
cd zathura-$VERSION

# Taken from KISS, not exactly the best option
patch -p1 < ../remove_gettext.patch

muon setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D wrap_mode=nofallback \
	-D manpages=disabled \
	-D tests=disabled \
	-D convert-icon=disabled \
	build

ninja -C build
muon -C build install -d $DESTDIR

strip --strip-unneeded /usr/bin/zathura
strip --strip-unneeded /usr/bin/zathura-sandbox

rm -rf $DESTDIR/usr/share/bash-completion
rm -rf $DESTDIR/usr/share/dbus-1
rm -rf $DESTDIR/usr/share/fish
rm -rf $DESTDIR/usr/share/zsh

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Text-zathura@$VERSION.tar.gz"
doas rm -rf $DESTDIR
