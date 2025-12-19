#!/bin/sh

set -eu

PRETTY_NAME=python:pytz
MAJOR=2025
MINOR=2
PATCH=
VERSION=2025.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-python/pytz/files/pytz-2023.2-system-tzinfo.patch
curl --location --remote-name --skip-existing https://files.pythonhosted.org/packages/source/p/pytz/pytz-$VERSION.tar.gz

gzip -cd pytz-$VERSION.tar.gz | tar -x
cd pytz-$VERSION

patch -p1 < ../pytz-2023.2-system-tzinfo.patch
rm -rf pytz/zoneinfo

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-pytz@$VERSION.tar.gz"
doas rm -rf $DESTDIR
