FROM sudachen/python3:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"

# Julia
USER root
ARG JULIA_VERSION=
ENV JULIA_BASE=${HOME}/.julia/${JULIA_VERSION} 
ENV JULIA_STARTUP=${JULIA_BASE}/etc/julia/startup.jl 
ADD --chown=lab:users julia-${JULIA_VERSION}-bin.tar.bz2 ${HOME}/.julia
RUN ln -fs ${JULIA_BASE}/bin/julia /usr/local/bin/julia \
 && chown lab:users ${HOME}/.julia \
 && cd /usr/lib/x86_64-linux-gnu \
 && ln -s libopenblas.so libopenblas64_.so.0

USER lab
RUN set -ex \
 && mkdir -p $(dirname JULIA_STARTUP) \
 && echo "using Libdl; push!(Libdl.DL_LOAD_PATH, \"${CONDA_DIR}/lib\")" >> ${JULIA_STARTUP} \
 && echo "ENV[\"PATH\"]=\"${CONDA_DIR}/bin:\$(ENV[\"PATH\"])\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"PYTHON\"]=\"${CONDA_DIR}/bin/python\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"CONDA_DEFAULT_ENV\"]=\"base\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"TZ\"]=\"\"" >> ${JULIA_STARTUP} 

RUN set -ex \
 && julia -e 'using Pkg; Pkg.update()' \
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
 && julia -e 'using Pkg; Pkg.add("Gadfly")'  
RUN set -ex \
 && julia -e 'using Pkg; Pkg.add("OpenCL")' \
 && julia -e 'using Pkg; Pkg.add("Clang")' \
 && julia -e 'using Pkg; Pkg.add("LLVM")' \
 && julia -e 'using Pkg; Pkg.add("PackageCompiler")' \
 && julia -e 'using Pkg; Pkg.add("ImageSegmentation")' \
 && julia -e 'using Pkg; Pkg.add("Nemo")' \
 && julia -e 'using Pkg; Pkg.add("ECC")' \
 && julia -e 'using Pkg; Pkg.add("Bitcoin")'
RUN set -ex \
 && julia -e 'using Pkg; Pkg.add("PyCall")' \
 && julia -e 'using Pkg; Pkg.add("PyPlot")' \
 && julia -e 'using Pkg; Pkg.add("Pandas")' \
 && julia -e 'using Pkg; Pkg.add("IJulia")' \
 && julia -e 'using Pkg; Pkg.add("ScikitLearn")' 
RUN set -ex \
 && julia -e 'using Pkg; Pkg.add("Colors")' \
 && julia -e 'using Pkg; Pkg.add("ImageDraw")' \
 && julia -e 'using Pkg; Pkg.add("ImageInTerminal")' \
 && julia -e 'using Pkg; Pkg.add("ImageShow")' 
RUN set -ex \
 && julia -e 'using Pkg; Pkg.add(PackageSpec(name="Flux",rev="master"))' \
 && julia -e 'using Pkg; Pkg.add(PackageSpec(name="DiffEqFlux",rev="master"))' \ 
 && julia -e 'using Pkg; Pkg.add(PackageSpec(name="MLDatasets",rev="master"))' \
 && julia -e 'using Pkg; Pkg.add(PackageSpec(name="Metalhead",rev="master"))' 

RUN set -ex \
 && julia -e 'using Pkg; Pkg.gc()' \
 && rm ${HOME}/.julia/packages/*/*/deps/usr/downloads/* || true \
 && rm -r ${HOME}/.julia/compiled/* || true
RUN set -e \
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
 && julia -e 'using Pkg; Pkg.gc()'
RUN set -ex \
 && cd $HOME \
 && tar jcf julia-${JULIA_VERSION}-${CPGPU}-pkgs.tar.bz2 .julia
