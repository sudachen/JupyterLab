#/bin/bash

versions="1.1.1"
set -ex

proxy_port=3129
docker0=$(ifconfig docker0 | awk '/inet /{ print $2 }' )
#args="--build-arg https_proxy=http://$docker0:$proxy_port --build-arg http_proxy=http://$docker0:$proxy_port"

for p in $*; do 
case $p in 
pkgs-build)
    for ver in $versions; do
        sfx=$(echo $ver | sed -e 's/\.//g') 
        docker build $args --build-arg JULIA_VERSION=$ver -t julia-$sfx-cpu-pkgs -f julia-pkgs.Dockerfile .
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
        docker build $args --build-arg JULIA_VERSION=$ver -t julia-$sfx-bin -f julia-bin.Dockerfile .
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
