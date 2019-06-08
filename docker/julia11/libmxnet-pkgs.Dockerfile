FROM sudachen/python3:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"

ENV CPGPU=gpu
LABEL com.nvidia.volumes.needed="nvidia_driver"
LABEL com.nvidia.cuda.version="10.0"
LABEL com.nvidia.cudnn.version="7.6"
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0"
ENV PATH=/usr/local/cuda-10.0/bin:$PATH
ENV CUDA_HOME=/usr/local/cuda-10.0

USER root
RUN set -ex && cd /tmp \ 
  && curl -L $JUPYTERLAB_URL/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb -o /tmp/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb \
  && dpkg -i /tmp/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb \
  && rm /tmp/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb \ 
  && apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub \
  && apt-get update  \
  && apt-get install -qy \
    libnvidia-compute-418 \
  && apt-get install -qy \
    cuda-cublas-10-0 \
    cuda-cudart-10-0 \
    cuda-cufft-10-0 \
    cuda-curand-10-0 \
    cuda-cusolver-10-0 \
    cuda-cusparse-10-0 \
    cuda-nvjpeg-10-0 \
    cuda-nvcc-10-0 \
    cuda-nvrtc-10-0 \
    cuda-cupti-10-0 \
    cuda-cublas-dev-10-0 \
    cuda-cudart-dev-10-0 \
    cuda-curand-dev-10-0 \
    cuda-cufft-dev-10-0 \
    cuda-cusolver-dev-10-0 \
    cuda-cusparse-dev-10-0 \
    cuda-nvjpeg-dev-10-0 \
    cuda-nvrtc-dev-10-0 \
    cuda-nvtx-10-0 \
  && apt-get install -qy ccache \
  && /usr/sbin/update-ccache-symlinks \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* 

RUN cd /tmp \
  && curl -L $JUPYTERLAB_URL/libcudnn7.7z -o /tmp/libcudnn7.7z \
  && 7z x /tmp/libcudnn7.7z \
  && dpkg -i /tmp/libcudnn7/*.deb \
  && rm -r /tmp/libcudnn* \
  && echo "/usr/local/conda-10.0/lib64" > /etc/ld.so.conf.d/cuda-10.0.conf \
  && ldconfig \
  && usermod -aG video lab \
  && chown lab:users $HOME/.[^.]* \
  && chown lab:users -R $HOME/.gnu*

ENV PATH="/usr/lib/ccache:$PATH"

USER lab
RUN git clone --branch 1.4.1 --recursive https://github.com/apache/incubator-mxnet.git

RUN pip install lit

RUN set -ex \
 && cd incubator-mxnet \
 && mkdir -p build-cpu \
 && cd build-cpu \
 && cmake -GNinja \
      -DUSE_CUDA=0 \
      -DBLAS=open \
      -DUSE_JEMALLOC=0 \
      -DUSE_MKL_IF_AVAILABLE=0 \
      -DCMAKE_CUDA_COMPILER_LAUNCHER=ccache \
      -DCMAKE_C_COMPILER_LAUNCHER=ccache \
      -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \ 
    .. \
 && ninja -j6

USER lab
RUN set -ex \
 && cd incubator-mxnet \
 && mkdir -p build-gpu \
 && cd build-gpu \
 && cmake -GNinja \
      -DUSE_CUDA=1 \
      -DUSE_CUDNN=1 \
      -DBLAS=open \
      -DUSE_JEMALLOC=0 \
      -DUSE_MKL_IF_AVAILABLE=0 \
      -DCMAKE_CUDA_COMPILER_LAUNCHER=ccache \
      -DCMAKE_C_COMPILER_LAUNCHER=ccache \
      -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \ 
    .. \
 && ninja -j6


USER root
RUN set -ex \
 && cd incubator-mxnet/build-gpu \
 && cp libmxnet.so /usr/lib/x86_64-linux-gnu/ \
 && chown root:root /usr/lib/x86_64-linux-gnu/libmxnet.* \
 && tar zcf /lab/libmxnet-gpu.tar.gz /usr/lib/x86_64-linux-gnu/libmxnet.*

USER root
RUN set -ex \
 && cd incubator-mxnet/build-cpu \
 && cp libmxnet.so /usr/lib/x86_64-linux-gnu/ \
 && chown root:root /usr/lib/x86_64-linux-gnu/libmxnet.* \
 && tar zcf /lab/libmxnet-cpu.tar.gz /usr/lib/x86_64-linux-gnu/libmxnet.*

USER lab 

#RUN set -ex \
# && cd incubator-mxnet/python \
# && ln -s /usr/lib/x86_64-linux-gnu/libmxnet.so mxnet \
# && python setup.py bdist_wheel 
#RUN set -ex \
# && pip install --upgrade nose \
# && cd incubator-mxnet \
# && cd python \
# && cp /usr/lib/x86_64-linux-gnu/libmxnet.so mxnet \
# && pip install -e . \
# && cd .. \
# && nosetests tests/python/unittest \
# && nosetests tests/python/train


