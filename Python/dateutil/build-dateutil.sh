#!/bin/sh

set -eu

PRETTY_NAME=python:dateutil
MAJOR=2
MINOR=9
PATCH=0
VERSION=2.9.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://files.pythonhosted.org/packages/66/c0/0c8b6ad9f17a802ee498c46e004a0eb49bc148f2fd230864601a86dcf6db/python-dateutil-$VERSION.post0.tar.gz
curl --location --remote-name --skip-existing https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-python/python-dateutil/files/python-dateutil-$VERSION-system-tzdata.patch

gzip -cd python-dateutil-$VERSION.post0.tar.gz | tar -x
cd python-dateutil-$VERSION.post0

patch -p1 < ../python-dateutil-$VERSION-system-tzdata.patch
sed '/package_data=/d' setup.py > setup.py.new
mv setup.py.new setup.py

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-dateutil@$VERSION.tar.gz"
doas rm -rf $DESTDIR
