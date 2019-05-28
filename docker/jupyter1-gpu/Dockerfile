FROM sudachen/jupyter1:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"

LABEL com.nvidia.volumes.needed="nvidia_driver"
LABEL com.nvidia.cuda.version="10.0"
LABEL com.nvidia.cudnn.version="7.6"
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0"

ENV CPGPU=gpu

USER root
RUN  wget $JUPYTERLAB_URL/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb -q -O /tmp/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb \
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
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* 

#RUN curl -L $JUPYTERLAB_URL/libcudnn7.7z -o /tmp/libcudnn7.7z \
#  && cd /tmp \
#  && 7z x libcudnn7.7z \
#  && cd / \
#  && dpkg -i /tmp/libcudnn7/*.deb \
#  && rm -r /tmp/libcudnn7* \
#  && echo "/usr/local/conda-10.0/lib64" > /etc/ld.so.conf.d/cuda-10.0.conf \
#  && ldconfig

RUN curl -L $JUPYTERLAB_URL/libcudnn7_7.6.0.64-1+cuda10.0_amd64.deb -o /tmp/libcudnn7_7.6.0.64-1+cuda10.0_amd64.deb \
  && dpkg -i /tmp/libcudnn7_7.6.0.64-1+cuda10.0_amd64.deb \
  && rm -r /tmp/libcudnn7_7.6.0.64-1+cuda10.0_amd64.deb \
  && echo "/usr/local/conda-10.0/lib64" > /etc/ld.so.conf.d/cuda-10.0.conf \
  && ldconfig

ENV PATH=/usr/local/cuda-10.0/bin:$PATH

RUN usermod -aG video jupyter

USER $NB_USER
RUN pip install -U --no-cache-dir  \
      https://download.pytorch.org/whl/cu100/torch-1.1.0-cp37-cp37m-linux_x86_64.whl \
 && pip install -U --no-cache-dir  \
      https://download.pytorch.org/whl/cu100/torchvision-0.3.0-cp37-cp37m-linux_x86_64.whl
