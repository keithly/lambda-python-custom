ARG AL_PROVIDED_VERSION=al2023.2023.12.01.08
ARG ARCH=x86_64
FROM public.ecr.aws/lambda/provided:${AL_PROVIDED_VERSION}-${ARCH} as base
RUN dnf -y update && \
    dnf clean all

FROM base as builder
RUN dnf -y update && \
    dnf -y install gcc openssl-devel bzip2-devel libffi-devel xz-devel && \
    dnf clean all

RUN curl -Lo /usr/local/bin/cosign https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64 && \
    chmod +x /usr/local/bin/cosign

ARG PYTHON_VERSION=3.12.0
#ARG PYTHON_KEY=64E628F8D684696D

RUN cd "$(mktemp -d)" && \
    curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz.sigstore && \
    curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz && \
    cosign verify-blob Python-${PYTHON_VERSION}.tar.xz  \
        --bundle Python-${PYTHON_VERSION}.tar.xz.sigstore \
        --certificate-identity=thomas@python.org \
        --certificate-oidc-issuer=https://accounts.google.com && \
#    gpg --keyserver hkps://keys.openpgp.org --recv-keys ${PYTHON_KEY} && \
#    gpg --verify Python-${PYTHON_VERSION}.tar.xz.asc Python-${PYTHON_VERSION}.tar.xz && \
    tar xf Python-${PYTHON_VERSION}.tar.xz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --prefix=/var/lang --enable-optimizations --with-lto=full --with-system-ffi --with-computed-gotos --enable-loadable-sqlite-extensions && \
    make -j "$(nproc)" && \
    make install


ARG ARCH=amd64
FROM base
COPY --from=builder /var/lang /var/lang
RUN ln -s /var/lang/bin/python3           /var/lang/bin/python && \
    ln -s /var/lang/bin/pip3              /var/lang/bin/pip && \
    ln -s /var/lang/bin/pydoc3            /var/lang/bin/pydoc && \
    ln -s /var/lang/bin/python3-config    /var/lang/bin/python-config

COPY lambda /

RUN ./install-rie.sh

RUN python3 -m pip install -U --no-cache-dir pip setuptools wheel && \
    python3 -m pip install --no-cache-dir --target /var/runtime awslambdaric boto3

WORKDIR /var/task
COPY src src

RUN /usr/sbin/useradd lambdauser -d /var/task
USER lambdauser

ENV APP_VERSION=1.0.0

ENTRYPOINT [ "/lambda-entrypoint.sh", "src/lambda-poc/lambda_function.handler"]