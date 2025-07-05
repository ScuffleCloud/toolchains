#!/bin/env bash
set -euxo pipefail

export PKG_CONFIG="pkg-config --static"

if [ "$(uname -s)" = "Darwin" ]; then
    export CMAKE_BUILD_PARALLEL_LEVEL="$(sysctl -n hw.ncpu)"
    export MACOSX_DEPLOYMENT_TARGET="$(sw_vers -productVersion | cut -d '.' -f 1,2)"
else
    export CMAKE_BUILD_PARALLEL_LEVEL="$(nproc)"
fi

version="$1"
install_dir="$2"
build_dir="${3:-build}"

cmake -GNinja -B "${build_dir}" \
    -DCMAKE_INSTALL_PREFIX="${install_dir}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DFFMPEG_TAG="${version}" \
    -DBASH_BIN="$(which bash)" \
    -DMAKE_BIN="$(which make)" \
    -DMESON_BIN="$(which meson)" \
    -DPERL_BIN="$(which perl)" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5

cmake --build "${build_dir}" --config Release --parallel "${CMAKE_BUILD_PARALLEL_LEVEL}" --target install
