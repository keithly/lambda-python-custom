ARG AMAZONLINUX_VERSION=2.0.20221103.3-amd64
FROM public.ecr.aws/amazonlinux/amazonlinux:${AMAZONLINUX_VERSION} as base
ENV LANG=en_US.UTF-8 \
    TZ=:/etc/localtime \
    PATH=/var/lang/bin:/usr/local/bin:/usr/bin/:/bin:/opt/bin \
    LD_LIBRARY_PATH=/var/lang/lib:/lib64:/usr/lib64:/var/runtime:/var/runtime/lib:/var/task:/var/task/lib:/opt/lib \
    LAMBDA_TASK_ROOT=/var/task \
    LAMBDA_RUNTIME_DIR=/var/runtime
RUN yum -y update && \
    yum clean all

FROM base as builder
RUN yum -y install wget yum-utils && \
    yum -y groupinstall "Development Tools" && \
    yum-builddep -y python3 && \
    yum clean all

ARG OPENSSL_VERSION=1.1.1s
RUN cd "$(mktemp -d)" && \
    wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.asc && \
    wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz && \
    gpg --keyserver hkps://keys.openpgp.org --recv-keys B8EF1A6BA9DA2D5C && \
    gpg --verify openssl-${OPENSSL_VERSION}.tar.gz.asc openssl-${OPENSSL_VERSION}.tar.gz && \
    tar xf openssl-${OPENSSL_VERSION}.tar.gz && \
    cd openssl-${OPENSSL_VERSION} && \
    ./config --prefix=/var/lang && \
    make -j "$(nproc)" && \
    make install

ARG PYTHON_VERSION=3.11.0
RUN cd "$(mktemp -d)" && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz.asc && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz && \
    gpg --keyserver hkps://keys.openpgp.org --recv-keys 64E628F8D684696D && \
    gpg --verify Python-${PYTHON_VERSION}.tar.xz.asc Python-${PYTHON_VERSION}.tar.xz && \
    tar xf Python-${PYTHON_VERSION}.tar.xz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --prefix=/var/lang --with-openssl=/var/lang --enable-optimizations --with-lto=full --with-system-ffi --with-computed-gotos --enable-loadable-sqlite-extensions && \
    make -j "$(nproc)" && \
    make install

FROM base
COPY --from=builder /var/lang /var/lang
RUN ln -s /var/lang/bin/python3       /var/lang/bin/python && \
    ln -s /var/lang/bin/pip3              /var/lang/bin/pip && \
    ln -s /var/lang/bin/pydoc3            /var/lang/bin/pydoc && \
    ln -s /var/lang/bin/python3-config    /var/lang/bin/python-config

RUN python3 -m pip install -U --no-cache-dir pip setuptools wheel && \
    python3 -m pip install --no-cache-dir --target /var/runtime awslambdaric boto3

COPY lambda-entrypoint.sh /
COPY runtime /var/runtime
WORKDIR /var/task
COPY src src

ENTRYPOINT [ "/lambda-entrypoint.sh", "src/lambda-poc/lambda_function.lambda_handler"]