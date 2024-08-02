ARG AL_PROVIDED_VERSION=al2023.2024.07.10.10
ARG ARCH=x86_64
FROM public.ecr.aws/lambda/provided:${AL_PROVIDED_VERSION}-${ARCH} as base
RUN dnf -y update && \
    dnf -y install shadow-utils && \
    dnf clean all

FROM base as builder
RUN dnf -y update && \
    dnf -y install gcc openssl-devel bzip2-devel libffi-devel xz-devel zlib-devel tar xz && \
    dnf clean all

ARG PYTHON_VERSION=3.12.4

RUN cd "$(mktemp -d)" && \
    curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz && \
    tar xf Python-${PYTHON_VERSION}.tar.xz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --prefix=/var/lang --enable-optimizations --with-lto=full --with-computed-gotos --enable-loadable-sqlite-extensions && \
    make -j "$(nproc)" && \
    make install


ARG ARCH=amd64
FROM base
COPY --from=builder /var/lang /var/lang
RUN ln -s /var/lang/bin/python3           /var/lang/bin/python && \
    ln -s /var/lang/bin/pip3              /var/lang/bin/pip && \
    ln -s /var/lang/bin/pydoc3            /var/lang/bin/pydoc && \
    ln -s /var/lang/bin/python3-config    /var/lang/bin/python-config

WORKDIR /var/task
COPY lambda /var/task

RUN ./install-rie.sh

RUN python3 -m pip install -U --no-cache-dir pip setuptools wheel && \
    python3 -m pip install --no-cache-dir --target /var/task awslambdaric boto3

COPY src src

RUN /usr/sbin/useradd lambdauser
USER lambdauser

ENV APP_VERSION=1.0.0

ENTRYPOINT ["/var/task/lambda-entrypoint.sh", "src/lambda-poc/lambda_function.handler"]
