FROM arch-buildenv-zyn

#Copy source to container and build
COPY zynaddsubfx/ /zynaddsubfx/
RUN mkdir build
WORKDIR /zynaddsubfx/build
RUN cmake -G Ninja ..

RUN ninja

#Run in the container exposing a port for OSC usage
ENTRYPOINT ["/zynaddsubfx/build/src/zynaddsubfx"]
