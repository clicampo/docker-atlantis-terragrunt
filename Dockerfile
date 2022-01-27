FROM runatlantis/atlantis:v0.18.2

LABEL org.opencontainers.image.source=https://github.com/clicampo/docker-atlantis-terragrunt

ENV TERRAGRUNT_VERSION=v0.36.0 \
    VAULT_VERSION=1.9.2 \
    TERRAGRUNT_ATLANTIS_CONFIG_VERSION=1.12.3 \
    TERRAFORM_VERSION=1.1.4 \
    DEFAULT_TERRAFORM_VERSION=1.1.4

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl -Ls https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 --output /usr/local/bin/terragrunt \
    && chmod +x /usr/local/bin/terragrunt \
    && curl -LOs https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
    && unzip vault_${VAULT_VERSION}_linux_amd64.zip -d /usr/local/bin \
    && rm vault_${VAULT_VERSION}_linux_amd64.zip \
    && curl -Ls https://github.com/transcend-io/terragrunt-atlantis-config/releases/download/v${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}/terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64.tar.gz \
    | tar -xvz terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64/terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64 --strip-components=1 -C /usr/local/bin \
    && mv /usr/local/bin/terragrunt-atlantis-config_${TERRAGRUNT_ATLANTIS_CONFIG_VERSION}_linux_amd64 /usr/local/bin/terragrunt-atlantis-config
