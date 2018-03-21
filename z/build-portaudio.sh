set -e
wget http://www.portaudio.com/archives/pa_stable_v19_20140130.tgz
rm -rf portaudio
tar xvf pa_stable*.tgz
cd portaudio*
#export CC=x86_64-w64-mingw32-gcc
#export CXX=x86_64-w64-mingw32-g++
./configure --host=x86_64-w64-mingw32 --prefix=`pwd`/../pkg/
make
make install
cd ..
