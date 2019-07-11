FROM sudachen/python3-base:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"

#ADD --chown=lab:users libmxnet-${CPGPU}.tar.gz /
USER lab

RUN set -ex \
 && cd / \
 && curl -L ${JUPYTERLAB_URL}/libmxnet-${CPGPU}.tar.gz | sudo tar zx \
 && cd /tmp \
 && git clone --branch 0.44.0 git://github.com/numba/numba.git \
 && cd numba \
 && python setup.py install \
 && numba -s  | sed '/Conda/,$d' \
 && cd .. \
 && rm -rf numba \
 && pip install -U --no-cache-dir \
     git+https://github.com/sudachen/python-mxnet-1.4.1.git \
     gluoncv \
     gluonnlp \
     Augmentor \
     fastparquet \
     param \
     mxboard \
 && MPLBACKEND=Agg python -c "import matplotlib.pyplot" \
 && rm -rf /tmp/* 





