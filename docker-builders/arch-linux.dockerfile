FROM archlinux

#Build dependencies
RUN pacman -Syu --noconfirm

#Basics 
RUN pacman -Syu gcc make pkgconf git --noconfirm

RUN pacman -S sudo --noconfirm

RUN pacman -S ruby fftw mxml liblo zlib libx11 mesa --noconfirm

#Build dependencies 
COPY ./version.txt /z/
COPY ./Makefile.linux.mk /z/
COPY ./Common.mk /z/
COPY ./Install-deps.mk /z/

RUN  cd z && make -f Makefile.linux.mk install_deps
RUN  cd z && make MODE=release PARALLEL=1 -f Makefile.linux.mk
