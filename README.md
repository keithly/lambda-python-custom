# lambda-python-custom

Use Python >= 3.10 on AWS Lambda

Currently, AWS Lambda only supports Python versions 3.7 - 3.9. This project shows how to use a newer version by creating a custom runtime. This is documented by AWS in several different places and is tedious to piece together what's truly required.

Update: I've created a [simpler example](simple-example) that starts with the Debian-based official Python image and therefore doesn't require building it from source. The only dependency truly required is the [awslambdaric](https://github.com/aws/aws-lambda-python-runtime-interface-client), and everything can be copied into the same directory in the image.

## Dockerfile

The Docker image is loosely based on [the one used by AWS Lambda for Python 3.9](https://gallery.ecr.aws/lambda/python) (see also [here](https://github.com/aws/aws-lambda-base-images/tree/python3.9)), and incorporates its default bootstrap files under [/lambda](lambda). It's built via github actions and deployed with Terraform.

The Dockerfile follows all the best practices I'm aware of. :) There are several ARGs for passing specific versions of the base image, OpenSSL, and Python, but I didn't attempt to pin every dependency. There's a tradeoff between reproducibility and convenience. 

- Starts with Amazon Linux 2, creates a builder stage from it, copies build artifacts back into the base.
- Builds OpenSSL and Python from source, checking pgp signatures. The dependencies and build options could no doubt be tweaked, but this is the simplest solution I found that makes a functional Python build.
- Links "python3" to "python"
- Curls the latest version of the [AWS Lambda Runtime Interface Emulator](https://github.com/aws/aws-lambda-runtime-interface-emulator/)
- Installs the latest versions of pip, setuptools, wheel, then [awslambdaric](https://github.com/aws/aws-lambda-python-runtime-interface-client) and boto3
- runs as a non-root user (though this may not matter for running on Lambda)

Maybe it would make more sense to use the Python 3.9 lambda image as the base. Doing so would likely entail a different set of tradeoffs with trying to remove Python 3.9 and edit configs.

## AWS Lambda Runtime Interface Emulator

The image contains the [AWS Lambda Runtime Interface Emulator](https://github.com/aws/aws-lambda-runtime-interface-emulator/), which can emulate many features of AWS Lambda. Usage:

```bash
docker build -t hello-world .
docker run -it -p 9000:8080 hello-world:latest
```

From another shell:

```bash
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
```

## Lambda Function Code

[src/lambda-poc](src/lambda-poc) contains a basic function that returns HTTP 200, printing the Python version and lambda event payload.

## AWS Infrastructure

[infra/tf](infra/tf) contains terraform code that creates an ECR repository, a lambda function that depends on it, and a simple [lambda function URL](https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html). Terraform creates and manages the Cloudwatch log group that lambda would otherwise go cowboy with and create on its own, and the IAM policy is scoped accordingly. 

Note that when creating the infrastructure for the first time, there's a chicken-and-egg problem with the ECR Repository needing to exist first. The easiest way to handle this is to create it manually, then import to terraform:

`terraform import aws_ecr_repository.repo <ecr_repository_name>`

## Github Actions Workflow

[.github/workflows/ci.yml](.github/workflows/ci.yml) 

- Builds, tests, and deploys the docker image to ECR
  - Images are tagged with the git SHA
  - Uses github GHA caching
  - The test just runs the container
- Lints, caches, and runs terraform plan and apply. Apply only runs on git push.
