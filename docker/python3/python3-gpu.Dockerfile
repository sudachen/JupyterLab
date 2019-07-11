FROM sudachen/python3-base:latest
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
RUN  curl -L $JUPYTERLAB_URL/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb -o /tmp/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb \
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
    cuda-nvtx-10-0 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && curl -L $JUPYTERLAB_URL/libcudnn7_7.6.0.64-1+cuda10.0_amd64.deb -o /tmp/libcudnn7_7.6.0.64-1+cuda10.0_amd64.deb \
  && dpkg -i /tmp/libcudnn7_7.6.0.64-1+cuda10.0_amd64.deb \
  && rm -rf /tmp/* \
  && echo "/usr/local/conda-10.0/lib64" > /etc/ld.so.conf.d/cuda-10.0.conf \
  && ldconfig \
  && usermod -aG video lab \
  && chown lab:users $HOME/.[^.]* \
  && chown lab:users -R $HOME/.gnu*

USER lab

