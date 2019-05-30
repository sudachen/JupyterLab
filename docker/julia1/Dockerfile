FROM sudachen/jupyter1:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"

# Julia
USER root
ENV JULIA_BASE=/opt/julia \
    JULIA_STARTUP=/opt/julia/etc/julia/startup.jl \
    JULIA_VERSION=1.1.1 
RUN mkdir ${JULIA_BASE} \
 && ln -fs ${JULIA_BASE}/bin/julia /usr/local/bin/julia \ 
 && chown $NB_USER ${JULIA_BASE} \
 && fix-permissions ${JULIA_BASE}

USER $NB_UID
RUN cd /tmp \
 && curl -L https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz | \
    tar xz -C ${JULIA_BASE} --strip-components=1 

RUN echo "using Libdl; push!(Libdl.DL_LOAD_PATH, \"${CONDA_DIR}/lib\")" >> ${JULIA_STARTUP} \
 && echo "ENV[\"PATH\"]=\"${CONDA_DIR}/bin:\$(ENV[\"PATH\"])\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"PYTHON\"]=\"${CONDA_DIR}/bin/python\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"CONDA_DEFAULT_ENV\"]=\"base\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"TZ\"]=\"\"" >> ${JULIA_STARTUP} 

RUN set -e \
 && curl -L -o /tmp/julia.7z $JUPYTERLAB_URL/julia-${JULIA_VERSION}-${CPGPU}-pkgs.7z \
 && cd $HOME && 7z x /tmp/julia.7z \
 && rm /tmp/julia.7z \
 && julia -e 'using Pkg; Pkg.update(); Pkg.gc()' \
 && screen -S julia1_img -d -m -s julia \
 && screen -S julia1_img -p 0 -X stuff '^M]^Mprecompile^M^M^M' \
 && sp='/-\|' \
 && pkgver=${JULIA_VERSION%.*} \
 && printf 'Precompiling Julia Packages...  ' \
 && sleep 1 \
 && while [ "`screen -S julia1_img -p 0 -X hardcopy /tmp/screen && tac /tmp/screen | grep '.' -a -m 1`" != "(v$pkgver) pkg>" ]; do \
       printf '\b%.1s' "$sp"; \
       sp=${sp#?}${sp%???}; \
       sleep 1; \
    done \
 && cat /tmp/screen \
 && julia -e 'using Pkg; Pkg.gc()'

RUN julia -e 'using IJulia; IJulia.installkernel("Julia", "--depwarn=no")'
RUN pip install -U --no-cache-dir git+https://github.com/JuliaPy/pyjulia#egg=julia

