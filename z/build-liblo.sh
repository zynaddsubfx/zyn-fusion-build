set -e
wget http://downloads.sourceforge.net/liblo/liblo-0.28.tar.gz
tar xvf liblo*tar.gz --skip-old-files  
cd liblo*
./configure --host=x86_64-w64-mingw32 --prefix=`pwd`/../pkg/ --disable-shared --enable-static
make
make install
cd ..
