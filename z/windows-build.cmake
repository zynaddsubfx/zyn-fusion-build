SET(CMAKE_SYSTEM_NAME Windows)


SET(CMAKE_C_COMPILER /usr/bin/x86_64-w64-mingw32-gcc)
SET(CMAKE_CXX_COMPILER /usr/bin/x86_64-w64-mingw32-g++)
SET(CMAKE_RC_COMPILER /usr/bin/x86_64-w64-mingw32-windres)

SET(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32/ $ENV{THIS}/pkg)

#export LD=/usr/bin/x86_64-w64-mingw32-gcc
