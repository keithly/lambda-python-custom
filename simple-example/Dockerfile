# based on this example
# https://github.com/aws/aws-lambda-python-runtime-interface-client/blob/970e9c1d2613e0ce9c388547c76ac30992ad0e96/README.md

FROM public.ecr.aws/docker/library/python:3.12.0-slim-bookworm as build-image

# Install aws-lambda-cpp build dependencies (for awslambdaric) and curl
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    g++ \
    make \
    cmake \
    unzip \
    libcurl4-openssl-dev \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie -Lo /usr/local/bin/aws-lambda-rie && \
    chmod +x /usr/local/bin/aws-lambda-rie

WORKDIR /src

COPY app.py .
COPY requirements.txt .
RUN pip install \
    -r requirements.txt \
    --target /src \
    awslambdaric boto3

FROM public.ecr.aws/docker/library/python:3.12.0-slim-bookworm

WORKDIR /src

COPY ./lambda-entrypoint.sh /lambda-entrypoint.sh
COPY --from=build-image /usr/local/bin/aws-lambda-rie /usr/local/bin/aws-lambda-rie
COPY --from=build-image /src .

ENV APP_VERSION=1.0.0

ENTRYPOINT [ "/lambda-entrypoint.sh"]
CMD [ "app.handler" ]
