#!/bin/sh

set -eu

PRETTY_NAME=dbus
MAJOR=1
MINOR=16
PATCH=2
VERSION=1.16.2

# Inspired both from KISS Linux (kiss-dbus) and Linux From Scratch

printf "\033[1m\
Before installing D-Bus, add a user named 'messagebus' that will\n\
be in charge of running the system session, and nothing else. Also\n\
add a user group for said user. If unsure which UID to pick, just\n\
so you know, Arch Linux uses 81\n\
/etc/passwd entry:\n\
messagebus:x:81:81:System Message Bus:/:/bin/nologin\n\
/etc/shadow entry:\n\
messagebus:!:::::::\n\
/etc/group entry:\n\
messagebus:x:81:\n\
If you haven't gone through such steps, the build will fail.\n\
It would be very hard for this script to check if such requirement\n\
is satisfied, which is why I have to trust you doing the right thing.\n\
Proceed further? [Y/n] \033[0m"

read -r
if [ $REPLY == 'N' ] || [ $REPLY == 'n' ]
then
	exit 1
fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://dbus.freedesktop.org/releases/dbus/dbus-$VERSION.tar.xz

xz -cd dbus-$VERSION.tar.xz | tar -x
cd dbus-$VERSION

# The post-install hook is nothing but trouble and, since we set the
# permissions ourselves, serves no purpose
# Might not be necessary when using meson
printf "#!/usr/bin/env python3" > meson_post_install.py

meson setup \
	-D prefix=/usr \
	-D localstatedir=/var \
	-D buildtype=release \
	-D wrap_mode=nofallback \
	-D strip=true \
	-D default_library=both \
	-D dbus_user=messagebus \
	-D relocation=disabled \
	-D doxygen_docs=disabled \
	-D ducktype_docs=disabled \
	-D xml_docs=disabled \
	build

meson compile -C build
meson install -C build --destdir $DESTDIR

# NOTE: dbus has /var/lib/dbus but only contains a symlink to /etc/machine-id,
# which probably means that it's redundant
rm -rf "$DESTDIR/run"
rm -rf "$DESTDIR/usr/share/doc"

install -Dm755 ../dbus.run "$DESTDIR/etc/sv/dbus/run"
ln -sf /run/runit/supervise.dbus "$DESTDIR/etc/sv/dbus/supervise"

doas chown -R root:root $DESTDIR
doas chown root:messagebus "$DESTDIR/usr/libexec/dbus-daemon-launch-helper"
doas chmod 4750 "$DESTDIR/usr/libexec/dbus-daemon-launch-helper"
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-dbus@$VERSION.tar.gz"
doas rm -rf $DESTDIR
