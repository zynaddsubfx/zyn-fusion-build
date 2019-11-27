set -e
echo "----------------------Getting Packages-----------------------"
pacman 		-Syuu --noconfirm
pacman 		-S --noconfirm --needed git ruby gcc bison util-macros automake libtool mingw-w64-x86_64-cmake cmake mingw-w64-x86_64-mruby python3 autoconf zip make
pacman 		-S --noconfirm --needed mingw-w64-x86_64-gcc mingw-w64-x86_64-make mingw-w64-x86_64-pkg-config mingw-w64-x86_64-gcc-fortran mingw-w64-x86_64-gcc-libgfortran
mkdir pkg -p

echo "------------------------Cleaning-----------------------------"
rm			-rf zynaddsubfx -v
rm 			-rf mruby-zest-build -v
rm 			-f fftw-*.tar.gz* -v
rm 			-f liblo-*.tar.gz* -v
rm 			-f mxml-*.tar.gz* -v
rm 			-f zlib-*.tar.gz* -v
rm 			-f pa_stable_*.tgz* -v
rm 			-f cxx*tar.gz -v
rm 			-rf pkg -v

echo "-------Getting ZynAddSubFx------------"
git clone --depth=1 https://github.com/zynaddsubfx/zynaddsubfx
cd zynaddsubfx
git submodule update --init
cd ..

echo "-------Getting FFTW------------------"
wget http://www.fftw.org/fftw-3.3.4.tar.gz
tar xvf fftw*.tar.gz
rm fftw*.tar.gz
cd fftw*
./configure --prefix=`pwd`/../pkg/ --with-our-malloc --disable-mpi
make
make install
cd ..

echo "--------Getting Liblo-----------------"
wget http://downloads.sourceforge.net/liblo/liblo-0.28.tar.gz
tar xvf liblo*.tar.gz
cd liblo-0.28
./configure --prefix=`pwd`/../pkg/ --disable-shared --enable-static
make
make install
cd ..

echo "--------Getting Portaudio--------------"
wget http://www.portaudio.com/archives/pa_stable_v19_20140130.tgz
rm -rf portaudio
tar xvf pa_stable*.tgz
cd portaudio*
./configure --prefix=`pwd`/../pkg/
make
make install
cd ..

echo "--------Getting Zlib--------------------"
wget http://downloads.sourceforge.net/libpng/zlib/1.2.7/zlib-1.2.7.tar.gz
tar xvf zlib-1.2.7.tar*
rm zlib-1.2.7.tar*
cd zlib* 
cmake -G "MSYS Makefiles" -DCMAKE_INSTALL_PREFIX=`pwd`/../pkg/
make
make install
cd ..

echo "--------Getting Mxml---------------------"
wget https://github.com/michaelrsweet/mxml/releases/download/release-2.10/mxml-2.10.tar.gz
tar xvf mxml-2.10.tar.gz
cd mxml-2.10
./configure --prefix=`pwd`/../pkg/ --disable-shared --enable-static
make libmxml.a
make -i install TARGETS=""
cd ..

#Copying libwinpthread.dll
cp /mingw64/bin/libwinpthread* ./pkg/bin/

echo "---------Getting Zest---------------------"
git clone --depth=1 https://github.com/mruby-zest/mruby-zest-build
cd mruby-zest-build
git submodule update --init
git apply ../mruby-zest-no-process.patch
cd deps/mruby-dir-glob && git apply ../../../mruby-dir-glob-no-process.patch
cd ../mruby-io && git apply ../../../mruby-io-libname.patch
cd ../../mruby && git apply ../../mruby-float-patch.patch
cd ../
ruby rebuild-fcache.rb
make setupwin
make builddepwin
cd ..

./z/build-package.sh demo true
./z/build-package.sh release false
