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
    # Configure script tries to check for /dev/ptmx by building executable with host compiler.
    # This will fail when cross-compiling.
    # The check is skipped automatically on Linux, so we can patch the script to
    # instead skip on macOS when cross-compiling.
    # The HAVE_DEV_PTMX CFLAG would normally be set by the check, so we manually set it instead.
    sed -i 's/^\*\-\*\-linux\*/*-*-darwin*/' configure
    export CFLAGS="${CFLAGS} -DHAVE_DEV_PTMX=1"
fi
./configure "${configure_args[@]}"
make -j$CPU_COUNT
make install
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
make check
fi

rm -rf ${PREFIX}/lib/libftp-jobs.a ${PREFIX}/lib/libftp-jobs.la
rm -rf ${PREFIX}/lib/libftp-tasks.a ${PREFIX}/lib/libftp-tasks.la
