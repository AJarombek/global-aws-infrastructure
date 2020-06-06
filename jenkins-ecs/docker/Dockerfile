# Dockerfile for building a Jenkins server.
# Author: Andrew Jarombek
# Date: 6/3/2020

FROM jenkins/jenkins:lts

LABEL maintainer="andrew@jarombek.com" \
      version="1.0.0" \
      description="Dockerfile for building a Jenkins server"

USER root
WORKDIR /home/root

# Install Python 3.8
RUN apt-get update \
    && apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev \
    && curl -O https://www.python.org/ftp/python/3.8.2/Python-3.8.2.tar.xz \
    && tar -xf Python-3.8.2.tar.xz \
    && cd Python-3.8.2 \
    && ./configure --enable-optimizations \
    && make -j 4 \
    && make altinstall

# Cleanup after Python 3.8 installation.
RUN rm -f Python-3.8.2.tar.xz

# Install Terraform
RUN mkdir bin \
    && apt-get install -y wget \
    && wget https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip \
    && unzip terraform_0.12.26_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && terraform --version

# Install AWS CLI
RUN pip3.8 install awscli

# Install Node.js
RUN apt-get install -y build-essential libssl-dev \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
    && nvm install --lts  \
    && nvm use --lts \
    && npm i yarn -g

# Install JQ
RUN apt-get install -y jq

# Configure the Jenkins server with plugins and seed jobs.
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY jenkins.yaml /usr/share/jenkins/ref/jenkins.yaml
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

USER jenkins
EXPOSE 8080 50000