#!/bin/sh

set -eu

PRETTY_NAME=adwaita-icon-theme
MAJOR=49
MINOR=0
PATCH=
VERSION=49.0

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://download.gnome.org/sources/adwaita-icon-theme/49/adwaita-icon-theme-$VERSION.tar.xz

xz -cd adwaita-icon-theme-$VERSION.tar.xz | tar -x
cd adwaita-icon-theme-$VERSION

muon setup -D prefix=/usr build
ninja -C build
muon -C build install -d $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Themes-adwaita@$VERSION.tar.gz"
doas rm -rf $DESTDIR

printf "\033[1mRemember to update the GTK icon cache!\033[0m\n"
# doas gtk-update-icon-cache
