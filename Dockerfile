FROM debian:stretch
RUN apt-get update -qq && \
    apt-get install -y sudo build-essential git ruby libtool libmxml-dev automake \
    cmake libfftw3-dev libjack-jackd2-dev liblo-dev libz-dev libasound2-dev \
    mesa-common-dev libgl1-mesa-dev libglu1-mesa-dev libcairo2-dev \
    libfontconfig1-dev bison
COPY . /zyn-fusion-build
WORKDIR /zyn-fusion-build
RUN ruby build-linux.rb
RUN tar -jxvf zyn-fusion-linux-64bit-3.0.3-patch1-release.tar.bz2
WORKDIR /zyn-fusion-build/zyn-fusion
RUN bash ./install-linux.sh
ENTRYPOINT [ "zynaddsubfx", "-O", "alsa" ]