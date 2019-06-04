FROM sudachen/python3:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"

# Julia
USER root
ARG JULIA_VERSION=
ENV JULIA_BASE=${HOME}/.julia/${JULIA_VERSION} 
ENV JULIA_STARTUP=${JULIA_BASE}/etc/julia/startup.jl 
RUN ln -fs ${JULIA_BASE}/bin/julia /usr/local/bin/julia 
COPY julia-${JULIA_VERSION}-linux-x86_64.tar.gz /tmp

USER lab
RUN set -ex \
 && mkdir -p ${JULIA_BASE} \
 && tar xzf /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C ${JULIA_BASE} --strip-components=1 \
 && mkdir -p $(dirname JULIA_STARTUP) \
 && echo "using Libdl; push!(Libdl.DL_LOAD_PATH, \"${CONDA_DIR}/lib\")" >> ${JULIA_STARTUP} \
 && echo "ENV[\"PATH\"]=\"${CONDA_DIR}/bin:\$(ENV[\"PATH\"])\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"PYTHON\"]=\"${CONDA_DIR}/bin/python\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"CONDA_DEFAULT_ENV\"]=\"base\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"TZ\"]=\"\"" >> ${JULIA_STARTUP} 

RUN set -ex \
 && julia -e 'using Pkg; Pkg.update()' 

RUN set -ex \
 && julia -e 'using Pkg; Pkg.add("Plots")' \
 && julia -e 'using Pkg; Pkg.add("HDF5")' \
 && julia -e 'using Pkg; Pkg.add("MySQL")' \
 && julia -e 'using Pkg; Pkg.add("CSV")' \
 && julia -e 'using Pkg; Pkg.add("SQLite")' \
 && julia -e 'using Pkg; Pkg.add("LibPQ")' \
 && julia -e 'using Pkg; Pkg.add("Mongoc")' \
 && julia -e 'using Pkg; Pkg.add("JuliaDB")' \
 && julia -e 'using Pkg; Pkg.add("GitHub")' \
 && julia -e 'using Pkg; Pkg.add("MbedTLS")' \
 && julia -e 'using Pkg; Pkg.add("JSON")' \
 && julia -e 'using Pkg; Pkg.add("HTTP")' \
 && julia -e 'using Pkg; Pkg.add("WebSockets")' \
 && julia -e 'using Pkg; Pkg.add("Mux")' \
 && julia -e 'using Pkg; Pkg.add("JuliaWebAPI")' \
 && julia -e 'using Pkg; Pkg.add("BenchmarkTools")' 

RUN set -ex \
 && julia -e 'using Pkg; Pkg.add(PackageSpec(name="Gadfly",rev="master"))'  

RUN set -ex \
 && julia -e 'using Pkg; Pkg.add("OpenCL")' \
 && julia -e 'using Pkg; Pkg.add("Clang")' \
 && julia -e 'using Pkg; Pkg.add("LLVM")' 

RUN set -ex \
 && julia -e 'using Pkg; Pkg.add("PackageCompiler")' \    
 && julia -e 'using Pkg; Pkg.add("ImageSegmentation")' \    
 && julia -e 'using Pkg; Pkg.add(PackageSpec(name="Flux",rev="master"))' \
 && julia -e 'using Pkg; Pkg.add(PackageSpec(name="DiffEqFlux",rev="master"))' \ 
 && julia -e 'using Pkg; Pkg.add(PackageSpec(name="Metalhead",rev="master"))' \
 && julia -e 'using Pkg; Pkg.add(PackageSpec(name="MLDatasets",rev="master"))' \
 && julia -e 'using Pkg; Pkg.add("Nemo")' 

RUN set -ex \
 && julia -e 'using Pkg; Pkg.add("ECC")' \
 && julia -e 'using Pkg; Pkg.add("Bitcoin")'

RUN set -ex \
 && julia -e 'using Pkg; Pkg.add(PackageSpec(name="PyCall",rev="master"))' \
 && julia -e 'using Pkg; Pkg.add(PackageSpec(name="PyPlot",rev="master"))' \
 && julia -e 'using Pkg; Pkg.add(PackageSpec(name="Pandas",rev="master"))' \
 && julia -e 'using Pkg; Pkg.add(PackageSpec(name="IJulia",rev="master"))' \
 && julia -e 'using Pkg; Pkg.add(PackageSpec(name="ScikitLearn",rev="master"))'

RUN set -ex \
 && julia -e 'using Pkg; Pkg.gc()' \
 && rm ${HOME}/.julia/packages/*/*/deps/usr/downloads/* || true \
 && rm -r ${HOME}/.julia/compiled/* || true

RUN set -e \
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

RUN set -ex \
 && cd $HOME \
 && tar jcf julia-${JULIA_VERSION}-${CPGPU}-pkgs.tar.bz2 .julia


