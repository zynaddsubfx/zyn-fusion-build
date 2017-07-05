#!/bin/bash
set -euo pipefail

mkdir -p pkg
cd pkg
#wget ftp://ftp.fftw.org/pub/fftw/fftw-3.3.4-dll64.zip
#unzip fftw*

#wget http://zlib.net/zlib128-dll.zip
#unzip zlib*
cd ..

#sh ./build-mxml.sh

#exit


#git clone https://github.com/zynaddsubfx/zynaddsubfx

cd zynaddsubfx
rm -rf build
mkdir -p build
cd build

#export CC=/usr/bin/x86_64-w64-mingw32-gcc
#export CXX=/usr/bin/x86_64-w64-mingw32-g++
#export AR=/usr/bin/x86_64-w64-mingw32-ar 
#export LD=/usr/bin/x86_64-w64-mingw32-gcc
##
#export CFLAGS='-g -I/usr/share/mingw-w64/include/ -I/usr/x86_64-w64-mingw32/include/'

cmake .. -DCMAKE_TOOLCHAIN_FILE=../../windows-build.cmake
make
cd ../..
cp zynaddsubfx/build/src/zynaddsubfx.exe pkg/bin/
