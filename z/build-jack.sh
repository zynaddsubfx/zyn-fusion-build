set -e
#wget https://dl.dropboxusercontent.com/u/28869550/jack-1.9.10.tar.bz2
#tar xvf jack*
cd jack*
export CC=x86_64-w64-mingw32-gcc
export CXX=x86_64-w64-mingw32-g++
IS_WINDOWS=1 ./waf configure --dist-target=mingw
# --host=x86_64-w64-mingw32 --prefix=/home/vm/z/pkg/
./waf build
#make install
cd ..
