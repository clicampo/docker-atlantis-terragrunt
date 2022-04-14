FROM ghcr.io/runatlantis/atlantis:v0.19.2

LABEL org.opencontainers.image.source=https://github.com/clicampo/docker-atlantis-terragrunt

ENV TERRAGRUNT_VERSION=v0.36.6 \
  VAULT_VERSION=1.9.3 \
  TERRAGRUNT_ATLANTIS_CONFIG_VERSION=1.14.2 \
  TERRAFORM_VERSION=1.1.8 \
  DEFAULT_TERRAFORM_VERSION=1.1.8 \
  AWS_CLI_VERSION=2.4.17 \
  GLIBC_VER=2.34-r0

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apk --no-cache add binutils \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
    && curl -Ls https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 --output /usr/local/bin/terragrunt \
    && chmod +x /usr/local/bin/terragrunt \
    && curl -LOs https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
    && unzip vault_${VAULT_VERSION}_linux_amd64.zip -d /usr/local/bin \
    && rm vault_${VAULT_VERSION}_linux_amd64.zip \
    && curl -Ls https://github.com/transcend-io/terragrunt-atlantis-config/releases/download/v${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}/terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64.tar.gz \
    | tar -xvz terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64/terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64 --strip-components=1 -C /usr/local/bin \
    && mv /usr/local/bin/terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64 /usr/local/bin/terragrunt-atlantis-config \
    && curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf \
    awscliv2.zip \
    aws \
    /usr/local/aws-cli/v2/*/dist/aws_completer \
    /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
    /usr/local/aws-cli/v2/*/dist/awscli/examples \
    && apk --no-cache del \
    && rm glibc-${GLIBC_VER}.apk \
    && rm glibc-bin-${GLIBC_VER}.apk \
    && rm -rf /var/cache/apk/*
