#!/bin/sh
docker ps -a | grep bsarda/vault | awk '{print $1}' | xargs -n1 docker rm -f
docker rmi bsarda/vault
# build!
docker build --no-cache -t bsarda/vault .
