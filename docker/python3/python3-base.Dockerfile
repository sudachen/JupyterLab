FROM ubuntu:18.04
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"
ENV BUILD 20190609
ENV USER=lab
ENV UID=1000
ENV GID=100
ENV HOME=/${USER}
ENV XDG_CACHE_HOME ${HOME}/.cache/
ENV CPGPU=cpu
ENV DEBIAN_FRONTEND noninteractive
ENV JUPYTERLAB_URL https://github.com/sudachen/JupyterLab/releases/download/release1
ENV TINI_VERSION v0.18.0
ENV CONDA_VERSION=4.5.11 
ENV CONDA_DIR=${HOME}/.conda
ENV SHELL=/bin/bash 
ENV PATH=${CONDA_DIR}/bin:$PATH 
ENV TZ=America/Santiago

USER root

RUN bash -c "for i in {1..9}; do mkdir -p /usr/share/man/man\$i; done" \
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
    liblapack-dev \
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
#    libfreerdp-dev \
    libltdl-dev \
    libopencv-dev \
    ninja-build \
    libjemalloc-dev \
    libomp-dev \
    libssh2-1-dev \
    libgmp-dev \
    libdsfmt-dev \
    libatomic1 \
    libmbedtls-dev \
    libgit2-dev \
    libcurl4-gnutls-dev \
    libmpfr-dev \
    libpcre2-dev \  
    libssl-dev \
    libopenlibm-dev \
    \
    m4 \
 && add-apt-repository "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner" \
 && apt-get install -qy --no-install-recommends \
    adobe-flashplugin \
 ## AMD APU processors \
 # && apt-get install -qy --no-install-recommends \
 #   mesa-opencl-icd \ 
 # && apt-get purge cmake \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8 \
 && curl -L $JUPYTERLAB_URL/geckodriver.7z -o /tmp/geckodriver.7z \
 && cd /tmp \
 && 7z x geckodriver.7z \
 && mv geckodriver /usr/bin/geckodriver \
 && chmod +x /usr/bin/geckodriver \
 && rm geckodriver*

ENV LANG=en_US.UTF-8 
ENV LANGUAGE=en_US.UTF-8 
ENV LC_ALL=en_US.UTF-8 

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

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
 && useradd -m -s ${SHELL} -N -u ${UID} lab -d ${HOME} \
 && mkdir -p ${CONDA_DIR} \
 && chmod g+w /etc/passwd /etc/group \
 && chown lab:users -R ${HOME} \
 && echo "lab ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/lab \
 && mkdir -p /etc/jupyter \
 && chown lab:users -R /etc/jupyter 

RUN set -ex \
 && cd /tmp \
 && curl -L https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5-Linux-x86_64.sh -o cmake-3.14.5.sh \
 && bash cmake-3.14.5.sh --skip-license --prefix=/usr \
 && rm -rf cmake* 

USER lab
ENV PYTHON_VERSION=3.7.3
RUN mkdir ${HOME}/work \
 && curl -L $JUPYTERLAB_URL/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -o /tmp/miniconda.sh \
 && ${SHELL} /tmp/miniconda.sh -f -b -p ${CONDA_DIR} \
 && rm /tmp/miniconda.sh \
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
    scipy \
    matplotlib \
    ipython \
    cython \
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
    h5py \
    pyarrow \
    pytables \
    pymysql \
    beautifulsoup4 \
    icu \
    libxml2 \
    nodejs \
    protobuf \
    dask \
    rsa \
    gmpy2 \
    mpfr \
 && conda remove -y --force qt \
 && conda clean -tipsy \
 && rm -rf ${CONDA_DIR}/pkgs/*

RUN pip install -U --no-cache-dir \
    pymc \
    scikit-learn \
    psycopg2-binary \
    pymongo \
    pyotp \
    singleton_decorator \
    mmh3 \
    fastecdsa \
    Wand \
    pybind11 \
    weasyprint \
    pyopencl \
    opencv-python-headless \
    opencv-contrib-python-headless \
    selenium \
    pyvirtualdisplay \
    pyscreenshot \
    rdpy 

USER root
COPY tini-${TINI_VERSION} /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

USER lab
WORKDIR $HOME

