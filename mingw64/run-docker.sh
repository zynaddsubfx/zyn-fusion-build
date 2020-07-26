#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

set -v

DEP_ZLIB=zlib-1.2.7.tar.gz
GET_ZLIB=http://downloads.sourceforge.net/libpng/zlib/1.2.7/$DEP_ZLIB
DEP_FFTW=fftw-3.3.4.tar.gz
GET_FFTW=http://www.fftw.org/fftw-3.3.4.tar.gz
DEP_LIBLO=liblo-0.28.tar.gz
GET_LIBLO=http://downloads.sourceforge.net/liblo/liblo-0.28.tar.gz
DEP_MXML=mxml-2.10.tar.gz
GET_MXML=https://github.com/michaelrsweet/mxml/releases/download/release-2.10/mxml-2.10.tar.gz
DEP_PA=pa_stable_v19_20140130.tgz
GET_PA=http://www.portaudio.com/archives/pa_stable_v19_20140130.tgz
DEP_CXT=cxxtest-4.4.tar.gz
GET_CXT=https://sourceforge.net/projects/cxxtest/files/cxxtest/4.4/cxxtest-4.4.tar.gz
DEP_UV=libuv-v1.9.1.tar.gz
GET_UV=http://dist.libuv.org/dist/v1.9.1/libuv-v1.9.1.tar.gz

[ -f $DEP_LIBLO ] || wget $GET_LIBLO
[ -f $DEP_ZLIB ]  || wget $GET_ZLIB
[ -f $DEP_FFTW ]  || wget $GET_FFTW
[ -f $DEP_MXML ]  || wget $GET_MXML
[ -f $DEP_CXT ]   || wget $GET_CXT
[ -f $DEP_PA ]    || wget $GET_PA
[ -f $DEP_UV ]    || wget $GET_UV

[ -d zynaddsubfx ] || git clone https://github.com/zynaddsubfx/zynaddsubfx
cd zynaddsubfx
git submodule update --init
cd ..
[ -d mruby-zest-build ] || git clone https://github.com/mruby-zest/mruby-zest-build
cd mruby-zest-build
git submodule update --init
