#!/bin/sh -e

PRETTY_NAME=sway
MAJOR=1
MINOR=11
PATCH=
VERSION=1.11

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://github.com/swaywm/sway/releases/download/$VERSION/sway-$VERSION.tar.gz

gzip -cd sway-$VERSION.tar.gz | tar -x
cd sway-$VERSION

# TODO: use /etc instead of /usr/etc
muon setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D wrap_mode=nofallback \
	-D man-pages=enabled \
	-D swaynag=true \
	-D default-wallpaper=false \
	-D bash-completions=false \
	-D fish-completions=false \
	-D zsh-completions=false \
	-D gdk-pixbuf=disabled \
	-D swaybar=false \
	-D tray=disabled \
	build

ninja -C build
muon -C build install -d $DESTDIR

find "$DESTDIR/usr/bin" -type f -exec strip --strip-unneeded {} \;
# Since we don't use PAM, this is irrelevant
rm -rf "$DESTDIR/usr/share/wayland-sessions"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Wayland-sway@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
