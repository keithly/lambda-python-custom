#!/bin/bash

set -ex

archSuffix=""
if [[ "$1" == "arm64v8" ]]
then
  archSuffix="-arm64"
fi

url="https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie$archSuffix"
curl $url -Lo /usr/local/bin/aws-lambda-rie
chmod +x /usr/local/bin/aws-lambda-rie
