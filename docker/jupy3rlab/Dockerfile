FROM sudachen/jupyterlab:latest
LABEL maintainer="Alexey Sudachen <alexey@sudachen.name>"

# PyPy

USER root
RUN mkdir /opt/pypy \
 && ln -s /opt/pypy/bin/pypy3 /usr/local/bin \
 && ln -s /opt/pypy/bin/pip /usr/local/bin/pipy3 \
 && chown -R $NB_USER /opt/pypy \
 && fix-permissions /opt/pypy/

USER $NB_USER
ENV PYPY_GC_MAX: 1.99GB
ENV PYPY_GC_MAJOR_COLLECT: 1.2
RUN curl -o /tmp/pypy.7z -L https://github.com/sudachen/dstoolbox/releases/download/1.23/pypy-3.5.7z \
 &&  cd / && 7z x /tmp/pypy.7z \
 &&  rm /tmp/pypy.7z 
RUN pypy3 -m ipykernel install --user --name "PyPy6-3.5" --display-name "PyPy 6/3.5"
COPY logo-32x32.png logo-64x64.png $HOME/.local/share/jupyter/kernels/pypy6-3.5/

# Julia
USER root
ENV JULIA_BASE=/opt/julia \
    JULIA_STARTUP=/opt/julia/etc/julia/startup.jl \
    JULIA_VERSION=1.0.3 
RUN mkdir ${JULIA_BASE} \
 && ln -fs ${JULIA_BASE}/bin/julia /usr/local/bin/julia \ 
 && chown $NB_USER ${JULIA_BASE} \
 && fix-permissions ${JULIA_BASE}

USER $NB_UID
RUN cd /tmp \
 && wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz \
 && tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C ${JULIA_BASE} --strip-components=1 \
 && rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz \
 && echo "using Libdl; push!(Libdl.DL_LOAD_PATH, \"${CONDA_DIR}/lib\")" >> ${JULIA_STARTUP} \
 && echo "ENV[\"PATH\"]=\"${CONDA_DIR}/bin:\$(ENV[\"PATH\"])\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"PYTHON\"]=\"${CONDA_DIR}/bin/python3\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"CONDA_DEFAULT_ENV\"]=\"base\"" >> ${JULIA_STARTUP} \
 && echo "ENV[\"TZ\"]=\"\"" >> ${JULIA_STARTUP} 
RUN curl -L -o /tmp/julia.7z https://github.com/sudachen/dstoolbox/releases/download/1.23/julia-101-pkgs.7z \
 && cd $HOME && 7z x /tmp/julia.7z \
 && rm /tmp/julia.7z \
 && julia -e 'using Pkg; Pkg.update(); Pkg.gc()' \
 && julia -e 'using Pkg; Pkg.add("JuliaDB")' \
 && screen -S julia -d -m -s julia \
 && screen -S julia -p 0 -X stuff '^M]^Mprecompile^M^M^M' \
 && sp='/-\|' \
 && printf 'Precompiling Julia Packages...  ' \
 && sleep 1 \
 && while [ "`screen -S julia -p 0 -X hardcopy /tmp/screen && tac /tmp/screen | grep '.' -a -m 1`" != "(v1.0) pkg>" ]; do \
       printf '\b%.1s' "$sp"; \
       sp=${sp#?}${sp%???}; \
       sleep 0.5; \
    done \
 && echo done \
 && julia -e 'using Pkg; Pkg.gc()'
RUN julia -e 'using IJulia; IJulia.installkernel("Julia", "--depwarn=no")'

# Rust

USER $NB_UID
RUN curl https://sh.rustup.rs -sSf | bash -s - --default-toolchain stable -y
ENV PATH "$HOME/.cargo/bin:$PATH"
RUN cargo install evcxr_jupyter \
 && evcxr_jupyter --install 
RUN sed ~/.local/share/jupyter/kernels/rust/kernel.json -i -e "s/_name\": \"Rust\"/_name\": \"Rust `rustc --version | cut -f 2 -d ' '`\"/g"    

# Scala

USER root
RUN apt install -y \
      ca-certificates-java \
      openjdk-8-jdk-headless \
      maven 
ENV ALMOND_VERSION=0.5.0 \
    SBT_VERSION=1.2.8 \
    SCALA_VERSION=2.12.8 \
    PATH=$PATH:/opt/sbt/bin
RUN mkdir /opt/sbt \
 && curl -sL --retry 5 "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar zx -C /opt/sbt --strip-components=1 \
 && chmod +x /opt/sbt/bin/sbt \
 && curl -L -o /usr/bin/coursier https://git.io/coursier \
 && chmod +x /usr/bin/coursier 

USER $NB_USER
RUN coursier bootstrap \
      -i user \
      -I user:sh.almond:scala-kernel-api_$SCALA_VERSION:$ALMOND_VERSION \
      sh.almond:scala-kernel_$SCALA_VERSION:$ALMOND_VERSION \
      -o almond_2_12 \
 && chmod +x almond_2_12 \
 && ./almond_2_12 --id almond_scala_2_12 --display-name "Scala $SCALA_VERSION" --install \
 && rm ./almond_2_12

# Kotlin
USER $NB_USER
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false"
RUN curl -L -o /tmp/kotlin.7z https://github.com/sudachen/dstoolbox/releases/download/1.23/kotlin-1.3.11.7z \
 && cd $HOME/.local/share/jupyter/kernels \
 && 7z x /tmp/kotlin.7z \
 && rm /tmp/kotlin.7z \
 && sed -e 's:"Kotlin":"Kotlin 1.3.11":g' -i ~/.local/share/jupyter/kernels/kotlin/kernel.json \
 && mkdir -p $ $HOME/jars
RUN sed -e 's;\${PATH};"/home/jupyter/.local/share/jupyter/kernels/kotlin/lib/*:/home/jupyter/jars/*:/home/jupyter/.local/share/jars/*", "-Xmx2048m", "-Xms256m";g' -i ~/.local/share/jupyter/kernels/kotlin/kernel.json

#Java
USER $NB_USER
RUN curl -L -o /tmp/java.7z https://github.com/sudachen/dstoolbox/releases/download/1.23/java.7z \
 && cd $HOME/.local/share/jupyter/kernels \
 && 7z x /tmp/java.7z \
 && rm /tmp/java.7z \
 && sed -e 's:"Java":"Java 8":g' -i ~/.local/share/jupyter/kernels/java/kernel.json \
 && mkdir -p $ $HOME/jars
RUN sed -e 's;\${PATH};"/home/jupyter/.local/share/jupyter/kernels/java/lib/*:/home/jupyter/jars/*:/home/jupyter/.local/share/jars/*", "-Xmx2048m", "-Xms256m";g' -i ~/.local/share/jupyter/kernels/java/kernel.json

# Keras/Theano/Tensorflow
USER $NB_USER
RUN conda install -y tensorflow-gpu keras Theano \
 && conda clean -tipsy \
 && rm -rf ${CONDA_DIR}/pkgs/*
