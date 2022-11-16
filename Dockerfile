FROM amazonlinux:2022.0.20221101.0 as builder
ARG PYTHON_VERSION=3.11.0
RUN dnf upgrade -y && dnf install -y wget xz gnupg2 dirmngr dnf-plugins-core --allowerasing
RUN dnf builddep -y python3
WORKDIR /opt

RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz.asc
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz
RUN gpg --keyserver hkps://keys.openpgp.org --recv-keys 64E628F8D684696D
RUN gpg --verify Python-${PYTHON_VERSION}.tar.xz.asc Python-${PYTHON_VERSION}.tar.xz
RUN tar xf Python-${PYTHON_VERSION}.tar.xz
WORKDIR /opt/Python-${PYTHON_VERSION}
RUN ./configure --prefix=/opt/py311 --enable-optimizations --with-lto=full --with-system-ffi --enable-loadable-sqlite-extensions
RUN make -j "$(nproc)"
RUN make altinstall

FROM amazonlinux:2022.0.20221101.0
RUN dnf upgrade -y
COPY --from=builder /opt/py311 /opt/py311
ENV PATH=/opt/py311/bin:${PATH}
RUN ln -s /opt/py311/bin/python3.11     /opt/py311/bin/python3 && \
ln -s /opt/py311/bin/python3.11         /opt/py311/bin/python && \
ln -s /opt/py311/bin/pip3.11            /opt/py311/bin/pip3 && \
ln -s /opt/py311/bin/pip3.11            /opt/py311/bin/pip && \
ln -s /opt/py311/bin/pydoc3.11          /opt/py311/bin/pydoc && \
ln -s /opt/py311/bin/python3.11-config  /opt/py311/bin/python-config
RUN python3 -m ensurepip && python3 -m pip install -U pip setuptools wheel
