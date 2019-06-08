#/bin/bash

versions="1.1.1"
set -ex

for p in $*; do 
case $p in 
mxnet-build)
    docker build -t libmxnet-pkgs -f libmxnet-pkgs.Dockerfile .
    docker run -v $PWD:/opt/mount --rm libmxnet-pkgs:latest \
        bash -c 'cp /lab/libmxnet-*.tar.gz /opt/mount'
    ;;
mxnet-copy)
    for tg in cpu gpu; do
        if [ ! -f libmxnet-$tg.tar.gz ] 
        then
            wget -L https://github.com/sudachen/JupyterLab/releases/download/release1/libmxnet-$tg.tar.gz
        fi
    done
    ;;
pkgs-build)
    for ver in $versions; do
        sfx=$(echo $ver | sed -e 's/\.//g') 
        docker build --build-arg JULIA_VERSION=$ver -t julia-$sfx-cpu-pkgs -f julia-pkgs.Dockerfile .
        docker run -v $PWD:/opt/mount --rm julia-$sfx-cpu-pkgs:latest \
            bash -c 'cp /lab/julia-*-pkgs.tar.bz2 /opt/mount'
    done
    ;;
pkgs-copy)
    for ver in $versions; do
        if [ ! -f julia-$ver-cpu-pkgs.tag.bz2 ] 
        then
	    wget -L https://github.com/sudachen/JupyterLab/releases/download/release1/julia-$ver-cpu-pkgs.tag.bz2
        fi
    done
    ;;
julia-build)
    for ver in $versions; do
        sfx=$(echo $ver | sed -e 's/\.//g') 
        docker build --build-arg JULIA_VERSION=$ver -t julia-$sfx-bin -f julia-bin.Dockerfile .
        docker run -v $PWD:/opt/mount --rm julia-$sfx-bin:latest \
            bash -c 'cp /lab/julia-*-bin.tar.bz2 /opt/mount'
    done
    ;;
julia-copy)
    for ver in $versions; do
        if [ ! -f julia-$ver-bin.tag.bz2 ] 
        then
	    wget -L https://github.com/sudachen/JupyterLab/releases/download/release1/julia-$ver-bin.tag.bz2
        fi
    done
    ;;
esac
done
