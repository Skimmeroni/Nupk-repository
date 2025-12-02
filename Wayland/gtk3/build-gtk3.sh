#!/bin/sh

set -eu

PRETTY_NAME=gtk3
MAJOR=3
MINOR=24
PATCH=51
VERSION=3.24.51

# Snatching gtk from repology is problematic

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://download.gnome.org/sources/gtk/$MAJOR.$MINOR/gtk-$VERSION.tar.xz

xz -cd gtk-$VERSION.tar.xz | tar -x
cd gtk-$VERSION

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D wrap_mode=nofallback \
	-D broadway_backend=false \
	-D cloudproviders=false \
	-D demos=false \
	-D examples=false \
	-D gtk_doc=false \
	-D introspection=false \
	-D wayland_backend=true \
	-D x11_backend=false \
	-D colord=no \
	-D print_backends=file \
	-D builtin_immodules=backend \
	-D man=false \
	-D tests=false \
	-D tracker3=false \
	build

meson compile -C build
meson install -C build --destdir $DESTDIR

find "$DESTDIR/usr/lib" -type f -name '*.a'   -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -type f -name '*.so*' -exec strip --strip-unneeded {} \;

rm -rf "$DESTDIR/usr/share/gettext"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-gtk3@$VERSION.tar.gz"
doas rm -rf $DESTDIR

printf "\033[1mDon't forget to update immodules cache!\033[0m\n"
# doas gtk-query-immodules-3.0 --update-cache
printf "\033[1mDon't forget to compile glib schemas!\033[0m\n"
# doas glib-compile-schemas /usr/share/glib-2.0/schemas
