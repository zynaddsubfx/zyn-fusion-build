# This script is meant to be run from the root of the zyn-fusion-build repo.
# It builds ZynFusion for other Linux distros than Ubuntu.

# Uncomment this line if your system requires sudo to run docker.
SUDO=sudo

#### No user parameters below this line ####

# Stops as soon as an error happens so that we don't miss anything.
set -e

DOCKER="${SUDO} docker"

# Each build runs the compilation.
${DOCKER} build -t zf-arch-linux-img -f docker-builders/arch-linux.dockerfile .
${DOCKER} build -t zf-alpine-linux-img -f docker-builders/alpine-linux.dockerfile .

${DOCKER} rmi zf-arch-linux-img
${DOCKER} rmi zf-alpine-linux-img
