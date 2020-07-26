FROM alpine

#Build dependencies
RUN apk update

#MXML
RUN apk add wget gcc g++ make
RUN wget --quiet https://github.com/michaelrsweet/mxml/releases/download/v3.1/mxml-3.1.tar.gz \
    && tar xvf mxml-3.1.tar.gz

WORKDIR /mxml-3.1/
RUN ./configure && make && make install

#LIBLO

WORKDIR /

RUN wget --quiet https://downloads.sourceforge.net/project/liblo/liblo/0.31/liblo-0.31.tar.gz \
    && tar xvf liblo-0.31.tar.gz

WORKDIR /liblo-0.31/
RUN ./configure && make && make install

WORKDIR /

RUN apk add git cmake zlib-dev fftw-dev
#apt-get update -qq && \
#    apt-get install -y sudo build-essential git ruby libtool libmxml-dev automake \
#    cmake libfftw3-dev libjack-jackd2-dev liblo-dev libz-dev libasound2-dev \
#    mesa-common-dev libgl1-mesa-dev libglu1-mesa-dev libcairo2-dev \
#    libfontconfig1-dev bison

RUN git clone https://github.com/zynaddsubfx/zynaddsubfx
RUN mkdir build
WORKDIR /zynaddsubfx/build
RUN cmake -DOssEnable=OFF ..

RUN make


ENTRYPOINT ["sh"]
