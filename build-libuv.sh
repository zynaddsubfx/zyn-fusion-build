cd deps/libuv-v1.9.1
./autogen.sh
./configure  --host=x86_64-w64-mingw32
LD=x86_64-w64-mingw32-gcc make
