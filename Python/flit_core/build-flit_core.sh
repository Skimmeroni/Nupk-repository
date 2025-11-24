#!/bin/sh -e

PRETTY_NAME=python:flit-core
MAJOR=3
MINOR=12
PATCH=0
VERSION=3.12.0

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://files.pythonhosted.org/packages/source/f/flit/flit-$VERSION.tar.gz

gzip -cd flit-$VERSION.tar.gz | tar -x
cd flit-$VERSION

python flit_core/build_dists.py
python -m installer -d $DESTDIR flit_core/dist/flit_core-$VERSION-py3-none-any.whl

# The vendored dependency tomli is not needed since Python has now its own toml parser

PYTHON_VERSION=$(python -c 'from sys import version_info as v; print(f"{v[0]}.{v[1]}")')
rm -rf $DESTDIR/usr/lib/python$PYTHON_VERSION/site-packages/flit_core/vendor
rm -rf $DESTDIR/usr/lib/python$PYTHON_VERSION/site-packages/flit_core-$VERSION.dist-info/licenses/flit_core/vendor

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Python-flit_core@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
