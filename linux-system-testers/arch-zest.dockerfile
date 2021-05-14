# Arch does not build with a static libuv option
# Eventually we should just link against the shared libuv option
FROM archlinux as archlinux-libuv

#HACK
RUN patched_glibc=glibc-linux4-2.33-4-x86_64.pkg.tar.zst && \
curl -LO "https://repo.archlinuxcn.org/x86_64/$patched_glibc" && \
bsdtar -C / -xvf "$patched_glibc"

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

#HACK
RUN patched_glibc=glibc-linux4-2.33-4-x86_64.pkg.tar.zst && \
curl -LO "https://repo.archlinuxcn.org/x86_64/$patched_glibc" && \
bsdtar -C / -xvf "$patched_glibc"

#Build dependencies
RUN pacman -Syu --noconfirm

#Basics 
RUN pacman -S gcc make pkgconf --noconfirm

#Network
RUN pacman -S libuv --noconfirm

#Ruby
RUN pacman -S ruby rake --noconfirm

#PUGL
RUN pacman -S python2 libx11 mesa --noconfirm

#MISC Note - arch has a broken dependency as gettext is only needed for bison
RUN pacman -S git bison --noconfirm
RUN pacman -S gettext --noconfirm 

RUN git clone https://github.com/mruby-zest/mruby-zest-build

WORKDIR mruby-zest-build

RUN git submodule update --init

COPY --from=archlinux-libuv   /opt/pkg/ /opt/pkg/
RUN mkdir -p deps/libuv-v1.9.1/.libs/
RUN cp /opt/pkg/lib/libuv.a deps/libuv-v1.9.1/.libs/
RUN cp /opt/pkg/lib/libuv.a deps/

RUN make
