cd deps/glpk-4.52
CFLAGS="-DDBL_EPSILON=2e-16" ./configure --disable-shared --enable-static --host=x86_64-w64-mingw32
make
