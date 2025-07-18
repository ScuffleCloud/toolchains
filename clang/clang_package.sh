#!/bin/bash

# Copyright Materialize, Inc. and contributors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License in the LICENSE file at the
# root of this repository, or online at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -exuo pipefail

# Version of clang we built.
clang_version="$1"

clang_arch="$(uname -m)"

# These values are used in the `.txt` files that define what we package.
clang_target="${clang_arch}-unknown-linux-gnu"
clang_major="$(echo "${clang_version}" | cut -d '.' -f 1)"
clang_major_minor="$(echo "${clang_version}" | cut -d. -f1-2)"
shared_extension="so"

# Package the toolchain by copying everything listed from the following files:
#
#  * bin.txt
#  * include.txt
#  * lib.txt
#
# Note: There is a header file `__config_site` that gets generated in a platform specific
# directory but to support cross compiling we move it into the normal `include` dir. This is
# bit hacky, but I've manually confirmed the file is the same for both architectures.

mkdir package

mv "llvm-project/build/include/${clang_target}/c++/v1/__config_site" "llvm-project/build/include/c++/v1/__config_site"

# Copy all of the files into the 'package' dir.
#
# TODO(parkmycar): The `lib` directory is a bit heavy and we could strip out a
# few unused `libcompiler_rt` libraries, but for now it's easier to just
# include them all.

for dir in bin include lib; do
    mkdir "package/${dir}"
    cat "${dir}.txt" | while read -r val; do 
        # Strip the 'linux:' prefix if it exists.
        val="${val#linux:}"
        # Skip anything that starts with a 'mac' prefix.
        if [[ ${val} != mac* && -n ${val} ]]; then
            eval cp -rP "llvm-project/build/${dir}/${val}" "package/${dir}/"
        fi
    done
done

# Compress the whole directory.

cd package
tar -cf - * | zstd --ultra -22 -o "../linux_${clang_arch}.tar.zst"

cd ..
mkdir artifacts
mv "linux_${clang_arch}.tar.zst" "artifacts/linux_${clang_arch}.tar.zst"

# Package up a libclang toolchain.

mkdir package_libclang

# Linux nests the libc++ one directory deep, so let's move that up.
eval cp -rP "llvm-project/build/lib/${clang_target}/libc++"* llvm-project/build/lib/.

for dir in bin lib; do
    mkdir "package_libclang/${dir}"
    cat "${dir}"_libclang.txt | while read -r val; do
        # Skip anything that starts with "mac".
        if [[ "${val}" == mac* && -n ${val} ]]; then
            continue
        fi
        # Strip the 'linux:' prefix if it exists.
        val="${val#linux:}"
        eval cp -rP "llvm-project/build/${dir}/${val}" "package_libclang/${dir}/"
    done
done

# Compress the whole directory.

cd package_libclang
tar -cf - * | zstd --ultra -22 -o "../linux_${clang_arch}_libclang.tar.zst"

cd ..
mv "linux_${clang_arch}_libclang.tar.zst" "artifacts/linux_${clang_arch}_libclang.tar.zst"
