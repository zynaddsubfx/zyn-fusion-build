SET(CMAKE_SYSTEM_NAME Windows)


SET(CMAKE_C_COMPILER /usr/bin/x86_64-w64-mingw32-gcc)
SET(CMAKE_CXX_COMPILER /usr/bin/x86_64-w64-mingw32-g++)
SET(CMAKE_RC_COMPILER /usr/bin/x86_64-w64-mingw32-windres)

# This PREFIX_PATH will be specified by -DPREFIX_PATH when invoking cmake
SET(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32/ ${PREFIX_PATH})

#export LD=/usr/bin/x86_64-w64-mingw32-gcc
