ARG ALPINE_VERSION=3.16
FROM python:3.10.5-alpine${ALPINE_VERSION} as builder

ARG AWS_CLI_VERSION=2.7.20
RUN apk add --no-cache git unzip groff build-base libffi-dev cmake
RUN git clone --single-branch --depth 1 -b ${AWS_CLI_VERSION} https://github.com/aws/aws-cli.git

WORKDIR aws-cli
RUN sed -i'' 's/PyInstaller.*/PyInstaller==5.2/g' requirements-build.txt
RUN python -m venv venv
RUN . venv/bin/activate
RUN scripts/installers/make-exe
RUN unzip -q dist/awscli-exe.zip
RUN aws/install --bin-dir /aws-cli-bin
RUN /aws-cli-bin/aws --version

# reduce image size: remove autocomplete and examples
RUN rm -rf /usr/local/aws-cli/v2/current/dist/aws_completer /usr/local/aws-cli/v2/current/dist/awscli/data/ac.index /usr/local/aws-cli/v2/current/dist/awscli/examples
RUN find /usr/local/aws-cli/v2/current/dist/awscli/botocore/data -name examples-1.json -delete

# build the final image
FROM alpine:${ALPINE_VERSION}


FROM ghcr.io/runatlantis/atlantis:v0.19.4

LABEL org.opencontainers.image.source=https://github.com/clicampo/docker-atlantis-terragrunt

ENV TERRAGRUNT_VERSION=v0.37.4 \
  VAULT_VERSION=1.10.1 \
  TERRAGRUNT_ATLANTIS_CONFIG_VERSION=1.14.2 \
  TERRAFORM_VERSION=1.1.9 \
  DEFAULT_TERRAFORM_VERSION=1.1.9

# AWS CLI v2
COPY --from=builder /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=builder /aws-cli-bin/ /usr/local/bin/

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl -Ls https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 --output /usr/local/bin/terragrunt \
  && chmod +x /usr/local/bin/terragrunt \
  && curl -LOs https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
  && unzip vault_${VAULT_VERSION}_linux_amd64.zip -d /usr/local/bin \
  && rm vault_${VAULT_VERSION}_linux_amd64.zip \
  && curl -Ls https://github.com/transcend-io/terragrunt-atlantis-config/releases/download/v${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}/terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64.tar.gz \
  | tar -xvz terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64/terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64 --strip-components=1 -C /usr/local/bin \
  && mv /usr/local/bin/terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64 /usr/local/bin/terragrunt-atlantis-config
