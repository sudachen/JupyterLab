FROM ubuntu:18.04
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"
ENV BUILD 20190602
ENV XDG_CACHE_HOME ${HOME}/.cache/
ENV DEBIAN_FRONTEND noninteractive
ENV JUPYTERLAB_URL https://github.com/sudachen/JupyterLab/releases/download/release1
RUN sed -i /etc/apt/sources.list -e 's/stretch main/stretch main non-free/g' \ 
 && bash -c "for i in {1..9}; do mkdir -p /usr/share/man/man\$i; done" \
 && apt-get update --fix-missing \
 && apt-get install -qy --no-install-recommends \
    ca-certificates \
    software-properties-common \
    wget \
    git \	
    bash \
    sudo \
    unzip \
    bzip2 \
    tzdata \
    locales \
    libsm6 \
    libxt6 \
    libxrender1 \
    fonts-dejavu \
    fonts-liberation \
    procps \
    \
    build-essential \
    gfortran \
    gcc \
    g++ \
    \
    libpq5 \
    libpq-dev \
    hdf5-tools \
    libhdf5-dev \
    sqlite3 \
    libsqlite3-dev \
    imagemagick \
    libreadline-dev \
    spatialite-bin \
    libgtk2.0-0 \
    libfreetype6-dev \
    curl \
    \
    mysql-client \
    mysql-utilities \
    postgresql-client \
    gnupg2 \
    ssh \
    apt-transport-https \
    openvpn \
    net-tools \
    iputils-ping \
    dnsutils \
    nginx \
    joe \
    zbar-tools \
    curl \
    file \
    ocl-icd-opencl-dev opencl-headers \
    clinfo \
    libclblas-dev \
    time \
    libatlas-base-dev \
    tcl \
    tk \
    gfortran \
    libfreetype6-dev \
    pkg-config \
    libopenblas-dev \
    swig \
    p7zip-full \
    libzmq3-dev \
    libssl-dev \
    screen \
    firefox \
    xvfb \
    xserver-xephyr \
    vnc4server \
    scrot \
    libgmp3-dev \
    libfreerdp-dev \
 && add-apt-repository "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner" \
 && apt-get install -qy --no-install-recommends \
    adobe-flashplugin \
 # AMD APU processors \
 && apt-get install -qy --no-install-recommends \
    mesa-opencl-icd \ 
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8

ENV CONDA_VERSION=4.5.11 \
    TINI_VERSION=0.16.1 \
    CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=jupyter \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    PATH=/opt/conda/bin:$PATH \
    HOME=/home/jupyter \
    TZ=America/Santiago

ADD fix-permissions /usr/local/bin/fix-permissions
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
 && chmod a+x /usr/local/bin/fix-permissions \
 && useradd -m -s ${SHELL} -N -u ${NB_UID} ${NB_USER} \
 && mkdir -p ${CONDA_DIR} \
 && chown ${NB_USER}:${NB_GID} ${CONDA_DIR} \
 && chmod g+w /etc/passwd /etc/group \
 && fix-permissions ${HOME} \
 && fix-permissions ${CONDA_DIR}

USER $NB_USER
ENV PYTHON_VERSION=3.7.3
RUN mkdir ${HOME}/work \
 && curl -L $JUPYTERLAB_URL/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -o ${HOME}/miniconda.sh \
 && ${SHELL} ${HOME}/miniconda.sh -f -b -p ${CONDA_DIR} \
 && rm ${HOME}/miniconda.sh \
 && conda config --system --append channels conda-forge \
 && conda config --system --set show_channel_urls true \
 && echo "python ==$PYTHON_VERSION" >> ${CONDA_DIR}/conda-meta/pinned \
 && conda update --all -y \
 && conda clean -tipsy \
 && rm -rf ${CONDA_DIR}/pkgs/* \
 && pip install -U --no-cache-dir pip \
 && echo ". ${CONDA_DIR}/etc/profile.d/conda.sh" >> ${HOME}/.bashrc 
 
RUN conda install -y \
    nomkl \
    numpy \
    pandas \
    matplotlib \
    notebook \
    cython \
    jemalloc \
    sqlalchemy \
    pexpect \
    scrapy \
    pytz \
    psutil \
    requests \
    gunicorn \
    circus \
    urllib3 \
    hdf5 \
    pymysql \
    beautifulsoup4 \
    icu \
    libxml2 \
    nodejs \
    protobuf \    
    xarray \
    scipy \
    scikit-learn \
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
    dask \
 && conda clean -tipsy \
 && rm -rf ${CONDA_DIR}/pkgs/*

RUN pip install -U --no-cache-dir \
    pymongo \
    pyotp \
    singleton_decorator \
    mmh3 \
    fastecdsa \
    pynacl \
    pymc \
    pythran \
    python-Levenshtein \
    Wand \
    pybind11 \
    weasyprint \
    pyopencl \
    opencv-python 

# OpenCL/CPU
USER root
RUN wget $JUPYTERLAB_URL/intel-cpu-ocl.7z -q -O /tmp/intel-cpu-ocl.7z --no-check-certificate \
  && cd /tmp \
  && 7z x intel-cpu-ocl.7z \
  && cd intel-cpu-ocl \
  && ls -l \
  && dpkg -i *.deb \
  && cd .. \
  && rm -r intel-cpu-ocl* \
  && mkdir -p /etc/OpenCL/vendors/ \
  && echo "/opt/intel/opencl-1.2-6.4.0.25/lib64/libintelocl.so" > /etc/OpenCL/vendors/intel-cpu.icd

# Selenium
USER root
RUN wget $JUPYTERLAB_URL/geckodriver.7z -q -O /tmp/geckodriver.7z \
  && cd /tmp \
  && 7z x geckodriver.7z \
  && mv geckodriver /usr/bin/geckodriver \
  && chmod +x /usr/bin/geckodriver \
  && rm geckodriver*

USER $NB_USER
RUN pip install -U --no-cache-dir \
    selenium \
    pyvirtualdisplay \
    pyscreenshot 

# Init
USER root
ADD tini-${TINI_VERSION} /usr/bin/tini
ADD jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py
RUN chmod +x /usr/bin/tini \
 && echo "jupyter ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook \
 && fix-permissions /etc/jupyter/

USER $NB_USER    
WORKDIR $HOME

#ENTRYPOINT [ "/usr/bin/tini", "--" ]
#ADD circus.ini /etc/
#ADD nginx.conf /etc/nginx/
#CMD ["circusd", "/etc/circus.ini"]

