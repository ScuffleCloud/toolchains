#!/bin/env bash

set -euxo pipefail

tmp_dir=$(mktemp -d)

cd $tmp_dir

# Step 1: Build zlib
git clone https://github.com/madler/zlib.git -b "${ZLIB_VERSION}" --depth 1
pushd zlib
./configure --prefix=$tmp_dir/zlib --static
make -j$(nproc)
make install
popd

# Step 2: Build OpenSSL
git clone https://github.com/openssl/openssl.git -b "${OPENSSL_VERSION}" --depth 1
pushd openssl

./Configure \
    --prefix=$tmp_dir/openssl \
    --openssldir=$tmp_dir/openssl/ssl \
    zlib \
    --with-zlib-include=$tmp_dir/zlib/include \
    --with-zlib-lib=$tmp_dir/zlib/lib \
    -Wl,-rpath,'$$ORIGIN/../lib'

make -j$(nproc)
make install
popd

tar -cf - $tmp_dir/openssl | zstd --ultra -22 -o "openssl_${OPENSSL_VERSION}.tar.zst"
