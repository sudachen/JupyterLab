#/bin/bash

set -ex

for t in cpu gpu; do
    case $t in cpu) ta=;; *) ta=-$t;; esac
    echo "FROM sudachen/jupyter1$ta:latest" > julia-pkgs.Dockerfile.build
    cat julia-pkgs.Dockerfile >> julia-pkgs.Dockerfile.build
    for ver in 1.1.1; do
        sfx=$(echo $ver | sed -e 's/\.//g') 
        docker build --build-arg JULIA_VERSION=$ver -t julia-$sfx-$t-pkgs -f julia-pkgs.Dockerfile.build .
        docker run -v $PWD:/opt/mount --rm julia-$sfx-$t-pkgs:latest \
            bash -c 'cp /home/jupyter/julia-*-pkgs.7z /opt/mount'
    done
done


