wget http://downloads.sourceforge.net/libpng/zlib/1.2.7/zlib-1.2.7.tar.gz

tar xvf zlib*
cd zlib*

CC=x86_64-w64-mingw32-gcc ./configure --prefix=`pwd`/../pkg/ --static
make
make install

cd ..
