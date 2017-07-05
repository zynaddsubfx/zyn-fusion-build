#wget http://www.msweet.org/files/project3/mxml-2.10.tar.gz
#tar xvf mxml*
cd mxml*

./configure --host=x86_64-w64-mingw32 --prefix=/home/vm/z/pkg/ --disable-shared --enable-static
make libmxml.a
make -i install TARGETS=""

cd ..
