FROM ubuntu

#Build dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt-get install -y git gcc g++ ninja-build cmake libz-dev libfftw3-dev libmxml-dev liblo-dev

#Debug tools
RUN apt-get install -y gdb
RUN apt-get install -y valgrind

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
