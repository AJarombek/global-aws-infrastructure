# Dockerfile for building a Jenkins server.
# Author: Andrew Jarombek
# Date: 6/3/2020

FROM jenkins/jenkins:lts

LABEL maintainer="andrew@jarombek.com" \
      version="1.0.0" \
      description="Dockerfile for building a Jenkins server"

USER root

# Install Python 3.8
RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get install -y python3.8 \
    && apt-get install -y python3-pip \
    && apt-get install -y python3.8-venv

# Install Terraform
WORKDIR /home/root
RUN mkdir bin \
    && apt-get install -y wget \
    && wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip \
    && unzip terraform_0.12.24_linux_amd64.zip \
    && mv terraform ~/bin \
    && terraform --version

# Install AWS CLI
RUN pip install awscli

# Install Node.js
RUN apt-get install -y build-essential libssl-dev \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash \
    && nvm install --lts  \
    && nvm use --lts

# Install JQ
RUN add-apt-repository -y ppa:eugenesan/ppa \
    && apt-get install -y jq

USER jenkins
EXPOSE 8080