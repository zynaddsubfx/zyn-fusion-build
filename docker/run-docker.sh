#!/bin/sh
echo "[LOG] Granting root user access to Local X Server"
xhost local:root

echo "[LOG] Running zyn-fusion container"
docker run -it \
  --net=host \
  -e DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --device /dev/dri \
  --device /dev/snd \
  zyn-fusion
