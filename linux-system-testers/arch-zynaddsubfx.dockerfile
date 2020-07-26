FROM archlinux

#Build dependencies
RUN pacman -Syu --noconfirm
RUN pacman -S git gcc ninja cmake zlib fftw mxml liblo --noconfirm

#Debug tools
RUN pacman -S gdb      --noconfirm
RUN pacman -S valgrind --noconfirm

#Copy source to container and build
COPY zynaddsubfx/ /zynaddsubfx/
RUN mkdir build
WORKDIR /zynaddsubfx/build
RUN cmake -G Ninja -DOssEnable=OFF -DBuildForDebug=ON ..

RUN ninja

#Run in the container exposing a port for OSC usage
EXPOSE 1234
ENTRYPOINT ["gdb", "/zynaddsubfx/build/src/zynaddsubfx"]
#, "-I null", "-O null", "-P 1234"]
#ENTRYPOINT ["/zynaddsubfx/build/src/zynaddsubfx", "-P 1234"]
