#/bin/bash

versions="1.1.1"
set -ex

proxy_port=3129
docker0=$(ifconfig docker0 | awk '/inet /{ print $2 }' )
args="--build-arg https_proxy=http://$docker0:$proxy_port --build-arg http_proxy=http://$docker0:$proxy_port"

for p in $*; do 
case $p in 
mxnet-build)
    docker build $args -t libmxnet-pkgs -f libmxnet-pkgs.Dockerfile .
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
esac
done
