FROM sudachen/jupyter1-gpu:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"

# Julia
USER root
ENV JULIA_BASE=/opt/julia \
    JULIA_STARTUP=/opt/julia/etc/julia/startup.jl 
ARG JULIA_VERSION=
RUN mkdir ${JULIA_BASE} \
 && ln -fs ${JULIA_BASE}/bin/julia /usr/local/bin/julia \ 
 && chown $NB_USER ${JULIA_BASE} \
 && fix-permissions ${JULIA_BASE}

USER $NB_UID
RUN cd /tmp \
 && curl -L https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz | \
    tar xz -C ${JULIA_BASE} --strip-components=1 \
 && echo "using Libdl; push!(Libdl.DL_LOAD_PATH, \"${CONDA_DIR}/lib\")" >> ${JULIA_STARTUP} \
 && echo "ENV[\"PATH\"]=\"${CONDA_DIR}/bin:\$(ENV[\"PATH\"])\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"PYTHON\"]=\"${CONDA_DIR}/bin/python3\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"CONDA_DEFAULT_ENV\"]=\"base\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"TZ\"]=\"\"" >> ${JULIA_STARTUP} 

RUN set -ex \
    && julia -e 'using Pkg; Pkg.update()' \
    && julia -e 'using Pkg; Pkg.add("Plots")' \
    && julia -e 'using Pkg; Pkg.add("HDF5")' \
    && julia -e 'using Pkg; Pkg.add("MySQL")' \
    && julia -e 'using Pkg; Pkg.add("CSV")' \
    && julia -e 'using Pkg; Pkg.add("SQLite")' \
    && julia -e 'using Pkg; Pkg.add(PackageSpec(name="Gadfly",rev="master"))'  \
    && julia -e 'using Pkg; Pkg.add(PackageSpec(name="PyCall",rev="master"))' \
    && julia -e 'using Pkg; Pkg.add(PackageSpec(name="PyPlot",rev="master"))' \
    && julia -e 'using Pkg; Pkg.add(PackageSpec(name="Pandas",rev="master"))' \
    && julia -e 'using Pkg; Pkg.add(PackageSpec(name="ScikitLearn",rev="master"))' \
    && julia -e 'using Pkg; Pkg.add(PackageSpec(name="LibPQ",rev="master"))' \
    && julia -e 'using Pkg; Pkg.add(PackageSpec(name="IJulia",rev="master"))' \
    && julia -e 'using Pkg; Pkg.add("JuliaDB")' \
    && julia -e 'using Pkg; Pkg.add("OpenCL")' \
    && julia -e 'using Pkg; Pkg.add("Clang")' \
    && julia -e 'using Pkg; Pkg.gc()' 

RUN set -ex \
    && julia -e 'using Pkg; Pkg.add("PackageCompiler")' \    
    && julia -e 'using Pkg; Pkg.gc()' 

RUN set -ex \
   && rm /home/jupyter/.julia/packages/*/*/deps/usr/downloads/* || true \
   && rm -r /home/jupyter/.julia/compiled/* || true

RUN set -ex \
   && cd $HOME \
   && 7z a -mx9 julia-${JULIA_VERSION}-cpu-pkgs.7z .julia

RUN set -ex \
    && julia -e 'using Pkg; Pkg.update()' \
    && julia -e 'using Pkg; Pkg.add("CUDAdrv")' \
    && julia -e 'using Pkg; Pkg.add("CUDAnative")' \
    && julia -e 'using Pkg; Pkg.add("CuArrays")' \
    && julia -e 'using Pkg; Pkg.gc()' 

RUN set -ex \
   && rm /home/jupyter/.julia/packages/*/*/deps/usr/downloads/* || true \
   && rm -r /home/jupyter/.julia/compiled/* || true

RUN set -ex \
   && cd $HOME \
   && 7z a -mx9 julia-${JULIA_VERSION}-gpu-pkgs.7z .julia
