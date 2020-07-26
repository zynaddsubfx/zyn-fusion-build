################################################################################
FROM alpine as mingw-libz

#Build dependencies 
RUN apk update
RUN apk add mingw-w64-gcc make

COPY ./zlib*tar.gz .

RUN tar xvf zlib*tar.gz
WORKDIR /zlib-1.2.7/

RUN CC=x86_64-w64-mingw32-gcc \
    AR=x86_64-w64-mingw32-ar \
    ./configure --prefix=/opt/pkg --static
RUN make
RUN make install

################################################################################
FROM alpine as mingw-fftw

RUN apk update
RUN apk add mingw-w64-gcc make

COPY ./fftw*tar.gz .
RUN  tar xvf fftw*tar.gz

WORKDIR /fftw-3.3.4/

RUN ./configure --host=x86_64-w64-mingw32 \
                --prefix=/opt/pkg \
                --with-our-malloc \
                --disable-mpi
RUN make
RUN make install
################################################################################
# - AR detection is broken
# - mxmldoc compilation is broken

FROM alpine as mingw-mxml

RUN apk update
RUN apk add mingw-w64-gcc make

COPY mxml-2.10.tar.gz .
RUN  tar xvf mxml*tar.gz
WORKDIR /mxml-2.10/

RUN ./configure --host=x86_64-w64-mingw32 \
                   --prefix=/opt/pkg/ \
                   --disable-shared \
                   --enable-static

RUN sed -i -e "s/^AR\t*=/AR=x86_64-w64-mingw32-ar/" Makefile

RUN ls

RUN cat Makefile

RUN make libmxml.a
RUN make -i install TARGETS=""

################################################################################
# Refuses to run with just mingw's AR

FROM alpine as mingw-pa

RUN apk update
RUN apk add mingw-w64-gcc make
RUN apk add gcc

COPY pa_stable_v19_20140130.tgz .
RUN  tar xvf pa_stable*tgz
WORKDIR portaudio

RUN ./configure --host=x86_64-w64-mingw32 \ 
                --prefix=/opt/pkg
RUN make
RUN make install

################################################################################

FROM alpine as mingw-cxxtest

RUN apk update
RUN apk add mingw-w64-gcc make
RUN apk add tar

COPY cxxtest-4.4.tar.gz .
RUN mkdir -p /opt/pkg
RUN tar xvf cxxtest*tar.gz
RUN mv cxxtest*/* /opt/pkg/

################################################################################

FROM alpine as mingw-liblo

RUN apk update
RUN apk add mingw-w64-gcc make

COPY liblo-0.28.tar.gz .
RUN tar xvf liblo-0.28.tar.gz
WORKDIR liblo-0.28
RUN ./configure --host=x86_64-w64-mingw32 \
                --prefix=/opt/pkg/ \
                --disable-shared \
                --enable-static
RUN make
RUN make install

################################################################################

FROM alpine as mingw-libuv

RUN apk update
RUN apk add mingw-w64-gcc make
RUN apk add libtool automake m4 autoconf

COPY libuv-v1.9.1.tar.gz .
RUN tar xvf libuv-v1.9.1.tar.gz
WORKDIR libuv-v1.9.1
RUN sh autogen.sh
RUN ./configure --host=x86_64-w64-mingw32 \
                --prefix=/opt/pkg/ \
                --disable-shared \
                --enable-static
RUN make
RUN make install

################################################################################

FROM alpine

RUN apk update
RUN apk add mingw-w64-gcc make

RUN apk add cmake pkgconf

COPY --from=mingw-liblo   /opt/pkg/ /opt/pkg/
COPY --from=mingw-fftw    /opt/pkg/ /opt/pkg/
COPY --from=mingw-mxml    /opt/pkg/ /opt/pkg/
COPY --from=mingw-libz    /opt/pkg/ /opt/pkg/
COPY --from=mingw-cxxtest /opt/pkg/ /opt/pkg/
COPY --from=mingw-libuv   /opt/pkg/ /opt/pkg/

COPY zynaddsubfx /zynaddsubfx/
RUN  mkdir /zynaddsubfx/build
COPY mingw64-build.cmake /zynaddsubfx/build/
RUN ls
WORKDIR zynaddsubfx/build
RUN cmake -DCMAKE_TOOLCHAIN_FILE=mingw64-build.cmake \
          -DOssEnable=False \
          -DGuiModule=zest \
          -DDemoMode=ON \
          -DCMAKE_INSTALL_PREFIX=/usr \
          -DDefaultOutput=pa \
          ..
RUN make


RUN apk add ruby-rake
RUN apk add python2
RUN apk add bison
RUN apk add gcc musl-dev

#git should not be needed...
RUN apk add git

COPY mruby-zest-build /mruby-zest-build/
WORKDIR /mruby-zest-build/

RUN make clean
RUN cp /opt/pkg/lib/libuv.a deps/libuv-win.a
#RUN ls /usr/x86_64-w64-mingw32/lib/

RUN CC=x86_64-w64-mingw32-gcc \
    CXX=x86_64-w64-mingw32-g++ \
    AR=x86_64-w64-mingw32-ar \
    LD=x86_64-w64-mingw32-gcc \
    CCLD=x86_64-w64-mingw32-gcc \
    CFLAGS=-I/opt/pkg/include/uv/ \
    LDFLAGS=-L/usr/x86_64-w64-mingw32/lib \
    make windows
