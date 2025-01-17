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
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
make check
fi
