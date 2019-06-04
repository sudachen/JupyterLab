FROM sudachen/python3:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"

# Julia
USER root
ENV JULIA_VERSION=1.1.1 
ENV JULIA_BASE=${HOME}/.julia/${JULIA_VERSION} 
ENV JULIA_STARTUP=${JULIA_BASE}/etc/julia/startup.jl
ENV CPGPU=cpu
RUN ln -fs ${JULIA_BASE}/bin/julia /usr/local/bin/julia 
ADD julia-${JULIA_VERSION}-cpu-pkgs.tar.bz2 ${HOME}

USER lab
RUN julia -e 'using IJulia; IJulia.installkernel("Julia", "--depwarn=no")'
RUN pip install -U --no-cache-dir git+https://github.com/JuliaPy/pyjulia#egg=julia

