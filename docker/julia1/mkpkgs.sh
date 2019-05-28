#/bin/bash

docker build --build-arg JULIA_VERSION=1.0.4 -t julia-104-pkgs -f julia-pkgs.Dockerfile .
docker run -v $PWD:/opt/mount --rm julia-104-pkgs:latest \
    bash -c 'cp /home/jupyter/julia-*-pkgs.7z /opt/mount'
docker build --build-arg JULIA_VERSION=1.1.1 -t julia-111-pkgs -f julia-pkgs.Dockerfile .
docker run -v $PWD:/opt/mount --rm julia-111-pkgs:latest \
    bash -c 'cp /home/jupyter/julia-*-pkgs.7z /opt/mount'
