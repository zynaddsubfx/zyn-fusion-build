FROM alpine:edge

#Build dependencies
RUN apk update

#Basics 
RUN apk add make git

RUN apk add gcc g++ wget zlib-dev fftw-dev libuv-static libuv-dev ruby ruby-rake libx11-dev mesa-dev

RUN apk add mxml-dev

RUN apk add liblo-dev --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/

#Build dependencies 
COPY ./version.txt /z/
COPY ./Makefile.linux.mk /z/
COPY ./Common.mk /z/
COPY ./Install-deps.mk /z/

RUN  cd z && make -f Makefile.linux.mk install_deps
RUN  cd z && make -f Makefile.linux.mk
