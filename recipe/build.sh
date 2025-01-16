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

if [[ ${target_platform} == "osx-arm64" ]]; then
    export ac_no_dev_ptmx=1
    export ac_no_dev_ptc=1
    export CFLAGS="${CFLAGS} -DHAVE_DEV_PTMX=1"
fi

autoreconf --force --verbose --install
./configure "${configure_args[@]}"
make -j$CPU_COUNT
make install
make check

# Remove documentation
rm -rf $uprefix/share/man $uprefix/share/doc

# Non-Windows: prefer dynamic libraries to static, and dump libtool helper files
if [ -z "$VS_MAJOR" ] ; then
    for lib_ident in Xp; do
        rm -f $uprefix/lib/lib${lib_ident}.la $uprefix/lib/lib${lib_ident}.a
    done
fi
