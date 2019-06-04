#/bin/bash

versions="1.1.1"
set -ex

for ver in $versions; do
    if [ ! -f julia-$ver-linux-x86_64.tar.gz ] 
    then
        wget -L https://julialang-s3.julialang.org/bin/linux/x64/`echo $ver | cut -d. -f 1,2`/julia-$ver-linux-x86_64.tar.gz
    fi
done

for ver in $versions; do
    sfx=$(echo $ver | sed -e 's/\.//g') 
    docker build --build-arg JULIA_VERSION=$ver -t julia-$sfx-cpu-pkgs -f julia-pkgs.Dockerfile .
    docker run -v $PWD:/opt/mount --rm julia-$sfx-cpu-pkgs:latest \
        bash -c 'cp /lab/julia-*-pkgs.tar.bz2 /opt/mount'
done



