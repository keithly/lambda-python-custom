FROM public.ecr.aws/amazonlinux/amazonlinux:2.0.20221103.3 as base
ENV LANG=en_US.UTF-8
ENV TZ=:/etc/localtime
ENV PATH=/var/lang/bin:/usr/local/bin:/usr/bin/:/bin:/opt/bin
ENV LD_LIBRARY_PATH=/var/lang/lib:/lib64:/usr/lib64:/var/runtime:/var/runtime/lib:/var/task:/var/task/lib:/opt/lib
ENV LAMBDA_TASK_ROOT=/var/task
ENV LAMBDA_RUNTIME_DIR=/var/runtime
RUN yum -y update

FROM base as builder
RUN yum -y install wget yum-utils && yum -y groupinstall "Development Tools"
RUN yum-builddep -y python3

ARG OPENSSL_VERSION=1.1.1s
RUN cd $(mktemp -d) && \
wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz && \
tar xf openssl-${OPENSSL_VERSION}.tar.gz && \
cd openssl-${OPENSSL_VERSION} && \
./config --prefix=/var/lang && \
make -j$(nproc) && \
make install

ARG PYTHON_VERSION=3.11.0
WORKDIR /opt
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz.asc
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz
RUN gpg --keyserver hkps://keys.openpgp.org --recv-keys 64E628F8D684696D
RUN gpg --verify Python-${PYTHON_VERSION}.tar.xz.asc Python-${PYTHON_VERSION}.tar.xz
RUN tar xf Python-${PYTHON_VERSION}.tar.xz
WORKDIR /opt/Python-${PYTHON_VERSION}
RUN ./configure --prefix=/var/lang --with-openssl=/var/lang --enable-optimizations --with-lto=full --with-system-ffi --with-computed-gotos --enable-loadable-sqlite-extensions
RUN make -j "$(nproc)"
RUN make install

FROM base
WORKDIR /var/task
COPY --from=builder /var/lang /var/lang

RUN ln -s /var/lang/bin/python3       /var/lang/bin/python && \
ln -s /var/lang/bin/pip3              /var/lang/bin/pip && \
ln -s /var/lang/bin/pydoc3            /var/lang/bin/pydoc && \
ln -s /var/lang/bin/python3-config    /var/lang/bin/python-config
RUN python3 -m pip install -U pip setuptools wheel
