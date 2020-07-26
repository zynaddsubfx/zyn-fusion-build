FROM ubuntu as ubuntu-libuv

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt-get install -y gcc make
RUN apt-get install -y libtool automake m4 autoconf

COPY libuv-v1.9.1.tar.gz .
RUN tar xvf libuv-v1.9.1.tar.gz
WORKDIR libuv-v1.9.1
RUN sh autogen.sh
RUN CFLAGS=-fPIC ./configure --prefix=/opt/pkg/ \
                             --disable-shared \
                             --enable-static
RUN CFLAGS=-fPIC make
RUN make install

############################################################
FROM ubuntu

#Build dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

#Basics 
RUN apt-get install -y gcc g++ make

#Network
RUN apt-get install -y libuv1-dev

#Ruby
RUN apt-get install -y ruby rake

#PUGL
RUN apt-get install -y python2 libx11-dev mesa-common-dev

#MISC
RUN apt-get install -y git bison

RUN git clone https://github.com/mruby-zest/mruby-zest-build

WORKDIR mruby-zest-build

RUN git submodule update --init

COPY --from=ubuntu-libuv   /opt/pkg/ /opt/pkg/
RUN mkdir -p deps/libuv-v1.9.1/.libs/
RUN cp /opt/pkg/lib/libuv.a deps/libuv-v1.9.1/.libs/
RUN cp /opt/pkg/lib/libuv.a deps/

RUN make
