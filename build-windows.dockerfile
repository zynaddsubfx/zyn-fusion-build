################################################################################
FROM ubuntu

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt-get install -y git ruby ruby-dev bison g++-mingw-w64-x86-64 autotools-dev automake libtool premake4 cmake
RUN apt-get install -y sudo
RUN apt-get install -y wget
RUN apt-get install -y pkg-config

#Build dependencies 
COPY ./build-windows.rb .
RUN  mkdir z
COPY ./z/build-fftw.sh ./z/
COPY ./z/build-jack.sh ./z/
COPY ./z/build-liblo.sh ./z/
COPY ./z/build-mxml.sh ./z/
COPY ./z/build-package.sh ./z/
COPY ./z/build-portaudio.sh ./z/
COPY ./z/build-zlib.sh ./z/
COPY ./z/build.sh ./z/
COPY ./z/mingw64-build.cmake ./z/
COPY ./z/windows-build.cmake ./z/
COPY ./mruby-dir-glob-no-process.patch .
COPY ./mruby-sleep-length.patch .
COPY ./mruby-io-libname.patch .
COPY ./mruby-float-patch.patch .

RUN ruby build-windows.rb
