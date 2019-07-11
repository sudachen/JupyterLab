FROM sudachen/python3:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"

ENV JULIA_VERSION=1.1.1 
ENV JULIA_BASE=${HOME}/.julia/${JULIA_VERSION} 
ENV JULIA_STARTUP=${JULIA_BASE}/etc/julia/startup.jl

#USER root
#ADD julia-${JULIA_VERSION}-cpu-pkgs.tar.bz2 ${HOME}
#RUN ln -fs ${JULIA_BASE}/bin/julia /usr/local/bin/julia 
USER lab

RUN set -ex \
 && curl -L ${JUPYTERLAB_URL}/julia-${JULIA_VERSION}-cpu-pkgs.tar.bz2 | tar jx -C ${HOME} \
 && sudo ln -fs ${JULIA_BASE}/bin/julia /usr/local/bin/julia \
 && julia -e 'using Pkg; Pkg.update()' \
 && julia -e 'using Pkg; Pkg.add(PackageSpec(url="https://github.com/sudachen/MXNet.jl.git"))' \
 && case $CPGPU in \
    gpu) \
       julia -e 'using Pkg; Pkg.add(PackageSpec(name="CUDAdrv",rev="master"))' \
    && julia -e 'using Pkg; Pkg.add(PackageSpec(name="CUDAnative",rev="master"))' \
    && julia -e 'using Pkg; Pkg.add(PackageSpec(name="CuArrays",rev="master"))' \
    ;; \
    esac \
 && julia -e 'using Pkg; Pkg.gc()' \
 && julia -e 'using IJulia; IJulia.installkernel("Julia", "--depwarn=no")' \
 && pip install -U --no-cache-dir git+https://github.com/JuliaPy/pyjulia#egg=julia \
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
 && rm -rf /tmp/*