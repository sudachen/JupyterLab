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
RUN curl -o /tmp/pypy.7z -L $JUPYTERLAB_URL/pypy-3.5.7z \
 &&  cd / && 7z x /tmp/pypy.7z \
 &&  rm /tmp/pypy.7z 
RUN pypy3 -m ipykernel install --user --name "PyPy6-3.5" --display-name "PyPy 6/3.5"
COPY logo-32x32.png logo-64x64.png $HOME/.local/share/jupyter/kernels/pypy6-3.5/

# Rust
USER $NB_UID
RUN curl https://sh.rustup.rs -sSf | bash -s - --default-toolchain stable -y
ENV PATH "$HOME/.cargo/bin:$PATH"
RUN cargo install evcxr_jupyter \
 && evcxr_jupyter --install 
RUN sed ~/.local/share/jupyter/kernels/rust/kernel.json -i -e "s/_name\": \"Rust\"/_name\": \"Rust `rustc --version | cut -f 2 -d ' '`\"/g"    

# Scala
USER root
RUN apt install -qy --no-install-recommends \
      ca-certificates-java \
      openjdk-8-jdk-headless \
      maven 
ENV ALMOND_VERSION=0.1.12 \
    SBT_VERSION=1.2.8 \
    SCALA_VERSION=2.12.7 \
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

# Spark
USER root
ENV SPARK_HOME=/opt/spark \
    PYTHONPATH="/opt/spark/python:$PYTHONPATH" \
    SPARK_XMX=2048M
ENV SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx$SPARK_XMX --driver-java-options=-Dlog4j.logLevel=info"
RUN mkdir ${SPARK_HOME} \
 && curl -L $JUPYTERLAB_URL/spark-2.4.3-bin-without-hadoop-scala-2.12.tgz -o /tmp/spark.tgz \
 && tar xzf /tmp/spark.tgz -C ${SPARK_HOME} --strip-components=1 \
 && rm /tmp/spark.tgz \
 && chown $NB_USER ${SPARK_HOME} \
 && fix-permissions ${SPARK_HOME}

USER $NB_USER  
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre 
RUN curl -L $JUPYTERLAB_URL/hadoop-2.8-jars.7z -o /tmp/hadoop-2.8-jars.7z \
 && cd /opt/spark \
 && 7z x -y /tmp/hadoop-2.8-jars.7z \
 && rm /tmp/hadoop-2.8-jars.7z
RUN pip install -U --no-cache-dir git+git://github.com/sudachen/spark-sklearn#egg=spark_sklearn\&subdirectory=python 

# Kotlin
USER $NB_USER
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false"
RUN curl -L -o /tmp/kotlin.7z $JUPYTERLAB_URL/kotlin-1.3.11.7z \
 && cd $HOME/.local/share/jupyter/kernels \
 && 7z x /tmp/kotlin.7z \
 && rm /tmp/kotlin.7z \
 && sed -e 's:"Kotlin":"Kotlin 1.3.11":g' -i ~/.local/share/jupyter/kernels/kotlin/kernel.json \
 && mkdir -p $ $HOME/jars \
 && sed -e 's;\${PATH};"/home/jupyter/.local/share/jupyter/kernels/kotlin/lib/*:/home/jupyter/jars/*:/home/jupyter/.local/share/jars/*", "-Xmx2048m", "-Xms256m";g' -i ~/.local/share/jupyter/kernels/kotlin/kernel.json

RUN pip install -U --no-cache-dir keras

# Keras/Theano
#USER $NB_USER
#RUN conda install -y keras Theano \
# && conda clean -tipsy \
# && rm -rf ${CONDA_DIR}/pkgs/*

# Java
#USER $NB_USER
#RUN curl -L -o /tmp/java.7z $JUPYTERLAB_URL/java.7z \
# && cd $HOME/.local/share/jupyter/kernels \
# && 7z x /tmp/java.7z \
# && rm /tmp/java.7z \
# && sed -e 's:"Java":"Java 8":g' -i ~/.local/share/jupyter/kernels/java/kernel.json \
# && mkdir -p $ $HOME/jars \
# && sed -e 's;\${PATH};"/home/jupyter/.local/share/jupyter/kernels/java/lib/*:/home/jupyter/jars/*:/home/jupyter/.local/share/jars/*", "-Xmx2048m", "-Xms256m";g' -i ~/.local/share/jupyter/kernels/java/kernel.json

# Go
#USER root
#ENV GOLANG_VERSION 1.9.7
#ENV GOPATH $HOME/go
#ENV LGOPATH $HOME/lgo
#ENV PATH $GOPATH/bin:/opt/go/bin:$PATH
#RUN curl -L https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz| tar -zx -C /opt

#USER $NB_USER
#RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" "$LGOPATH/src" "$LGOPATH/bin" \
# && chmod -R 777 "$GOPATH" \
# && chmod -R 777 "$LGOPATH" \
# && go get github.com/yunabe/lgo/cmd/lgo \
# && go get -d github.com/yunabe/lgo/cmd/lgo-internal \
# && lgo install \
# && python $GOPATH/src/github.com/yunabe/lgo/bin/install_kernel
#RUN jupyter labextension install @yunabe/lgo_extension \
# && jupyter lab clean
#RUN go get -u github.com/nfnt/resize gonum.org/v1/gonum/... gonum.org/v1/plot/...  github.com/wcharczuk/go-chart \
# && lgo installpkg github.com/nfnt/resize gonum.org/v1/gonum/... gonum.org/v1/plot/... github.com/wcharczuk/go-chart 

# C++
#USER $NB_USER
#RUN conda create -n cling \
# && conda install xeus-cling -c conda-forge -n cling 
#RUN cp -r $CONDA_DIR/envs/cling/share/jupyter/kernels/xcpp17 $HOME/.local/share/jupyter/kernels

