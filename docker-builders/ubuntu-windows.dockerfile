################################################################################
FROM ubuntu

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt-get install -y make
#git ruby ruby-dev bison g++-mingw-w64-x86-64 autotools-dev automake libtool premake4 cmake
#make
RUN apt-get install -y sudo

#Build dependencies 
COPY ./version.txt /z/
COPY ./Common.mk /z/
COPY ./Install-deps.mk /z/
COPY ./Makefile.windows.mk /z/
COPY ./z/windows-build.cmake /z/z/

WORKDIR z
RUN  make -f Makefile.windows.mk install_deps
