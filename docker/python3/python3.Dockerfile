FROM sudachen/python3-base:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"

ADD --chown=lab:users libmxnet-${CPGPU}.tar.gz /

USER lab

RUN pip install -U --no-cache-dir \
     git+https://github.com/sudachen/python-mxnet-1.4.1.git \
     gluoncv \
     gluonnlp 

RUN set -ex \
 && cd /tmp \
 && git clone git://github.com/numba/numba.git \
 && cd numba \
 && python setup.py install \
 && numba -s  | sed '/Conda/,$d' \
 && cd .. \
 && rm -rf numba




