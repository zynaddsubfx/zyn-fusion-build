FROM archlinux

#Build dependencies
RUN pacman -Syu --noconfirm
RUN pacman -S git gcc ninja cmake zlib fftw mxml liblo --noconfirm
