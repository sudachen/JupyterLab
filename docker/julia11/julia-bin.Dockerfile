FROM sudachen/python3:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"

# Julia
USER root
ARG JULIA_VERSION=1.1.1
ENV JULIA_BASE=${HOME}/.julia/${JULIA_VERSION} 
ENV JULIA_STARTUP=${JULIA_BASE}/etc/julia/startup.jl 
RUN ln -fs ${JULIA_BASE}/bin/julia /usr/local/bin/julia 
#ADD --chown=lab:users julia-${JULIA_VERSION}-full.tar.gz /lab/

USER lab

ENV HTTP_PROXY=${http_proxy}
ENV HTTPS_PROXY=${httpS_proxy}

RUN set -ex \
&& echo "[http]" >> ~/.gitconfig \
&& echo "proxy = ${http_proxy}" >> ~/.gitconfig \
&& echo "[https]" >> ~/.gitconfig \
&& echo "proxy = ${https_proxy}" >> ~/.gitconfig \
&& cat ~/.gitconfig

RUN set -ex \
 && git clone --branch v${JULIA_VERSION} https://github.com/JuliaLang/julia.git julia-${JULIA_VERSION} 

ADD --chown=lab:users Make.user /lab/julia-${JULIA_VERSION}/ 

RUN set -ex \
 && cd julia-${JULIA_VERSION} \
 && echo "prefix=/lab/.julia/${JULIA_VERSION}" >>  Make.user 

RUN set -ex \
 && cd julia-${JULIA_VERSION} \
 && echo "LIBGIT2_BRANCH=v0.27.7" > deps/libgit2.version \
 && echo "LIBGIT2_SHA1=f23dc5b29f1394928a940d7ec447f4bfd53dad1f" >> deps/libgit2.version \
 && echo CURL_VER = 7.61.0 >> deps/Versions.make \
 && echo CURL_BB_REL = 1 >> deps/Versions.make \
 && echo LIBGIT2_VER = 0.27.7 >> deps/Versions.make \
 && echo LIBGIT2_BB_REL = 1 >> deps/Versions.make 

RUN set -ex \
 && cd julia-${JULIA_VERSION} \
 && make -C deps getall

RUN set -ex \
 && cd julia-${JULIA_VERSION} \
 && make -C deps -j 5 install-llvm

RUN set -ex \
 && cd julia-${JULIA_VERSION} \
 && make -j 5

#RUN set -ex \
# && cd julia-${JULIA_VERSION} \
# && make testall

RUN set -ex \
 && mkdir -p .julia \
 && cd julia-${JULIA_VERSION} \
 && make install 

RUN set -ex \
 && cd .julia \
 && tar jcf /lab/julia-${JULIA_VERSION}-bin.tar.bz2 ${JULIA_VERSION}
