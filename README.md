# lambda-python-custom

Use Any Python Version on AWS Lambda

This project was created when AWS Lambda only supported Python versions 3.7 - 3.9, despite 3.10 and 3.11 having been
released for quite a while. Now AWS is again keeping up with Python versions, but this project shows how to use any
version by creating a custom runtime. The AWS documentation for how do this has improved but is still spread across
several different sites and pages.

## Dockerfile

The main Docker image is now based on the new
[Amazon Linux 2023 Provided image for Lambda](https://gallery.ecr.aws/lambda/provided) (also see
https://aws.amazon.com/blogs/compute/introducing-the-amazon-linux-2023-runtime-for-aws-lambda/). It's built via GitHub
actions and deployed with Terraform. This means a modern version of OpenSSL is available without having to build it from
source. However, the minimal image it's based on made verifying the Python source download more difficult
(see https://github.com/keithly/lambda-python-custom/issues/78).

The Dockerfile follows all the best practices I'm aware of. :) There are several ARGs for passing specific versions of
the base image and Python, but I didn't attempt to pin every dependency. There's a tradeoff between reproducibility and
convenience.

- Starts with Amazon Linux 2023, creates a builder stage from it, copies build artifacts back into the base.
- Builds Python from source The python build options optimize the build for speed of execution. The dependencies and
  build options could no doubt be tweaked, but this is the simplest solution I found that makes a functional Python
  build.
- Links "python3" to "python"
- Installs the latest version of
  the [AWS Lambda Runtime Interface Emulator](https://github.com/aws/aws-lambda-runtime-interface-emulator/)
- Installs the latest versions of pip, setuptools, wheel,
  then [awslambdaric](https://github.com/aws/aws-lambda-python-runtime-interface-client) and boto3
- runs as a non-root user (though this may not matter for running on Lambda)

There's also a [simpler example](simple-example) that starts with the Debian-based official Python image and
therefore doesn't require building it from source. The only dependency truly required is
the [awslambdaric](https://github.com/aws/aws-lambda-python-runtime-interface-client), and everything can be copied into
the same directory in the image.

## AWS Lambda Runtime Interface Emulator

The image contains
the [AWS Lambda Runtime Interface Emulator](https://github.com/aws/aws-lambda-runtime-interface-emulator/), which can
emulate many features of AWS Lambda. Usage:

```bash
docker build -t hello-world .
docker run -it -p 9000:8080 hello-world:latest
```

From another shell:

```bash
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
```

## Lambda Function Code

[src/lambda-poc](src/lambda-poc) contains a basic function that returns HTTP 200 and some json.

## AWS Infrastructure

[infra/tf](infra/tf) contains terraform code that creates an ECR repository, a lambda function that depends on it, and a
simple [lambda function URL](https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html). Terraform creates and
manages the Cloudwatch log group that lambda would otherwise go cowboy with and create on its own, and the IAM policy is
scoped accordingly.

Note that when creating the infrastructure for the first time, there's a chicken-and-egg problem with the ECR Repository
needing to exist first. The easiest way to handle this is to create it manually, then import to terraform:

`terraform import aws_ecr_repository.repo <ecr_repository_name>`

## GitHub Actions Workflow

[.github/workflows/ci.yml](.github/workflows/ci.yml)

- Builds and deploys the docker image to ECR
    - Images are tagged with the git SHA
    - Uses GitHub GHA caching
    - Testing the container before deploy is TBD
- Lints, caches, and runs terraform plan and apply. Apply only runs on git push.
