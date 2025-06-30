FROM ubuntu:22.04 AS base_image

# Tools needed to install bootsrap clang.
RUN apt-get update && apt-get install -y \
    wget \
    lsb-release \
    software-properties-common \
    gnupg \
    clang \
    llvm \
    lld


FROM base_image AS llvm_image

RUN apt-get update && apt-get install -y \
    git

WORKDIR /downloads

ARG CLANG_VERSION
ENV CLANG_VERSION=$CLANG_VERSION

# Shallow clone of the LLVM project since it's quite large.
RUN git clone \
    --depth 1 \
    --branch llvmorg-$CLANG_VERSION \
    https://github.com/llvm/llvm-project.git


FROM llvm_image AS build_image

RUN apt-get update && apt-get install -y \
    # Tools needed by the build process.
    zstd \
    cmake \
    gcc \
    ninja-build \
    # Libraries we statically link into clang.
    zlib1g-dev \
    libzstd-dev \
    libncurses-dev \
    libxml2-dev

WORKDIR /downloads/llvm-project

COPY clang_build.sh clang_build.sh
RUN chmod +x clang_build.sh
RUN ./clang_build.sh $CLANG_VERSION

FROM build_image AS package_image

WORKDIR /downloads

COPY bin.txt bin.txt
COPY include.txt include.txt
COPY lib.txt lib.txt

COPY bin_libclang.txt bin_libclang.txt
COPY lib_libclang.txt lib_libclang.txt

COPY clang_package.sh clang_package.sh
RUN chmod +x clang_package.sh

RUN ./clang_package.sh $CLANG_VERSION
