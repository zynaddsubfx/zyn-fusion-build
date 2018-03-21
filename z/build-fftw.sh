set -e
wget http://www.fftw.org/fftw-3.3.4.tar.gz
tar xvf fftw*tar.gz --skip-old-files  
cd fftw*
./configure --host=x86_64-w64-mingw32 --prefix=`pwd`/../pkg/ --with-our-malloc --disable-mpi
make
make install
cd ..
