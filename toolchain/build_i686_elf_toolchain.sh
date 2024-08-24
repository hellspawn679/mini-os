#!/bin/bash

# Exit on any error
set -e

# Define versions and target
BINUTILS_VERSION="2.40"
GCC_VERSION="12.3.0"
TARGET="i686-elf"
PREFIX="$HOME/opt/cross"
PATH="$PREFIX/bin:$PATH"

# Number of cores for parallel build
CORES=$(nproc)

# Create directories
mkdir -p "$PREFIX"
mkdir -p "$HOME/src"
cd "$HOME/src"

# Download sources
wget "https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.gz"
wget "https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz"

# Extract archives
tar -xf "binutils-$BINUTILS_VERSION.tar.gz"
tar -xf "gcc-$GCC_VERSION.tar.gz"

# Build binutils
mkdir -p "build-binutils"
cd "build-binutils"
../binutils-$BINUTILS_VERSION/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make -j$CORES
make install
cd ..

# Download GCC prerequisites
cd "gcc-$GCC_VERSION"
./contrib/download_prerequisites
cd ..

# Build GCC
mkdir -p "build-gcc"
cd "build-gcc"
../gcc-$GCC_VERSION/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc -j$CORES
make all-target-libgcc -j$CORES
make install-gcc
make install-target-libgcc
cd ..

echo "Cross-compiler for $TARGET has been built and installed to $PREFIX"
echo "Add $PREFIX/bin to your PATH to use the cross-compiler"