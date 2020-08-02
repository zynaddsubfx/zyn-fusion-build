# Arch does not build with a static libuv option
# Eventually we should just link against the shared libuv option
FROM archlinux as archlinux-libuv

#Build dependencies
RUN pacman -Syu --noconfirm

#Basics
RUN pacman -S gcc make --noconfirm
RUN pacman -S libtool automake m4 autoconf --noconfirm

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
FROM archlinux

#Build dependencies
RUN pacman -Syu --noconfirm

#Basics
RUN pacman -S gcc make --noconfirm

#Network
RUN pacman -S libuv --noconfirm

#Ruby
RUN pacman -S ruby rake --noconfirm

#PUGL
RUN pacman -S python2 libx11 mesa --noconfirm

#MISC Note - arch has a broken dependency as gettext is only needed for bison
RUN pacman -S bison --noconfirm
RUN pacman -S gettext --noconfirm

COPY --from=archlinux-libuv   /opt/pkg/ /opt/pkg/
