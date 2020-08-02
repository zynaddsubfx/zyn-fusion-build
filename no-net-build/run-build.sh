git clone https://github.com/zynaddsubfx/zynaddsubfx
(cd zynaddsubfx && git submodule update --init)
docker build -t arch-buildenv-zyn -f arch-buildenv-zyn.dockerfile \
             .
docker build -t arch-nonet-zyn    -f arch-nonet-zynaddsubfx.dockerfile \
              --network none .

git clone https://github.com/mruby-zest/mruby-zest-build
(cd mruby-zest-build && git submodule update --init)
DEP_UV=libuv-v1.9.1.tar.gz
GET_UV=http://dist.libuv.org/dist/v1.9.1/libuv-v1.9.1.tar.gz
[ -f $DEP_UV ]    || wget $GET_UV

docker build -t arch-buildenv-zest -f arch-buildenv-zest.dockerfile \
             .
docker build -t arch-nonet-zest   -f arch-nonet-zest.dockerfile \
              --network none .


