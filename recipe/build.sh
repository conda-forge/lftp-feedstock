#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

configure_args=(
    --prefix=$PREFIX
    --build=${BUILD}
    --host=${HOST}
    --with-sysroot=$PREFIX
    --disable-dependency-tracking
    --disable-silent-rules
    --without-gnutls
    --with-openssl
    --with-readline=$PREFIX
    --without-libresolv
)


autoreconf --force --verbose --install
if [[ ${target_platform} == "osx-arm64" ]]; then
    sed -i 's/^\*\-\*\-linux\*/*-*-darwin*/' configure
    export CFLAGS="${CFLAGS} -DHAVE_DEV_PTMX=1"
fi
./configure "${configure_args[@]}"
make -j$CPU_COUNT
make install
make check

# Remove documentation
rm -rf ${PREFIX}/share/man ${PREFIX}/share/doc

# Non-Windows: prefer dynamic libraries to static, and dump libtool helper files
if [ -z "$VS_MAJOR" ] ; then
    for lib_ident in Xp; do
        rm -f ${PREFIX}/lib/lib${lib_ident}.la ${PREFIX}/lib/lib${lib_ident}.a
    done
fi
