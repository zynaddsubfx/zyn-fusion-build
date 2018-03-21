set -e
wget https://github.com/michaelrsweet/mxml/releases/download/release-2.10/mxml-2.10.tar.gz
tar xvf mxml-2.10.tar.gz
cd mxml-2.10

./configure --host=x86_64-w64-mingw32 --prefix=`pwd`/../pkg/ --disable-shared --enable-static
make libmxml.a
make -i install TARGETS=""

cd ..
