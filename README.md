# lambda-python-custom

Use Python >= 3.10 on AWS Lambda

Currently, AWS Lambda only supports Python versions 3.7 - 3.9. This project shows how to use a newer version by creating a custom runtime.

The Docker image is loosely based on [the one used by AWS Lambda for Python 3.9](https://gallery.ecr.aws/lambda/python) (see also [here](https://github.com/aws/aws-lambda-base-images/tree/python3.9)), and incorporates its default bootstrap files under [/lambda](lambda). It's built via github actions and deployed with Terraform.

## Dockerfile

Follows all the best practices I'm aware of. :) There are several ARGs for passing specific versions of the base image, OpenSSL, and Python, but I didn't attempt to pin every dependency. There's a tradeoff between reproducibility and convenience. 

- Starts with Amazon Linux 2, creates a builder stage from it, copies build artifacts back into the base.
- Builds OpenSSL and Python from source, checking pgp signatures. The dependencies and build options could no doubt be tweaked, but this is the simplest solution I found that makes a functional Python build.
- Links "python3" to "python"
- Curls the latest version of the [AWS Lambda Runtime Interface Emulator](https://github.com/aws/aws-lambda-runtime-interface-emulator/)
- Installs the latest versions of pip, setuptools, wheel, then [awslambdaric](https://github.com/aws/aws-lambda-python-runtime-interface-client) and boto3
- runs as a non-root user (though this may not matter for running on Lambda)

Maybe it would make more sense to use the Python 3.9 lambda image as the base. Doing so would likely entail a different set of tradeoffs with trying to remove Python 3.9 and edit configs.

## Lambda Function Code

[src/lambda-poc](src/lambda-poc) contains a basic function that returns HTTP 200, printing the Python version and lambda event payload.

## AWS Infrastructure

[infra/tf](infra/tf) contains terraform code that creates an ECR repository, a lambda function that depends on it, and a simple [lambda function URL](https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html). Terraform creates and manages the Cloudwatch log group that lambda would otherwise go cowboy with and create on its own, and the IAM policy is scoped accordingly.

## Github Actions Workflow

[.github/workflows/ci.yml](.github/workflows/ci.yml) 

- Builds, tests, and deploys the docker image to ECR
  - Images are tagged with the git SHA
  - Uses github GHA caching
  - The test just runs the container
- Lints, caches, and runs terraform plan and apply. Apply only runs on git push.
