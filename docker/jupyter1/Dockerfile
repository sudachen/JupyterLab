FROM ubuntu:18.04
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"
ENV FULLREBUILD 20190523
ENV DEBIAN_FRONTEND noninteractive

RUN sed -i /etc/apt/sources.list -e 's/stretch main/stretch main non-free/g' \ 
 && bash -c "for i in {1..9}; do mkdir -p /usr/share/man/man\$i; done" \
 && apt-get update --fix-missing \
 && apt-get install -qy --no-install-recommends \
       ca-certificates \
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
       mesa-opencl-icd ocl-icd-opencl-dev opencl-headers \
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

RUN mkdir ${HOME}/work \
 && curl -L https://repo.continuum.io/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -o ${HOME}/miniconda.sh \
 && ${SHELL} ${HOME}/miniconda.sh -f -b -p ${CONDA_DIR} \
 && rm ${HOME}/miniconda.sh \
 && conda config --system --append channels conda-forge \
 #&& conda config --system --prepend channels intel \
 && conda config --system --set show_channel_urls true \
 && echo "python ==3.6.6" >> ${CONDA_DIR}/conda-meta/pinned \
 && conda install 'python==3.6.6' \
 && conda update --all -y \
 && conda clean -tipsy \
 && rm -rf ${HOME}/.cache/yarn \
 && rm -rf ${CONDA_DIR}/pkgs/* \
 && echo ". ${CONDA_DIR}/etc/profile.d/conda.sh" >> ${HOME}/.bashrc 
 #&& echo "conda activate base" >> ${HOME}/.bashrc 

RUN pip install -U --no-cache-dir pip

RUN conda install -y \
       'numpy>=1.15.4' \
       'xarray<=0.10.7' \
       pandas \
       scipy \
       scikit-learn \
       sympy \
       matplotlib \
       notebook \
       bokeh \
       cython \
       statsmodels \
       'icu=58.2*' \
       hdf5 \
       libxml2 \
       h5py \
       ipywidgets \
       seaborn \
       ipyleaflet  \
       openpyxl \
       geopandas \
       folium \
       rtree \
       'cloudpickle=0.5*' \
       'dill=0.2*' \
       'vincent=0.4.*' \
       beautifulsoup4 \
       protobuf \    
       pydrive \
       psycopg2 \
       pymysql \
       pyarrow \
       jemalloc \
       sqlalchemy \
       sqlalchemy-redshift \
       ipython-sql \
 && conda clean -tipsy \
 && rm -rf ${CONDA_DIR}/pkgs/* 

RUN conda install -y \
        pytables \
        xlrd \
        nodejs \
        numba \
        pexpect \
        scrapy \
        geopy \
        line_profiler \
        xtensor-python \
        sklearn-contrib-lightning \
        graphviz \
        python-graphviz \
        pydot \
        'networkx=2.*' \
        geopy \ 
        pytz \
 && conda clean -tipsy \
 && rm -rf ${CONDA_DIR}/pkgs/*

RUN conda install -y \
        dask \
        psutil \
        requests \
        gunicorn \
        circus \
        urllib3 \
 && conda clean -tipsy \
 && rm -rf ${CONDA_DIR}/pkgs/*

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME ${HOME}/.cache/
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" 

# Other

USER $NB_USER    
RUN pip install -U --no-cache-dir pystan pymc
RUN pip install -U --no-cache-dir fbprophet

RUN pip install -U --no-cache-dir \
       'requests-oauthlib==1.1.0' \
        google-api-python-client \
        oauth2client \
        pydrive \
        hug \
        falcon \
        alembic \
        flask \
        flask-sqlalchemy \
        flask-migrate \
        flask-oauthlib \
        flask-script \
        flask-admin \
        git+https://github.com/sudachen/colabtools \
        git+https://github.com/sudachen/pygdrive-funcs.git#egg=gdrive \ 
        git+https://github.com/sudachen/ipython-sql 

RUN pip install -U --no-cache-dir \
        pyotp \
        singleton_decorator \
        pythran \
        pybind11 \
        python-Levenshtein \
        Wand \
        mmh3 

# OpenCL/CPU
USER root
RUN wget https://github.com/sudachen/dstoolbox/releases/download/1.23/intel-cpu-ocl.7z -q -O /tmp/intel-cpu-ocl.7z --no-check-certificate \
  && cd /tmp \
  && 7z x intel-cpu-ocl.7z \
  && cd intel-cpu-ocl \
  && ls -l \
  && dpkg -i *.deb \
  && cd .. \
  && rm -r intel-cpu-ocl* \
  && echo "/opt/intel/opencl-1.2-6.4.0.25/lib64/libintelocl.so" > /etc/OpenCL/vendors/intel-cpu.icd

# GPU/CV
USER $NB_USER
RUN pip install -U --no-cache-dir \
        pyopencl \
        pyclblas \
        torch \
        torchvision \
        opencv-python 

# Selenium
USER root
ENV MOZ_HEADLESS=1
RUN apt-get update \
  && apt-get install -qy --no-install-recommends \
       firefox \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* 
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.24.0/geckodriver-v0.24.0-linux64.tar.gz -q -O /tmp/geckodriver.tgz \
  && cd /tmp \
  && tar zxf geckodriver.tgz \
  && mv geckodriver /usr/bin/geckodriver \
  && chmod +x /usr/bin/geckodriver \
  && rm geckodriver*

USER $NB_USER
RUN pip install -U --no-cache-dir \
        selenium 

# Init
USER root
ADD tini-${TINI_VERSION} /usr/bin/tini
ADD jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py
RUN chmod +x /usr/bin/tini \
 && echo "jupyter ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook \
 && fix-permissions /etc/jupyter/

WORKDIR $HOME
ENTRYPOINT [ "/usr/bin/tini", "--" ]
ADD circus.ini /etc/
ADD nginx.conf /etc/nginx/
CMD ["circusd", "/etc/circus.ini"]

