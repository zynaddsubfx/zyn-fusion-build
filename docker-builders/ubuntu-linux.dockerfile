FROM ubuntu

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt-get install -y make
RUN apt-get install -y sudo

COPY ./version.txt /z/
COPY ./Makefile.linux.mk /z/
COPY ./Common.mk /z/
COPY ./Install-deps.mk /z/

WORKDIR z
RUN     make -f Makefile.linux.mk install_deps
