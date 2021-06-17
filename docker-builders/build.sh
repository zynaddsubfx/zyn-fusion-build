docker build -t zf-ubuntu-linux-img -f docker-builders/ubuntu-linux.dockerfile .
docker run --name zf-ubuntu-linux zf-ubuntu-linux-img make MODE=demo -f Makefile.linux.mk
docker cp zf-ubuntu-linux:/z/build/zyn-fusion-linux-64bit-3.0.5-demo.tar.bz2 .
docker rm zf-ubuntu-linux
docker run --name zf-ubuntu-linux zf-ubuntu-linux-img make MODE=release -f Makefile.linux.mk
docker cp zf-ubuntu-linux:/z/build/zyn-fusion-linux-64bit-3.0.5-release.tar.bz2 .
docker rm zf-ubuntu-linux

docker build -t zf-ubuntu-w64-img -f docker-builders/ubuntu-windows.dockerfile .
docker run --name zf-ubuntu-w64 zf-ubuntu-w64-img make MODE=demo -f Makefile.windows.mk
docker cp zf-ubuntu-w64:/z/build/zyn-fusion-windows-64bit-3.0.6-demo.zip .
docker rm zf-ubuntu-w64
docker run --name zf-ubuntu-w64 zf-ubuntu-w64-img make MODE=release -f Makefile.windows.mk
docker cp zf-ubuntu-w64:/z/build/zyn-fusion-windows-64bit-3.0.6-release.zip .
docker rm zf-ubuntu-w64
