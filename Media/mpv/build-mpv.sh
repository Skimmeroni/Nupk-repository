#!/bin/sh

set -eu

PRETTY_NAME=mpv
MAJOR=0
MINOR=41
PATCH=0
VERSION=0.41.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/mpv-player/mpv/archive/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd mpv-$VERSION

# lua is disabled because lua 5.4 is not supported
meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D wrap_mode=nofallback \
	-D default_library=both \
	-D alsa=enabled \
	-D cplugins=enabled \
	-D drm=enabled \
	-D egl=enabled \
	-D gl=enabled \
	-D lcms2=enabled \
	-D vaapi=enabled \
	-D wayland=enabled \
	-D html-build=disabled \
	-D manpage-build=disabled \
	-D pdf-build=disabled \
	-D jpeg=disabled \
	-D libarchive=disabled \
	-D lua=disabled \
	-D zlib=disabled \
	-D tests=false \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

rm -rf "$DESTDIR/usr/share/bash-completion"
rm -rf "$DESTDIR/usr/share/fish"
rm -rf "$DESTDIR/usr/share/zsh"
rm -rf "$DESTDIR/usr/share/doc"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-mpv@$VERSION.tar.gz"
doas rm -rf $DESTDIR

printf "\033[1mRemember to update the GTK icon cache!\033[0m\n"
# doas gtk-update-icon-cache -t /usr/share/icons/hicolor
