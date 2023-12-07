#!/bin/sh

if [ $# -ne 1 ]; then
  echo "entrypoint requires the handler name to be the first argument" 1>&2
  exit 142
fi

if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
  exec /usr/local/bin/aws-lambda-rie /var/lang/bin/python -m awslambdaric --log-level "debug" "$@"
else
  exec /var/lang/bin/python -m awslambdaric "$@"
fi
