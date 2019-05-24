FROM sudachen/jupyter1:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"
LABEL com.nvidia.volumes.needed="nvidia_driver"
LABEL com.nvidia.cuda.version="9.2"
LABEL com.nvidia.cudnn.version="7.4"
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=9.2"
ENV FULLREBUILD 20190523
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get install -qy --no-install-recommends \
       software-properties-common \
 && add-apt-repository -y ppa:graphics-drivers/ppa \
 && apt-get install -y libnvidia-compute-390 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* 
 
# Python 2.7
USER $NB_USER
RUN conda create -n python27 python=2.7 \
 && conda install -n python27 -c conda-forge \
       'blas=*=*openblas*' \
       'numpy=1.14.*=*openblas*' \
       'pandas=0.23.*' \
       'sqlalchemy=1.2.*' \
       'libpq=9.6.*' \
       'psycopg2=2.7.*' \
       'pymysql=0.8.*' \
 && conda clean -tipsy \
 && rm -rf ${CONDA_DIR}/pkgs/*

# COLAB
USER root
ENV GCLOUD_DIR /opt/google_cloud
RUN mkdir ${GCLOUD_DIR} \
 && chown ${NB_USER}:${NB_GID} ${GCLOUD_DIR} \
 && fix-permissions ${GCLOUD_DIR} 

USER $NB_USER    
RUN curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-202.0.0-linux-x86_64.tar.gz \
    | gzip -d \
    | tar x -C ${GCLOUD_DIR} --strip-components=1 \
 && pip install -U --no-cache-dir google-auth portpicker \
 && mkdir -p ${HOME}/content/datalab \
 && mkdir -p ${HOME}/.config/gcloud \
 && ln -s ${HOME}/.config/gcloud ${HOME}/content/datalab/.config \
 && ln -s ${HOME}/.config/gcloud ${HOME}/content/.config 

ENV CLOUDSDK_ROOT_DIR=$GCLOUD_DIR \
    CLOUDSDK_PYTHON=$CONDA_DIR/envs/python27/bin/python2 \
    PATH=$PATH:$GCLOUD_DIR/bin \
    DATALAB_ROOT=$HOME 

# JupyterLab
USER $NB_USER
RUN pip install -U --no-cache-dir 'jupyterlab>=0.35,<1.0' \
 && jupyter nbextension enable --py widgetsnbextension --sys-prefix \
 && jupyter labextension install \
        @jupyter-widgets/jupyterlab-manager@^0.38 \
        jupyterlab_bokeh \
 && jupyter labextension install @jupyterlab/github \
 && pip install --no-cache-dir jupyterlab_github \
 && jupyter serverextension enable --py jupyterlab_github \
 && pip install --no-cache-dir git+https://github.com/googlecolab/jupyter_http_over_ws#egg=jupyter_http_over_ws \
 && jupyter serverextension enable --py jupyter_http_over_ws \
 && pip install -U --no-cache-dir jupyterlab-git \
 && jupyter serverextension enable --py jupyterlab_git \
 && jupyter labextension install \
        @jupyterlab/mp4-extension \
        @jupyterlab/google-drive \
        @jupyterlab/git \
        dask-labextension \
 && rm -rf ${CONDA_DIR}/share/jupyter/lab/staging \
 && rm -rf ${HOME}/.cache/yarn \
 && rm -rf ${HOME}/.node-gyp \
 && conda clean -tipsy \
 && npm cache clean --force \
 && rm -rf ${CONDA_DIR}/pkgs/* 

USER root
ADD jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py
RUN fix-permissions /etc/jupyter/

EXPOSE 8888
WORKDIR $HOME
ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "jupyter", "lab" ]

USER $NB_USER