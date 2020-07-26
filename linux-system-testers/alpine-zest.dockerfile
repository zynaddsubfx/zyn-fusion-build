FROM alpine

#Build dependencies
RUN apk update

#Basics 
RUN apk add gcc g++ make ruby

#Network
RUN apk add libuv-static libuv-dev

#Ruby
RUN apk add ruby ruby-rake

#PUGL
RUN apk add python2 libx11-dev mesa-dev

#MISC
RUN apk add git bison

RUN git clone https://github.com/mruby-zest/mruby-zest-build

WORKDIR mruby-zest-build

RUN git submodule update --init

RUN make
