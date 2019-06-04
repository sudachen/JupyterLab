FROM sudachen/julia1-gpu:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"
ENV GCLOUD_DIR ${HOME}/.google_cloud
ENV CLOUDSDK_ROOT_DIR=$GCLOUD_DIR \
    CLOUDSDK_PYTHON=$CONDA_DIR/envs/python27/bin/python2 \
    PATH=$PATH:$GCLOUD_DIR/bin \
    DATALAB_ROOT=$HOME 

USER root
RUN apt-get update && apt-get clean  

# Python 2.7
USER lab
RUN conda create -n python27 python=2.7 \
 && conda install -n python27 -c conda-forge \
       nomkl \
       numpy \
 && conda clean -tipsy \
 && rm -rf ${CONDA_DIR}/pkgs/*

# COLAB
RUN mkdir -p ${GCLOUD_DIR} \
 && curl -L $JUPYTERLAB_URL/google-cloud-sdk-202.0.0-linux-x86_64.tgz \
    | tar zx -C ${GCLOUD_DIR} --strip-components=1 \
 && pip install -U --no-cache-dir google-auth portpicker \
 && mkdir -p ${HOME}/content/datalab \
 && mkdir -p ${HOME}/.config/gcloud \
 && ln -s ${HOME}/.config/gcloud ${HOME}/content/datalab/.config \
 && ln -s ${HOME}/.config/gcloud ${HOME}/content/.config 

# Other
RUN conda install -y \
    notebook \
    icu \
    xarray \
    sympy \
    bokeh \
    statsmodels \
    h5py \
    seaborn \
    openpyxl \
    geopandas \
    rtree \
    pydrive \
    psycopg2 \
    pyarrow \
    sqlalchemy-redshift \
    ipython-sql \
    pytables \
    xlrd \
    numba \
    geopy \
    line_profiler \
    xtensor-python \
    graphviz \
    python-graphviz \
    pydot \
    networkx \
    \
    folium \
    ipywidgets \
    ipyleaflet  \
 && conda clean -tipsy \
 && rm -rf ${CONDA_DIR}/pkgs/*

RUN pip install -U --no-cache-dir \
    pymc \
    pythran \
    python-Levenshtein 

# Import matplotlib the first time to build the font cache.
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" 

# JupyterLab
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

# Other
RUN pip install -U --no-cache-dir \
    git+https://github.com/sudachen/colabtools \
    'requests-oauthlib==1.1.0' \
    google-api-python-client \
    oauth2client \
    pydrive \
 && pip install -U --no-cache-dir pystan \
 && pip install -U --no-cache-dir fbprophet

# Tensorboard/Tf/Torch/CV/DrawIO
RUN case "$CPGPU" in gpu) tfsfx=-gpu; tcdr=cu100;; *) tfsfx=; tcdr=cpu;; esac \
 && pip install -U --no-cache-dir \
    tb-nightly \
    future \
    tensorflow$tfsfx==1.13.1 \
    jupyter-tensorboard \
    https://download.pytorch.org/whl/$tcdr/torch-1.1.0-cp37-cp37m-linux_x86_64.whl \
    https://download.pytorch.org/whl/$tcdr/torchvision-0.3.0-cp37-cp37m-linux_x86_64.whl \
 && jupyter labextension install jupyterlab_tensorboard \
 && jupyter labextension install jupyterlab-drawio

# Init
USER root
COPY --chown=lab:users jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

USER lab
EXPOSE 8888
CMD [ "jupyter", "lab" ]
