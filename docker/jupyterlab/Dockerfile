FROM sudachen/julia11:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"
ENV GCLOUD_DIR ${HOME}/.google_cloud
ENV CLOUDSDK_ROOT_DIR=$GCLOUD_DIR \
    CLOUDSDK_PYTHON=$CONDA_DIR/envs/python27/bin/python2 \
    PATH=$PATH:$GCLOUD_DIR/bin \
    DATALAB_ROOT=$HOME 

USER lab

RUN set -ex \
 && sudo apt-get update \
 && sudo apt-get clean  \
 && conda create -n python27 python=2.7 \
 && conda install -n python27 -c conda-forge \
    nomkl \
    numpy \
 && conda clean -tipsy \
 && rm -rf ${CONDA_DIR}/pkgs/* \
 && mkdir -p ${GCLOUD_DIR} \
 && curl -L $JUPYTERLAB_URL/google-cloud-sdk-202.0.0-linux-x86_64.tgz \
    | tar zx -C ${GCLOUD_DIR} --strip-components=1 \
 && pip install -U --no-cache-dir google-auth portpicker \
 && mkdir -p ${HOME}/content/datalab \
 && mkdir -p ${HOME}/.config/gcloud \
 && ln -s ${HOME}/.config/gcloud ${HOME}/content/datalab/.config \
 && ln -s ${HOME}/.config/gcloud ${HOME}/content/.config \
 && cd /tmp \
 && git clone https://github.com/rkern/line_profiler.git \
 && find line_profiler -name '*.pyx' -exec cython {} \; \
 && cd line_profiler \
 && python setup.py install \
 && cd \
 && pip install -U --no-cache-dir \
    notebook \
    ipywidgets \
    \
    future \
    memory_profiler \
    \
    xarray \
    sympy \
    bokeh \
    statsmodels \
    seaborn \
    openpyxl \
    geopandas \
    rtree \
    pydrive \
    sqlalchemy-redshift \
    ipython-sql \
    xlrd \
    geopy \
    graphviz \
    pydot \
    networkx \
    \
    folium \
    ipyleaflet \
    \
    pythran \
    python-Levenshtein \
    \
    git+https://github.com/sudachen/colabtools \
    'requests-oauthlib==1.1.0' \
    google-api-python-client \
    oauth2client \
    pydrive \
 #&& pip install -U --no-cache-dir pystan \
 #&& pip install -U --no-cache-dir fbprophet \
 && pip install -U --no-cache-dir plotly \
 && pip install -U --no-cache-dir pyct \
 && rm -rf holoviews \
 && cd /tmp \
 && git clone --branch v0.7.0 git://github.com/pyviz/datashader.git \
 && cd datashader \
 && python setup.py install \
 && cd .. \
 && rm -rf datashader \
 && cd /tmp \
 && git clone --branch v0.6.0 git://github.com/pyviz/panel.git \
 && cd panel \
 && python setup.py install \
 && cd .. \
 && cd /tmp \
 && git clone --branch v1.12.3 git://github.com/pyviz/holoviews.git \
 && cd holoviews \
 && python setup.py install \
 && cd .. \
 && rm -rf /tmp/* \
 && echo "sed -e 's:${CONDA_DIR}/bin/python:${CONDA_DIR}/bin/python-jl:g' \
              -i  ${CONDA_DIR}/share/jupyter/kernels/python3/kernel.json" \
      | bash \
 && pip install -U --no-cache-dir \
     'jupyterlab>=0.35,<1.0' \
     tensorboard \
     jupyter-tensorboard \
 && jupyter nbextension enable --py widgetsnbextension --sys-prefix \
 && jupyter labextension install \
     @jupyter-widgets/jupyterlab-manager@^0.38 \
 && pip install -U --no-cache-dir \
     dash==0.21.1 \
     dash-renderer==0.13.0 \
     dash-html-components==0.11.0 \
     dash-core-components==0.23.0 \
     jupyterlab-dash==0.1.0a2 \
     sidecar \
     jupyterlab_github \
     git+https://github.com/googlecolab/jupyter_http_over_ws#egg=jupyter_http_over_ws \
     jupyterlab-git \
     jupyterlab_code_formatter \
 && jupyter labextension install \
     @jupyterlab/github \
     @jupyterlab/mp4-extension \
     @jupyterlab/google-drive \
     @jupyterlab/git \
     @jupyter-widgets/jupyterlab-sidecar \
     dask-labextension \
     jupyterlab_bokeh \
     jupyterlab_tensorboard \
     jupyterlab-drawio \
     jupyterlab-dash@0.1.0-alpha.2 \
     @ryantam626/jupyterlab_code_formatter \
     @krassowski/jupyterlab_go_to_definition \
     @pyviz/jupyterlab_pyviz \
 && jupyter serverextension enable --py \
     jupyterlab_github \
     jupyter_http_over_ws \
     jupyterlab_git \
     jupyterlab_code_formatter \
 && if [ ! -z "${JULIA_VERSION}"]; then \     
        julia -e 'using Pkg; Pkg.add(PackageSpec(name="WebIO",rev="master"))' \
        && julia -e 'using Pkg; Pkg.add(PackageSpec(name="Interact",rev="master"))' \
        && julia -e 'using Pkg; Pkg.add(PackageSpec(name="InteractBulma",rev="master"))' \
        && julia -e 'using Pkg; Pkg.add(PackageSpec(name="Vue",rev="master"))' \
        && julia -e 'using Pkg; Pkg.add(PackageSpec(name="JSExpr",rev="master"))' \
        && set +x \
        && screen -S julia1_img -d -m -s julia \
        && screen -S julia1_img -p 0 -X stuff '^M]^Mprecompile^M^M^M' \
        && sp='/-\|' \
        && pkgver=${JULIA_VERSION%.*} \
        && printf 'Precompiling Julia Packages...                       ' \
        && sleep 1 \
        && while [ "`screen -S julia1_img -p 0 -X hardcopy /tmp/screen && tac /tmp/screen | grep '.' -a -m 1`" != "(v$pkgver) pkg>" ]; do \
            printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%.1s %-20s" "$sp" "$(tac /tmp/screen | grep '.' -a -m 1 | awk '{ print substr($(NF-1),1,20) }')" ; \
            sp=${sp#?}${sp%???}; \
            sleep 1; \
        done \
        && cat /tmp/screen \
        && set -x \
        && julia -e 'using Pkg; Pkg.gc()' \
        && julia -e 'using WebIO; using Interact; using IJulia' \
    ;fi \
 && jupyter lab build  \
 && rm -rf /lab/.conda/share/jupyter/lab/staging/* \
 && rm -rf /tmp/* \
 && mkdir -p ${HOME}/.jupyter/lab/workspaces

COPY --chown=lab:users jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py
EXPOSE 8888
CMD [ "jupyter", "lab" ]
