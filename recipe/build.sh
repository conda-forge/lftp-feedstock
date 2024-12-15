#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./build-aux

configure_args=(
    --prefix=$PREFIX
    --with-sysroot=$PREFIX
    --disable-dependency-tracking
    --disable-silent-rules
    --without-gnutls
    --with-openssl
    --with-readline=$PREFIX
    --without-libresolv
)

./configure "${configure_args[@]}"
make -j$CPU_COUNT
make install
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
make check
fi

# Remove documentation
rm -rf $uprefix/share/man $uprefix/share/doc

# Non-Windows: prefer dynamic libraries to static, and dump libtool helper files
if [ -z "$VS_MAJOR" ] ; then
    for lib_ident in Xp; do
        rm -f $uprefix/lib/lib${lib_ident}.la $uprefix/lib/lib${lib_ident}.a
    done
fi
