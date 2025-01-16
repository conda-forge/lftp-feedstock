#!/bin/bash

configure_args=(
    --prefix=$PREFIX
    --host=${HOST}
    --target=${TARGET}
    --with-sysroot=$PREFIX
    --disable-dependency-tracking
    --disable-silent-rules
    --without-gnutls
    --with-openssl
    --with-readline=$PREFIX
    --without-libresolv
)

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
