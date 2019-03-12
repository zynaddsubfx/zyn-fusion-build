#!/bin/sh

echo "[LOG] Building docker image"
docker build -t zyn-fusion .

./run-docker.sh